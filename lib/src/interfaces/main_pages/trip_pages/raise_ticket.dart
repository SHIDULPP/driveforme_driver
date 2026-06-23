import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/interfaces/components/input_field.dart';
import 'package:driveforme_driver/src/interfaces/components/primarybutton.dart';
import 'package:flutter/material.dart';

class RaiseTicketPage extends StatefulWidget {
  final String tripId;

  const RaiseTicketPage({super.key, this.tripId = '# ID2562'});

  @override
  State<RaiseTicketPage> createState() => _RaiseTicketPageState();
}

class _RaiseTicketPageState extends State<RaiseTicketPage> {
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    final subject = _subjectController.text.trim();
    final description = _descriptionController.text.trim();
    if (subject.isEmpty || description.isEmpty) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ticket submitted. Our team will get back to you soon.'),
      ),
    );
    Navigator.of(context).pop({
      'subject': subject,
      'description': description,
      'tripId': widget.tripId,
    });
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
              onPressed: _submit,
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
