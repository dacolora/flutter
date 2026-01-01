import 'package:flutter/material.dart';
import 'package:mylifegame/infraestructure/habit_state_controller.dart';
import 'package:mylifegame/ui/habit_add_screen.dart';
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
    final areaLabel = area?.name ?? 'Sin área';

    final _difficulty = habit.difficulty ;

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
                   Text(areaLabel, style: const TextStyle(color: UiTokens.textSoft,fontWeight: FontWeight.bold, )),

                   Text('-', style: const TextStyle(color: UiTokens.textSoft,fontWeight: FontWeight.bold, )),
                   Text(
                    difficultyLabel(_difficulty),
                    style: const TextStyle(color: Colors.white),
                  ),

          ],
        ),
        const SizedBox(height: 8),

        WeekDots(
          days: weekDays,
          statusOf: statusOf,
          onTap: onTapDay,
        ),
      ]),
    );
  }
}
