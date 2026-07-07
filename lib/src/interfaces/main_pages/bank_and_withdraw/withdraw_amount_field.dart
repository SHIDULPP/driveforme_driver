import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/models/wallet_model.dart';
import 'package:driveforme_driver/src/data/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WithdrawAmountField extends StatelessWidget {
  const WithdrawAmountField({
    super.key,
    required this.controller,
    this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: kWithdrawInputBorder.withValues(alpha: 0.45)),
      ),
      padding: EdgeInsets.symmetric(horizontal: context.rs(16)),
      child: Row(
        children: [
          Text(
            '₹',
            style: kStyle(
              kSemiBold,
              kSize18,
              color: kBrandBlue,
              height: 1,
            ),
          ),
          Container(
            height: context.rs(22),
            width: 1,
            margin: EdgeInsets.symmetric(horizontal: context.rs(12)),
            color: kCardBorder,
          ),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: kStyle(kMedium, kSize16, color: kTextColor, height: 1.2),
              decoration: InputDecoration(
                hintText: 'Enter Amount',
                hintStyle: kCaption14R.copyWith(color: kMutedText),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: context.rs(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PresetAmountChips extends StatelessWidget {
  const PresetAmountChips({
    super.key,
    required this.amounts,
    required this.selectedAmount,
    required this.onSelected,
  });

  final List<double> amounts;
  final double? selectedAmount;
  final ValueChanged<double> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: context.rs(8),
      runSpacing: context.rs(8),
      children: amounts.map((amount) {
        final isSelected = selectedAmount == amount;
        return GestureDetector(
          onTap: () => onSelected(amount),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.rs(14),
              vertical: context.rs(8),
            ),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? kBrandBlue : kCardBorder,
              ),
            ),
            child: Text(
              formatRupee(amount),
              style: kStyle(
                isSelected ? kSemiBold : kMedium,
                kSize13,
                color: kTextColor,
                height: 1.1,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
