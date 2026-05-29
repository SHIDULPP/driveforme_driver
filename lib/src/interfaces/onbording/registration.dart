import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/providers/loading_provider.dart';
import 'package:driveforme_driver/src/interfaces/animations/index.dart' as anim;
import 'package:driveforme_driver/src/interfaces/components/dropdown.dart';
import 'package:driveforme_driver/src/interfaces/components/input_field.dart';
import 'package:driveforme_driver/src/interfaces/components/primarybutton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegistrationPage extends ConsumerStatefulWidget {
  const RegistrationPage({super.key});

  @override
  ConsumerState<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends ConsumerState<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();

  String? selectedGender;

  final Map<String, GlobalKey> _fieldKeys = {
    'name': GlobalKey(),
    'email': GlobalKey(),
    'dob': GlobalKey(), // Added DOB key
    'gender': GlobalKey(),
  };

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      // Navigator.of(context).pushAndRemoveUntil(
      //   // MaterialPageRoute(builder: (context) => const NavBar()),
      //   // (route) => false,
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider);

    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: Column(
          children: [
            // ── Scrollable content ──────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.1,
                      ),

                      // ── Title ──────────────────────────────────────────
                      anim.AnimatedWidgetWrapper(
                        animationType:
                            anim.AppAnimationType.fadeSlideInFromLeft,
                        duration: anim.AnimationDuration.normal,
                        child: Text(
                          'Create Account',
                          style: const TextStyle(
                            fontFamily: 'ClashGrotesk',
                            fontSize: 36,
                            fontWeight: FontWeight.w500,
                            color: kTextColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      anim.AnimatedWidgetWrapper(
                        animationType:
                            anim.AppAnimationType.fadeSlideInFromLeft,
                        duration: anim.AnimationDuration.normal,
                        delayMilliseconds: 80,
                        child: const Text(
                          "Let's get you started",
                          style: TextStyle(
                            fontFamily: 'ClashGrotesk',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: kSecondaryTextColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ── Full Name ──────────────────────────────────────
                      const _FieldLabel(label: 'Full Name'),
                      const SizedBox(height: 8),
                      anim.AnimatedWidgetWrapper(
                        animationType:
                            anim.AppAnimationType.fadeSlideInFromBottom,
                        duration: anim.AnimationDuration.normal,
                        delayMilliseconds: 150,
                        child: InputField(
                          type: CustomFieldType.text,
                          hint: 'Enter your full name',
                          controller: _nameController,
                          focusNode: _nameFocus,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) =>
                              FocusScope.of(context).requestFocus(_emailFocus),
                          // validator: (v) =>
                          //     (v == null || v.trim().isEmpty) ? '' : null,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Email ──────────────────────────────────────────
                      const _FieldLabel(label: 'Email'),
                      const SizedBox(height: 8),
                      anim.AnimatedWidgetWrapper(
                        animationType:
                            anim.AppAnimationType.fadeSlideInFromBottom,
                        duration: anim.AnimationDuration.normal,
                        delayMilliseconds: 200,
                        child: InputField(
                          type: CustomFieldType.text,
                          hint: 'Enter your email',
                          controller: _emailController,
                          focusNode: _emailFocus,
                          textInputAction: TextInputAction.next,
                          // validator: (v) {
                          //   if (v == null || v.trim().isEmpty) return '';
                          //   final emailRegex = RegExp(
                          //     r'^[\w\.\+\-]+@[\w\-]+\.[a-zA-Z]{2,}$',
                          //   );
                          //   return emailRegex.hasMatch(v.trim()) ? null : '';
                          // },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Date of Birth ──────────────────────────────────
                      const _FieldLabel(label: 'Date of Birth'),
                      const SizedBox(height: 8),
                      anim.AnimatedWidgetWrapper(
                        animationType:
                            anim.AppAnimationType.fadeSlideInFromBottom,
                        duration: anim.AnimationDuration.normal,
                        delayMilliseconds: 250,
                        child: InputField(
                          type: CustomFieldType.date,
                          hint: 'DD-MM-YYYY',
                          controller: _dobController,
                          // validator: (v) =>
                          //     (v == null || v.trim().isEmpty) ? '' : null,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Gender ─────────────────────────────────────────
                      const _FieldLabel(label: 'Gender'),
                      const SizedBox(height: 8),
                      anim.AnimatedWidgetWrapper(
                        animationType:
                            anim.AppAnimationType.fadeSlideInFromBottom,
                        duration: anim.AnimationDuration.normal,
                        delayMilliseconds: 300,
                        child: FormField<String>(
                          key: _fieldKeys['gender'],
                          initialValue: selectedGender,
                          // validator: (value) =>
                          //     selectedGender == null || selectedGender!.isEmpty
                          //     ? "genderIsRequired"
                          //     : null,
                          builder: (FormFieldState<String> state) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AnimatedDropdown<String>(
                                  hint: "Select Gender",
                                  value: selectedGender,
                                  items: const ['Male', 'Female', 'Other'],
                                  itemLabel: (value) => value,
                                  borderColor: state.hasError
                                      ? Colors.red
                                      : null,
                                  onChanged: (v) {
                                    state.didChange(v);
                                    setState(() {
                                      selectedGender = v;
                                    });
                                  },
                                ),
                                if (state.hasError)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 6,
                                      left: 12,
                                    ),
                                    child: Text(
                                      state.errorText!,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),

            // ── Submit button pinned to bottom ──────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              child: anim.AnimatedWidgetWrapper(
                animationType: anim.AppAnimationType.fadeScaleUp,
                duration: anim.AnimationDuration.normal,
                delayMilliseconds: 350,
                child: primaryButton(
                  label: 'Submit',
                  buttonHeight: 56,
                  fontSize: 16,
                  onPressed: isLoading ? null : _handleSubmit,
                  isLoading: isLoading,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'ClashGrotesk',
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: kTextColor,
      ),
    );
  }
}
