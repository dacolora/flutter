import 'package:flutter/material.dart';
import 'package:mylifegame/ui/ui_token.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_log.dart';
import '../../domain/entities/life_area.dart';
import 'week_dots.dart';
import 'xp_varos_pills.dart';

class HabitCard extends StatelessWidget {
  const HabitCard({
    super.key,
    required this.habit,
    required this.weekDays,
    required this.isDueToday,
    required this.statusOf,
    required this.onTapDay,
  });

  final Habit habit;
  final List<DateTime> weekDays;
  final bool isDueToday;
  final HabitDayStatus Function(DateTime day) statusOf;
  final void Function(DateTime day) onTapDay;

  @override
  Widget build(BuildContext context) {
    final area = habit.area;
    final areaLabel = area?.label ?? 'Sin área';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: UiTokens.neonCard(),
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          children: [
            _AreaChip(area: area),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                habit.title,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ),
            ),
            if (!isDueToday)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Text('OFF', style: TextStyle(color: UiTokens.textSoft, fontWeight: FontWeight.w800)),
              )
          ],
        ),
        const SizedBox(height: 8),
        Text(areaLabel, style: const TextStyle(color: UiTokens.textSoft)),
        const SizedBox(height: 10),
        XpVarosPills(
          xp: habit.rewards.xp,
          varos: habit.rewards.varos,
          hp: habit.rewards.hp,
          xpLoss: habit.penalties.xpLoss,
          hpLoss: habit.penalties.hpLoss,
        ),
        const SizedBox(height: 10),
        WeekDots(
          days: weekDays,
          statusOf: statusOf,
          onTap: onTapDay,
        ),
      ]),
    );
  }
}

class _AreaChip extends StatelessWidget {
  const _AreaChip({required this.area});
  final LifeArea? area;

  @override
  Widget build(BuildContext context) {
    final label = area?.label ?? 'Any';
    final color = area == null ? UiTokens.neonBlue : UiTokens.neonGreen;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: UiTokens.borderSoft),
        color: UiTokens.card,
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w900)),
    );
  }
}