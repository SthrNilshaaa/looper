import 'package:flutter_riverpod/flutter_riverpod.dart';

final playerExpandProgressProvider = StateProvider<double>((ref) => 0.0);
final playerArtworkTopProvider = StateProvider<double?>((ref) => null);
final playerCollapseTriggerProvider = StateProvider<int>((ref) => 0);
