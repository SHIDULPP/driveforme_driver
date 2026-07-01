import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

enum CustomFieldType { text, number, date, document }

class _DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    if (text.isEmpty) {
      return newValue;
    }

    // Extract only digits from the input
    final digitsOnly = text.replaceAll(RegExp(r'\D'), '');

    // Limit to 8 digits (ddmmyyyy)
    if (digitsOnly.length > 8) {
      return oldValue;
    }

    // Format with hyphens
    String formatted = '';
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i == 2 || i == 4) {
        formatted += '-';
      }
      formatted += digitsOnly[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class InputField extends StatelessWidget {
  final CustomFieldType type;
  final String hint;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;
  final void Function()? onUpload;
  final void Function(DateTime)? onDateSelected;
  final bool readOnly;
  final int maxLines;
  final bool allowDecimal;
  final FormFieldValidator<String>? validator;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const InputField({
    super.key,
    required this.type,
    required this.hint,
    required this.controller,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
    this.onUpload,
    this.onDateSelected,
    this.readOnly = false,
    this.maxLines = 1,
    this.allowDecimal = false,
    this.validator,
    this.firstDate,
    this.lastDate,
  });

  DateTime? _parseDate(String dateStr) {
    try {
      // Remove hyphens and parse dd-mm-yyyy format
      final cleanStr = dateStr.replaceAll('-', '');
      if (cleanStr.length != 8) return null;

      final day = int.parse(cleanStr.substring(0, 2));
      final month = int.parse(cleanStr.substring(2, 4));
      final year = int.parse(cleanStr.substring(4, 8));

      return DateTime(year, month, day);
    } catch (e) {
      return null;
    }
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final parsed = _parseDate(controller.text);
    final minDate = firstDate ?? DateTime(1900);
    final maxDate = lastDate ?? DateTime.now();
    var initialDate = parsed ?? DateTime.now();
    if (initialDate.isBefore(minDate)) initialDate = minDate;
    if (initialDate.isAfter(maxDate)) initialDate = maxDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: minDate,
      lastDate: maxDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.text = DateFormat('dd-MM-yyyy').format(picked);
      onDateSelected?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isText = type == CustomFieldType.text;
    final isNumber = type == CustomFieldType.number;
    final isDate = type == CustomFieldType.date;
    final isMultiline = isText && maxLines > 1;

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      maxLines: isText ? maxLines : 1,
      readOnly: readOnly || type == CustomFieldType.document,
      keyboardType: isNumber
          ? TextInputType.numberWithOptions(decimal: allowDecimal)
          : isDate
          ? TextInputType.number
          : isMultiline
          ? TextInputType.multiline
          : TextInputType.text,
      inputFormatters: isNumber
          ? [
              FilteringTextInputFormatter.allow(
                allowDecimal ? RegExp(r'^\d*\.?\d*$') : RegExp(r'\d+'),
              ),
            ]
          : isDate
          ? [_DateInputFormatter()]
          : null,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: const TextStyle(
        fontFamily: 'ClashGrotesk',
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: kTextColor,
      ),
      cursorColor: kPrimaryColor,
      onTap: () async {
        if (type == CustomFieldType.document) {
          onUpload?.call();
        }
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF5F5FA),

        hintText: hint,

        hintStyle: const TextStyle(
          color: Color(0xFF9C9C9C),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),

        errorStyle: const TextStyle(height: 0),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),

        suffixIcon: isDate
            ? GestureDetector(
                onTap: () => _showDatePicker(context),
                child: const Icon(
                  Icons.calendar_today_outlined,
                  size: 22,
                  color: Color(0xFF111111),
                ),
              )
            : type == CustomFieldType.document
            ? const Icon(
                Icons.cloud_upload_outlined,
                size: 22,
                color: Color(0xFF111111),
              )
            : null,

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: const BorderSide(color: Color(0xFFE8E8EF), width: 1),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: const BorderSide(color: Color(0xFFE8E8EF), width: 1),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }
}
