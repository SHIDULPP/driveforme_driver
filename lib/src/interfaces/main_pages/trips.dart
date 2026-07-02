import 'dart:async';

import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/models/trip_model.dart';
import 'package:driveforme_driver/src/data/providers/trip_history_provider.dart';
import 'package:driveforme_driver/src/data/utils/trip_lifecycle.dart';
import 'package:driveforme_driver/src/data/utils/trip_navigation.dart';
import 'package:driveforme_driver/src/data/utils/responsive.dart';
import 'package:driveforme_driver/src/interfaces/components/trip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _kTripsStatusBarBlue = Color(0xFF1A5288);
const _kTripsPageBg = Color(0xFFF8FAF5);
const _kTabActiveGold = Color(0xFFC19A6B);

class TripsPage extends ConsumerStatefulWidget {
  const TripsPage({super.key});

  @override
  ConsumerState<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends ConsumerState<TripsPage> {
  TripHistoryTab _selectedTab = TripHistoryTab.ongoing;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      _invalidateCurrentTab();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _invalidateCurrentTab() {
    ref.invalidate(tripHistoryProvider(_selectedTab));
    if (_selectedTab == TripHistoryTab.upcoming) {
      ref.invalidate(tripHistoryProvider(TripHistoryTab.ongoing));
    } else if (_selectedTab == TripHistoryTab.ongoing) {
      ref.invalidate(tripHistoryProvider(TripHistoryTab.upcoming));
    }
  }

  TripCardStatus _cardStatusFor(TripHistoryTab tab) {
    switch (tab) {
      case TripHistoryTab.ongoing:
        return TripCardStatus.ongoing;
      case TripHistoryTab.upcoming:
        return TripCardStatus.upcoming;
      case TripHistoryTab.completed:
        return TripCardStatus.completed;
      case TripHistoryTab.cancelled:
        return TripCardStatus.cancelled;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripsAsync = ref.watch(tripHistoryProvider(_selectedTab));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: _kTripsStatusBarBlue,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _kTripsPageBg,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ColoredBox(
              color: _kTripsStatusBarBlue,
              child: SafeArea(
                bottom: false,
                child: const SizedBox(height: 0),
              ),
            ),
            _TripsTabBar(
              selectedTab: _selectedTab,
              onTabSelected: (tab) {
                setState(() => _selectedTab = tab);
                ref.invalidate(tripHistoryProvider(tab));
              },
            ),
            Expanded(
              child: tripsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: kBrandBlue),
                ),
                error: (error, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          error.toString(),
                          textAlign: TextAlign.center,
                          style: kCaption14R.copyWith(color: kMutedText),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () =>
                              ref.invalidate(tripHistoryProvider(_selectedTab)),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (trips) {
                  if (trips.isEmpty) {
                    return Center(
                      child: Text(
                        'No ${_labelFor(_selectedTab).toLowerCase()} trips',
                        style: kCaption14R.copyWith(color: kMutedText),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: kBrandBlue,
                    onRefresh: () async {
                      _invalidateCurrentTab();
                      await ref.read(tripHistoryProvider(_selectedTab).future);
                    },
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        context.horizontalPadding,
                        context.rs(16),
                        context.horizontalPadding,
                        context.scaffoldBottomPadding,
                      ),
                      itemCount: trips.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final trip = trips[index];
                        final cardData = TripCardData.fromTripModel(
                          trip,
                          status: _cardStatusFor(_selectedTab),
                        );
                        return TripCard(
                          data: cardData,
                          onButtonPressed: () => _onTripPressed(trip, cardData),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onTripPressed(TripModel trip, TripCardData cardData) async {
    if (_selectedTab == TripHistoryTab.ongoing || trip.isOngoingForDriver) {
      final target = tripNavigationTarget(trip);
      if (target != null) {
        await navigateToActiveTrip(ref, trip);
        return;
      }
    }

    if (!mounted) return;
    Navigator.pushNamed(
      context,
      'tripDetails',
      arguments: {'trip': cardData, 'tripModel': trip},
    );
  }

  String _labelFor(TripHistoryTab tab) {
    switch (tab) {
      case TripHistoryTab.ongoing:
        return 'Ongoing';
      case TripHistoryTab.upcoming:
        return 'Upcoming';
      case TripHistoryTab.completed:
        return 'Completed';
      case TripHistoryTab.cancelled:
        return 'Cancelled';
    }
  }
}

class _TripsTabBar extends StatelessWidget {
  const _TripsTabBar({
    required this.selectedTab,
    required this.onTabSelected,
  });

  final TripHistoryTab selectedTab;
  final ValueChanged<TripHistoryTab> onTabSelected;

  static const _tabs = TripHistoryTab.values;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kWhite,
        border: Border(
          bottom: BorderSide(color: kCardBorder, width: 1),
        ),
      ),
      child: Row(
        children: _tabs.map((tab) {
          final isSelected = selectedTab == tab;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabSelected(tab),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: context.rs(14)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _labelFor(tab),
                        maxLines: 1,
                        softWrap: false,
                        style: kStyle(
                          isSelected ? kSemiBold : kMedium,
                          kSize14,
                          color: isSelected ? _kTabActiveGold : kTextColor,
                          height: 1.1,
                        ),
                      ),
                    ),
                    SizedBox(height: context.rs(8)),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      height: 2,
                      width: isSelected ? context.rs(28) : 0,
                      decoration: BoxDecoration(
                        color: _kTabActiveGold,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _labelFor(TripHistoryTab tab) {
    switch (tab) {
      case TripHistoryTab.ongoing:
        return 'Ongoing';
      case TripHistoryTab.upcoming:
        return 'Upcoming';
      case TripHistoryTab.completed:
        return 'Completed';
      case TripHistoryTab.cancelled:
        return 'Cancelled';
    }
  }
}
