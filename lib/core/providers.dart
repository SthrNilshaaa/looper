import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'audio_service.dart';
import 'db_service.dart';
import 'package:isar/isar.dart';

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(() => service.dispose());
  return service;
});

final isarProvider = Provider<Isar>((ref) {
  return DbService.isar;
});

final startupFileProvider = Provider<String?>((ref) => null);

final searchFocusNodeProvider = Provider<FocusNode>((ref) {
  final node = FocusNode(debugLabel: 'SearchFocusNode');
  ref.onDispose(() => node.dispose());
  return node;
});
