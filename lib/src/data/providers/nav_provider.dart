import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

/// Controls which tab is selected in [NavBar].
///
/// 0 = Home, 1 = Trips, 2 = Earnings, 3 = Profile
final navBarIndexProvider = StateProvider<int>((ref) => 0);
