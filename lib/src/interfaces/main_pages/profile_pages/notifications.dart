import 'package:driveforme_driver/src/data/apis/notification_api.dart';
import 'package:driveforme_driver/src/data/apis/trip_api.dart';
import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/models/notification_model.dart';
import 'package:driveforme_driver/src/data/providers/notification_provider.dart';
import 'package:driveforme_driver/src/data/services/navigation_services.dart';
import 'package:driveforme_driver/src/data/utils/trip_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _kDividerColor = Color(0xFFEEEEEE);
const _kDateHeaderBg = Color(0xFFF2F4F7);
const _kUnreadDotColor = Color(0xFF1D5C92);
const _kTimestampColor = Color(0xFF5A7A9A);
const _kTitleColor = Color(0xFF0A1F33);

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

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
              _NotificationsHeader(
                onRefresh: () => ref.invalidate(notificationsProvider),
              ),
              const Divider(height: 1, thickness: 1, color: _kDividerColor),
              Expanded(
                child: notificationsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$error',
                            textAlign: TextAlign.center,
                            style: kCaption14R.copyWith(color: kMutedText),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () =>
                                ref.invalidate(notificationsProvider),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  data: (notifications) {
                    if (notifications.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.notifications_none_rounded,
                              size: 56,
                              color: kMutedText.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No notifications yet.',
                              style: kCaption14R.copyWith(color: kMutedText),
                            ),
                          ],
                        ),
                      );
                    }

                    final sections = _groupByDate(notifications);
                    return RefreshIndicator(
                      onRefresh: () async =>
                          ref.invalidate(notificationsProvider),
                      child: ListView(
                        children: [
                          for (final section in sections) ...[
                            _DateSectionHeader(label: section.dateLabel),
                            for (var i = 0; i < section.items.length; i++) ...[
                              _NotificationRow(
                                notification: section.items[i],
                                onTap: () => _onNotificationTap(
                                  context,
                                  ref,
                                  section.items[i],
                                ),
                                onDelete: () => _deleteNotification(
                                  context,
                                  ref,
                                  section.items[i],
                                ),
                              ),
                              if (i < section.items.length - 1)
                                const Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: _kDividerColor,
                                ),
                            ],
                          ],
                        ],
                      ),
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

  Future<void> _onNotificationTap(
    BuildContext context,
    WidgetRef ref,
    NotificationModel item,
  ) async {
    if (!item.isRead) {
      final response =
          await ref.read(notificationApiProvider).markAsRead(item.id);
      if (!response.success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Failed to mark as read.'),
          ),
        );
      }
      ref.invalidate(notificationsProvider);
    }

    if (item.type != 'trip_accepted') return;

    final tripId = item.payload['tripId']?.toString();
    if (tripId == null || tripId.isEmpty) return;

    final tripResponse = await ref.read(tripApiProvider).getTripById(tripId);
    if (!context.mounted) return;

    if (!tripResponse.success || tripResponse.data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tripResponse.message ?? 'Could not load trip details.'),
        ),
      );
      return;
    }

    final target = tripNavigationTarget(tripResponse.data!);
    if (target == null) return;

    NavigationService().pushNamed(
      target.route,
      arguments: target.arguments,
    );
  }

  Future<void> _deleteNotification(
    BuildContext context,
    WidgetRef ref,
    NotificationModel item,
  ) async {
    final response =
        await ref.read(notificationApiProvider).deleteNotification(item.id);
    if (!context.mounted) return;

    if (!response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message ?? 'Failed to delete.')),
      );
      return;
    }

    ref.invalidate(notificationsProvider);
  }

  List<_NotificationSection> _groupByDate(List<NotificationModel> items) {
    final sorted = [...items]
      ..sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

    final map = <String, List<NotificationModel>>{};
    for (final item in sorted) {
      final label = item.dateSectionLabel;
      map.putIfAbsent(label, () => []).add(item);
    }

    return map.entries
        .map(
          (entry) => _NotificationSection(
            dateLabel: entry.key,
            items: entry.value,
          ),
        )
        .toList();
  }
}

class _NotificationSection {
  final String dateLabel;
  final List<NotificationModel> items;

  const _NotificationSection({
    required this.dateLabel,
    required this.items,
  });
}

class _NotificationsHeader extends StatelessWidget {
  const _NotificationsHeader({required this.onRefresh});

  final VoidCallback onRefresh;

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
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded, color: kTextColor),
          ),
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
    required this.onDelete,
  });

  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  static const _dotSize = 8.0;
  static const _dotGap = 10.0;
  static const _contentIndent = _dotSize + _dotGap;

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: kRed,
        child: const Icon(Icons.delete_outline, color: kWhite),
      ),
      onDismissed: (_) => onDelete(),
      child: Material(
        color: isUnread ? kActiveGreenBg.withValues(alpha: 0.2) : kWhite,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isUnread) ...[
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
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.close, size: 18, color: kMutedText),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: isUnread ? _contentIndent : 0,
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
      ),
    );
  }
}
