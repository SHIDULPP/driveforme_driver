import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/interfaces/components/trip_card.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/trip_pages/trip_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _kTripsStatusBarBlue = Color(0xFF1A5288);
const _kTripsPageBg = Color(0xFFF8FAF5);
const _kTabActiveGold = Color(0xFFC19A6B);

enum _TripTab { ongoing, upcoming, completed, cancelled }

class TripsPage extends StatefulWidget {
  const TripsPage({super.key});

  @override
  State<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage> {
  _TripTab _selectedTab = _TripTab.ongoing;

  @override
  Widget build(BuildContext context) {
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
              onTabSelected: (tab) => setState(() => _selectedTab = tab),
            ),
            Expanded(
              child: _buildTabContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    final tripData = _tripDataForTab(_selectedTab);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        TripCard(
          data: tripData,
          onButtonPressed: _onTripCardButtonPressed,
        ),
      ],
    );
  }

  void _onTripCardButtonPressed() {
    switch (_selectedTab) {
      case _TripTab.ongoing:
        Navigator.pushNamed(context, 'driverArrived');
      case _TripTab.upcoming:
      case _TripTab.completed:
      case _TripTab.cancelled:
        Navigator.pushNamed(
          context,
          'tripDetails',
          arguments: {
            'trip': _tripDataForTab(_selectedTab),
            if (_selectedTab == _TripTab.completed) 'ticket': TripTicketInfo.dummy,
          },
        );
    }
  }

  TripCardData _tripDataForTab(_TripTab tab) {
    switch (tab) {
      case _TripTab.ongoing:
        return TripCardData.dummyOngoing();
      case _TripTab.upcoming:
        return TripCardData.dummyUpcoming();
      case _TripTab.completed:
        return TripCardData.dummyCompleted();
      case _TripTab.cancelled:
        return TripCardData.dummyCancelled();
    }
  }
}

class _TripsTabBar extends StatelessWidget {
  const _TripsTabBar({
    required this.selectedTab,
    required this.onTabSelected,
  });

  final _TripTab selectedTab;
  final ValueChanged<_TripTab> onTabSelected;

  static const _tabs = _TripTab.values;

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
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _labelFor(tab),
                      style: kStyle(
                        isSelected ? kSemiBold : kMedium,
                        kSize14,
                        color: isSelected ? _kTabActiveGold : kTextColor,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      height: 2,
                      width: isSelected ? 28 : 0,
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

  String _labelFor(_TripTab tab) {
    switch (tab) {
      case _TripTab.ongoing:
        return 'Ongoing';
      case _TripTab.upcoming:
        return 'Upcoming';
      case _TripTab.completed:
        return 'Completed';
      case _TripTab.cancelled:
        return 'Cancelled';
    }
  }
}
