import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/services/navigation_services.dart';
import 'package:driveforme_driver/src/data/utils/responsive.dart';
import 'package:driveforme_driver/src/interfaces/components/primarybutton.dart';
import 'package:driveforme_driver/src/data/models/bank_account_ui_model.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/bank_and_withdraw/verified_badge.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/bank_and_withdraw/withdraw_flow_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectBankSheet extends ConsumerStatefulWidget {
  const SelectBankSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SelectBankSheet(),
    );
  }

  @override
  ConsumerState<SelectBankSheet> createState() => _SelectBankSheetState();
}

class _SelectBankSheetState extends ConsumerState<SelectBankSheet> {
  late String? _selectedId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final flow = ref.read(withdrawFlowProvider);
      setState(() {
        _selectedId =
            flow.selectedBankId ?? flow.bankAccounts.firstOrNull?.id;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(withdrawFlowProvider).bankAccounts;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.82,
        ),
        decoration: const BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(20, 12, 20, bottomInset + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: kCardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: context.rs(14)),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Select Bank account',
                    style: kStyle(kSemiBold, kSize18, color: kTextColor),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: context.rs(32),
                    width: context.rs(32),
                    decoration: BoxDecoration(
                      color: kSearchFieldBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: context.rs(18),
                      color: kTextColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: context.rs(16)),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: accounts.length,
                separatorBuilder: (_, _) => SizedBox(height: context.rs(10)),
                itemBuilder: (context, index) {
                  final account = accounts[index];
                  final isSelected = _selectedId == account.id;
                  return _SelectableBankTile(
                    account: account,
                    isSelected: isSelected,
                    onTap: () => setState(() => _selectedId = account.id),
                  );
                },
              ),
            ),
            SizedBox(height: context.rs(12)),
            _AddBankDashedButton(
              onTap: () {
                Navigator.pop(context);
                NavigationService().pushNamed('addBankAccount');
              },
            ),
            SizedBox(height: context.rs(14)),
            primaryButton(
              label: 'Confirm Selection',
              buttonColor: kBrandBlue,
              onPressed: _selectedId == null
                  ? null
                  : () {
                      ref
                          .read(withdrawFlowProvider.notifier)
                          .selectBank(_selectedId!);
                      Navigator.pop(context);
                    },
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectableBankTile extends StatelessWidget {
  const _SelectableBankTile({
    required this.account,
    required this.isSelected,
    required this.onTap,
  });

  final BankAccountUiModel account;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(context.rs(12)),
        decoration: BoxDecoration(
          color: isSelected ? kWithdrawSelectedBankBg : kWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? kWithdrawSelectedBankBorder : kCardBorder,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isSelected ? kBrandBlue : kMutedText,
              size: context.rs(22),
            ),
            SizedBox(width: context.rs(10)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(account.bankName, style: kCaption14B),
                  SizedBox(height: context.rs(2)),
                  Text(
                    account.maskedAccountNumber,
                    style: kCaption12R.copyWith(color: kSecondaryTextColor),
                  ),
                  Text(
                    account.holderName,
                    style: kCaption12R.copyWith(color: kMutedText),
                  ),
                ],
              ),
            ),
            const VerifiedBadge(compact: true),
          ],
        ),
      ),
    );
  }
}

class _AddBankDashedButton extends StatelessWidget {
  const _AddBankDashedButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: kWithdrawDashedBorder.withValues(alpha: 0.5),
          radius: 14,
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: context.rs(14)),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, color: kBrandBlue, size: context.rs(18)),
              SizedBox(width: context.rs(6)),
              Text(
                'Add New Bank Account',
                style: kStyle(kMedium, kSize14, color: kBrandBlue),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius),
        ),
      );

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) => false;
}

extension _FirstOrNull<E> on List<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
