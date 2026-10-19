import 'package:DriveFormeDriver/src/data/utils/trip_lifecycle.dart';
import 'package:DriveFormeDriver/src/interfaces/main_pages/support/support_pages.dart';
import 'package:DriveFormeDriver/src/data/apis/support_api.dart';
import 'package:DriveFormeDriver/src/data/constants/color_constants.dart';
import 'package:DriveFormeDriver/src/data/constants/style_constans.dart';
import 'package:DriveFormeDriver/src/interfaces/components/input_field.dart';
import 'package:DriveFormeDriver/src/interfaces/components/primarybutton.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RaiseTicketPage extends ConsumerStatefulWidget {
  final String tripId;
  final String category;

  const RaiseTicketPage({
    super.key,
    this.tripId = '',
    this.category = 'Trip Support',
  });

  @override
  ConsumerState<RaiseTicketPage> createState() => _RaiseTicketPageState();
}

class _RaiseTicketPageState extends ConsumerState<RaiseTicketPage> {
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final subject = _subjectController.text.trim();
    final description = _descriptionController.text.trim();
    if (subject.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('pleaseEnterSubjectDescription'.tr())),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final response = await ref
        .read(supportApiProvider)
        .createTicket(
          category: widget.category.trim().isEmpty
              ? 'Trip Support'
              : widget.category.trim(),
          subject: subject,
          description: description,
          tripMongoId: isMongoObjectId(widget.tripId) ? widget.tripId : null,
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (!response.success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_friendlyError(response.message))));
      return;
    }

    final ticketData = response.data?['data'];
    final ticketId = ticketData is Map
        ? ticketData['ticketId']?.toString()
        : null;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ticketId != null && ticketId.isNotEmpty
              ? 'ticketSubmittedWithId'.tr(args: [ticketId])
              : 'supportTicketSubmitted'.tr(),
        ),
      ),
    );
    final mongoId = ticketData is Map ? ticketData['_id']?.toString() : null;
    if (mongoId != null && isMongoObjectId(mongoId)) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => SupportChatPage(ticketId: mongoId),
        ),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  String _friendlyError(String? message) {
    final raw = message?.trim() ?? '';
    if (raw.isEmpty) return 'failedToSubmitTicket'.tr();
    final lower = raw.toLowerCase();
    if (lower.contains('e11000') ||
        lower.contains('duplicate key') ||
        lower.contains('ticketid')) {
      return 'couldNotCreateTicket'.tr();
    }
    if (lower.contains('linked trip not found')) {
      return 'tripCouldNotBeLinked'.tr();
    }
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: kScreenBg,
      appBar: AppBar(
        backgroundColor: kWhite,
        surfaceTintColor: kWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 22,
            color: kTextColor,
          ),
        ),
        title: Text(
          'support'.tr(),
          style: kStyle(kSemiBold, kSize18, color: kTextColor),
        ),
        actions: [
          IconButton(
            onPressed: () => launchPhoneCall('+916282359916'),
            tooltip: 'callSupport'.tr(),
            icon: const Icon(Icons.phone_outlined),
          ),
        ],
        titleSpacing: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OutlinedButton.icon(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const SupportTicketsPage(),
                            ),
                          ),
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: Text('viewMyTicketsReplies'.tr()),
                  ),
                  const SizedBox(height: 24),
                  Text('raiseATicket'.tr(), style: kTripSubSectionSB),
                  const SizedBox(height: 20),
                  Text('subject'.tr(), style: kTripSubSectionSB),
                  const SizedBox(height: 12),
                  InputField(
                    type: CustomFieldType.text,
                    hint: 'enterYourSubject'.tr(),
                    controller: _subjectController,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 28),
                  Text('description'.tr(), style: kTripSubSectionSB),
                  const SizedBox(height: 12),
                  InputField(
                    type: CustomFieldType.text,
                    hint: 'typeYourDescription'.tr(),
                    controller: _descriptionController,
                    maxLines: 6,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, bottomInset + 16),
            child: primaryButton(
              label: 'submit'.tr(),
              onPressed: _isSubmitting ? null : _submit,
              isLoading: _isSubmitting,
              buttonColor: kTripCtaBlue,
              buttonHeight: 54,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
