import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labelsafe_ai/core/services/analysis_repository.dart';
import 'package:labelsafe_ai/core/models/analysis_result.dart';

final showScanTooltipProvider = StateProvider<bool>((ref) => true);

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

final analysisRepositoryProvider = Provider((ref) => AnalysisRepository());

final scanHistoryProvider = FutureProvider<List<ProductAnalysis>>((ref) async {
  final repo = ref.watch(analysisRepositoryProvider);
  return repo.getHistory();
});
