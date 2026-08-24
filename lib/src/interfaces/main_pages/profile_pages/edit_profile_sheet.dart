import 'dart:io';

import 'package:driveforme_driver/src/data/apis/onboarding_api.dart';
import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/models/user_model.dart';
import 'package:driveforme_driver/src/data/providers/loading_provider.dart';
import 'package:driveforme_driver/src/data/providers/user_provider.dart';
import 'package:driveforme_driver/src/data/services/upload_service.dart';
import 'package:driveforme_driver/src/data/utils/date_utils.dart';
import 'package:driveforme_driver/src/data/utils/document_upload_helper.dart';
import 'package:driveforme_driver/src/interfaces/components/input_field.dart';
import 'package:driveforme_driver/src/interfaces/components/primarybutton.dart';
import 'package:driveforme_driver/src/interfaces/components/profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class EditProfileSheet extends ConsumerStatefulWidget {
  const EditProfileSheet({super.key, required this.user});

  final UserModel user;

  static Future<void> show(BuildContext context, UserModel user) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => EditProfileSheet(user: user),
    );
  }

  @override
  ConsumerState<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _dobController;

  String? _photoUrl;
  String? _localPhotoPath;
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    final profile = widget.user.profile;
    _nameController = TextEditingController(text: profile.fullName);
    _phoneController = TextEditingController(text: displayPhone(widget.user));
    _emailController = TextEditingController(text: profile.email);
    _dobController = TextEditingController(
      text: profile.dateOfBirth != null
          ? DateFormat('dd/MM/yyyy').format(profile.dateOfBirth!)
          : '',
    );
    _photoUrl = profilePhotoUrl(widget.user);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _pickProfilePhoto() async {
    setState(() => _isUploadingPhoto = true);

    try {
      final result = await pickAndUploadDocumentImage(
        context: context,
        uploadService: ref.read(uploadServiceProvider),
        folder: 'driver-documents',
      );

      if (!mounted || result == null) return;

      setState(() {
        _photoUrl = result.imageUrl;
        _localPhotoPath = result.localPath;
      });
    } catch (e) {
      if (!mounted) return;
      _showMessage('Failed to upload photo. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    ref.read(loadingProvider.notifier).startLoading();

    try {
      final profile = widget.user.profile;
      final response = await ref.read(onboardingApiProvider).submitDriverProfile(
            fullName: _nameController.text.trim(),
            email: _emailController.text.trim(),
            dateOfBirth: dobUiToApi(_dobController.text.trim()),
            gender: profile.gender.isNotEmpty
                ? profile.gender
                : genderUiToApi('Male'),
            location: profile.location.isNotEmpty
                ? profile.location
                : locationUiToApi('Kochi'),
          );

      if (!mounted) return;

      if (!response.success) {
        _showMessage(response.message ?? 'Failed to update profile');
        return;
      }

      final verification = widget.user.driverVerification;
      final newPhotoUrl = _photoUrl?.trim();
      final existingPhotoUrl = verification.livePhotoUrl.trim();
      final photoChanged =
          newPhotoUrl != null &&
          newPhotoUrl.isNotEmpty &&
          newPhotoUrl != existingPhotoUrl;

      if (photoChanged &&
          verification.aadhaarImageUrl.isNotEmpty &&
          verification.drivingLicenseImageUrl.isNotEmpty) {
        final identityResponse = await ref
            .read(onboardingApiProvider)
            .submitDriverIdentity(
              aadhaarImageUrl: verification.aadhaarImageUrl,
              drivingLicenseImageUrl: verification.drivingLicenseImageUrl,
              livePhotoUrl: newPhotoUrl,
            );

        if (!mounted) return;

        if (!identityResponse.success) {
          _showMessage(
            identityResponse.message ?? 'Profile saved but photo update failed',
          );
          ref.invalidate(userProvider);
          Navigator.of(context).pop();
          return;
        }
      }

      ref.invalidate(userProvider);
      if (!mounted) return;
      Navigator.of(context).pop();
      _showMessage('Profile updated successfully');
    } on FormatException {
      _showMessage('Please enter date of birth as DD/MM/YYYY');
    } finally {
      ref.read(loadingProvider.notifier).stopLoading();
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.88,
        ),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(
                      'Edit profile',
                      style: kStyle(kMedium, kSize18, color: kTextColor),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: isLoading
                          ? null
                          : () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      icon: Container(
                        height: 28,
                        width: 28,
                        decoration: BoxDecoration(
                          color: kFigmaNeutral,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: kMutedText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(child: _buildAvatar(isLoading)),
                const SizedBox(height: 24),
                _EditField(
                  label: 'Name',
                  child: InputField(
                    type: CustomFieldType.text,
                    hint: 'Enter your name',
                    controller: _nameController,
                    validator: (value) =>
                        value == null || value.trim().isEmpty
                        ? 'Name is required'
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                _EditField(
                  label: 'Mobile Number',
                  child: InputField(
                    type: CustomFieldType.text,
                    hint: 'Mobile number',
                    controller: _phoneController,
                    readOnly: true,
                  ),
                ),
                const SizedBox(height: 16),
                _EditField(
                  label: 'Email',
                  child: InputField(
                    type: CustomFieldType.text,
                    hint: 'Add Email ID',
                    controller: _emailController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email is required';
                      }
                      final emailRegex = RegExp(
                        r'^[\w\.\+\-]+@[\w\-]+\.[a-zA-Z]{2,}$',
                      );
                      return emailRegex.hasMatch(value.trim())
                          ? null
                          : 'Enter a valid email';
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _EditField(
                  label: 'Date of Birth',
                  child: InputField(
                    type: CustomFieldType.date,
                    hint: 'Add DOB',
                    controller: _dobController,
                    validator: (value) =>
                        value == null || value.trim().isEmpty
                        ? 'Date of birth is required'
                        : null,
                  ),
                ),
                const SizedBox(height: 24),
                primaryButton(
                  label: 'save',
                  onPressed: isLoading || _isUploadingPhoto ? null : _saveProfile,
                  isLoading: isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(bool isLoading) {
    final localFile = _localPhotoPath != null ? File(_localPhotoPath!) : null;
    final hasLocalPreview = localFile != null && localFile.existsSync();

    Widget avatar;
    if (hasLocalPreview) {
      avatar = ClipRRect(
        borderRadius: BorderRadius.circular(55),
        child: Image.file(
          localFile,
          width: 110,
          height: 110,
          fit: BoxFit.cover,
        ),
      );
    } else {
      avatar = ProfileAvatar(
        imageUrl: _photoUrl,
        initials: profileInitials(widget.user),
        size: 110,
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        if (_isUploadingPhoto)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: kWhite,
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: _isUploadingPhoto || isLoading ? null : _pickProfilePhoto,
            child: Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                color: kWhite,
                shape: BoxShape.circle,
                border: Border.all(color: kCardBorder),
                boxShadow: [
                  BoxShadow(
                    color: kBlack.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.edit_outlined,
                size: 16,
                color: kTextColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EditField extends StatelessWidget {
  const _EditField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: kCaption12R.copyWith(color: kMutedText),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
