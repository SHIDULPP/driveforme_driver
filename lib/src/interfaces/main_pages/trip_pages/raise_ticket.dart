import 'package:driveforme_driver/src/data/apis/support_api.dart';
import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/interfaces/components/input_field.dart';
import 'package:driveforme_driver/src/interfaces/components/primarybutton.dart';
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
        const SnackBar(content: Text('Please enter subject and description.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final response = await ref.read(supportApiProvider).createTicket(
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_friendlyError(response.message))),
      );
      return;
    }

    final ticketData = response.data?['data'];
    final ticketId =
        ticketData is Map ? ticketData['ticketId']?.toString() : null;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ticketId != null && ticketId.isNotEmpty
              ? 'Ticket $ticketId submitted successfully.'
              : 'Support ticket submitted successfully.',
        ),
      ),
    );
    Navigator.of(context).pop({
      'subject': subject,
      'description': description,
      'tripId': widget.tripId,
      if (ticketId != null && ticketId.isNotEmpty) 'ticketId': ticketId,
    });
  }

  String _friendlyError(String? message) {
    final raw = message?.trim() ?? '';
    if (raw.isEmpty) return 'Failed to submit ticket.';
    final lower = raw.toLowerCase();
    if (lower.contains('e11000') ||
        lower.contains('duplicate key') ||
        lower.contains('ticketid')) {
      return 'Could not create ticket right now. Please try again in a moment.';
    }
    if (lower.contains('linked trip not found')) {
      return 'This trip could not be linked. Please try again from the trip details.';
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
          'Raise a ticket',
          style: kStyle(kSemiBold, kSize18, color: kTextColor),
        ),
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
                  Text('Subject', style: kTripSubSectionSB),
                  const SizedBox(height: 12),
                  InputField(
                    type: CustomFieldType.text,
                    hint: 'Enter your subject',
                    controller: _subjectController,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 28),
                  Text('Description', style: kTripSubSectionSB),
                  const SizedBox(height: 12),
                  InputField(
                    type: CustomFieldType.text,
                    hint: 'Type your description here...',
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
              label: 'Submit',
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
