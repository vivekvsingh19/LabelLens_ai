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

final streakProvider = Provider<int>((ref) {
  final historyValue = ref.watch(scanHistoryProvider);

  return historyValue.maybeWhen(
    data: (history) {
      if (history.isEmpty) return 0;

      final uniqueDates = history
          .map((e) {
            return DateTime(e.date.year, e.date.month, e.date.day);
          })
          .toSet()
          .toList()
        ..sort((a, b) => b.compareTo(a));

      if (uniqueDates.isEmpty) return 0;

      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      // If the last scan was before yesterday, streak is 0
      if (todayDate.difference(uniqueDates.first).inDays > 1) {
        return 0;
      }

      int streak = 1;
      DateTime expectedPrevDate =
          uniqueDates.first.subtract(const Duration(days: 1));

      for (int i = 1; i < uniqueDates.length; i++) {
        if (uniqueDates[i].isAtSameMomentAs(expectedPrevDate)) {
          streak++;
          expectedPrevDate = expectedPrevDate.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }
      return streak;
    },
    orElse: () => 0,
  );
});
