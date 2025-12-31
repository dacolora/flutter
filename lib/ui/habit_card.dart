import 'package:flutter/material.dart';
import 'package:mylifegame/infraestructure/habit_state_controller.dart';
import 'package:mylifegame/ui/habit_history_screen.dart';
import 'package:mylifegame/ui/habit_month.dart';
import 'package:mylifegame/ui/ui_token.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_log.dart';
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
            Expanded(
              child: Text(
                habit.title,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white),
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
