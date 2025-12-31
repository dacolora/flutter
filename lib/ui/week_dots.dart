import 'package:flutter/material.dart';
import '../../core/time.dart';
import '../../domain/entities/habit_log.dart';
import 'package:mylifegame/ui/ui_token.dart';


class WeekDots extends StatelessWidget {
  const WeekDots({
    super.key,
    required this.days,
    required this.statusOf,
    required this.onTap,
  });

  final List<DateTime> days;
  final HabitDayStatus Function(DateTime day) statusOf;
  final void Function(DateTime day) onTap;

  @override
Widget build(BuildContext context) {
  final dynamicLabels = getDynamicLabels(DateTime.now()); // Reorganiza los labels dinámicamente

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: List.generate(7, (i) {
      final d = days[i];
      final status = statusOf(d);
      final isToday = Time.ymd(d) == Time.ymd(DateTime.now());
      final style = TextStyle(
        color: isToday ? Colors.white : UiTokens.textSoft,
        fontWeight: FontWeight.w800,
        fontSize: 12,
      );

      final (bg, border) = _colors(status);
      return GestureDetector(
        onTap: () => onTap(d),
        child: Column(
          children: [
            Text(dynamicLabels[i], style: style), // Usa los labels dinámicos
            const SizedBox(height: 6),
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: bg,
                shape: BoxShape.circle,
                border: Border.all(color: border),
              ),
              child: _icon(status),
            ),
          ],
        ),
      );
    }),
  );
  }

  List<String> getDynamicLabels(DateTime today) {
  const labels = ['Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sa', 'Do'];
  final todayIndex = today.weekday - 1; // Índice del día actual (0 = lunes)
  return [
    ...labels.sublist(todayIndex + 1), // Días restantes de la semana
    ...labels.sublist(0, todayIndex + 1), // Días anteriores al día actual
  ];
}

  (Color, Color) _colors(HabitDayStatus s) {
    switch (s) {
      case HabitDayStatus.done:
        return (UiTokens.neonGreen.withOpacity(0.20), UiTokens.neonGreen);
      case HabitDayStatus.missed:
        return (UiTokens.danger.withOpacity(0.20), UiTokens.danger);
      case HabitDayStatus.skipped:
        return (UiTokens.card, UiTokens.textSoft);
      case HabitDayStatus.pending:
        return (UiTokens.card, UiTokens.borderSoft);
    }
  }

  Widget _icon(HabitDayStatus s) {
    switch (s) {
      case HabitDayStatus.done:
        return const Icon(Icons.check, size: 18, color: UiTokens.neonGreen);
      case HabitDayStatus.missed:
        return const Icon(Icons.close, size: 18, color: UiTokens.danger);
      case HabitDayStatus.skipped:
        return const Icon(Icons.fast_forward, size: 18, color: UiTokens.textSoft);
      case HabitDayStatus.pending:
        return const SizedBox.shrink();
    }
  }
}