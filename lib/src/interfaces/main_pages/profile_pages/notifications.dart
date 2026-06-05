import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _kDividerColor = Color(0xFFEEEEEE);
const _kDateHeaderBg = Color(0xFFF2F4F7);
const _kUnreadDotColor = Color(0xFF1D5C92);
const _kTimestampColor = Color(0xFF5A7A9A);
const _kTitleColor = Color(0xFF0A1F33);

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  static const _notifications = [
    _NotificationItem(
      title: 'Please update Membership',
      body:
          'Your membership plan has expired. Renew now to continue enjoying '
          'premium features and uninterrupted access.',
      timeAgo: '3 hours ago',
      isUnread: true,
    ),
    _NotificationItem(
      title: 'New Offer Available',
      body:
          'Get 20% off on your annual subscription if you upgrade today. '
          'Limited-time offer!',
      timeAgo: '3 hours ago',
      isUnread: true,
    ),
    _NotificationItem(
      title: 'New Offer Available',
      body:
          'Get 20% off on your annual subscription if you upgrade today. '
          'Limited-time offer!',
      timeAgo: '3 hours ago',
      isUnread: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: kWhite,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: kWhite,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _NotificationsHeader(),
              const Divider(height: 1, thickness: 1, color: _kDividerColor),
              const _DateSectionHeader(label: 'Sat, 10 Mar'),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: _notifications.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    thickness: 1,
                    color: _kDividerColor,
                  ),
                  itemBuilder: (context, index) {
                    return _NotificationRow(
                      notification: _notifications[index],
                      onTap: () {},
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationItem {
  const _NotificationItem({
    required this.title,
    required this.body,
    required this.timeAgo,
    required this.isUnread,
  });

  final String title;
  final String body;
  final String timeAgo;
  final bool isUnread;
}

class _NotificationsHeader extends StatelessWidget {
  const _NotificationsHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: kTextColor,
            ),
          ),
          Expanded(
            child: Text(
              'Notifications',
              textAlign: TextAlign.center,
              style: kStyle(
                kSemiBold,
                kSize18,
                color: kTextColor,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(width: 40, height: 40),
        ],
      ),
    );
  }
}

class _DateSectionHeader extends StatelessWidget {
  const _DateSectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _kDateHeaderBg,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(
        label,
        style: kStyle(
          kMedium,
          kSize14,
          color: kTripBodyMuted,
          height: 1.2,
        ),
      ),
    );
  }
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({
    required this.notification,
    required this.onTap,
  });

  final _NotificationItem notification;
  final VoidCallback onTap;

  static const _dotSize = 8.0;
  static const _dotGap = 10.0;
  static const _contentIndent = _dotSize + _dotGap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (notification.isUnread) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Container(
                        height: _dotSize,
                        width: _dotSize,
                        decoration: const BoxDecoration(
                          color: _kUnreadDotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: _dotGap),
                  ],
                  Expanded(
                    child: Text(
                      notification.title,
                      style: kStyle(
                        kSemiBold,
                        kSize16,
                        color: _kTitleColor,
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: notification.isUnread ? _contentIndent : 0,
                  top: 6,
                ),
                child: Text(
                  notification.body,
                  style: kCaption13R.copyWith(
                    color: kTripBodyMuted,
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  notification.timeAgo,
                  style: kCaption12R.copyWith(
                    color: _kTimestampColor,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
