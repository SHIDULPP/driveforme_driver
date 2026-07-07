import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WithdrawAppBar extends StatelessWidget implements PreferredSizeWidget {
  const WithdrawAppBar({
    super.key,
    required this.title,
    this.showHelp = false,
    this.onBack,
  });

  final String title;
  final bool showHelp;
  final VoidCallback? onBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: kWhite,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      leading: IconButton(
        onPressed: onBack ?? () => Navigator.maybePop(context),
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        color: kTextColor,
      ),
      title: Text(
        title,
        style: kStyle(kMedium, kSize17, color: kTextColor, height: 1.15),
      ),
      actions: [
        if (showHelp)
          Padding(
            padding: EdgeInsets.only(right: context.rs(12)),
            child: IconButton(
              onPressed: () {},
              icon: Container(
                height: context.rs(28),
                width: context.rs(28),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: kCardBorder),
                ),
                child: Icon(
                  Icons.help_outline_rounded,
                  size: context.rs(16),
                  color: kTextColor,
                ),
              ),
            ),
          )
        else
          SizedBox(width: context.rs(12)),
      ],
    );
  }
}

class WithdrawScaffold extends StatelessWidget {
  const WithdrawScaffold({
    super.key,
    required this.title,
    required this.body,
    this.showHelp = false,
    this.bottom,
    this.onBack,
  });

  final String title;
  final Widget body;
  final bool showHelp;
  final Widget? bottom;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: kWhite,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: kScreenBg,
        appBar: WithdrawAppBar(
          title: title,
          showHelp: showHelp,
          onBack: onBack,
        ),
        body: body,
        bottomNavigationBar: bottom,
      ),
    );
  }
}
