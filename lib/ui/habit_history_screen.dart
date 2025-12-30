import 'package:flutter/material.dart';
import 'package:mylifegame/domain/entities/habit_log.dart';

class HabitHistoryScreen extends StatelessWidget {
  final String habitName;
  final int xp;
  final int varos;
  final int hp;
  final List<HabitLog> history;

  const HabitHistoryScreen({
    super.key,
    required this.habitName,
    required this.xp,
    required this.varos,
    required this.hp,
    required this.history,
  });

  DateTime _parseDayKey(String dayKey) {
    final parts = dayKey.split('-');
    return DateTime(
      int.parse(parts[0]), // Año
      int.parse(parts[1]), // Mes
      int.parse(parts[2]), // Día
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final daysInMonth = DateTime(today.year, today.month + 1, 0).day;

    return Scaffold(
      appBar: AppBar(
        title: Text(habitName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total XP: $xp', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Total Varos: $varos', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Total HP: $hp', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7, // 7 días de la semana
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: daysInMonth,
                itemBuilder: (context, index) {
                  final date = DateTime(today.year, today.month, index + 1);
                  final isPastDate = date.isBefore(today) || date.isAtSameMomentAs(today);
                  final log = history.firstWhere(
                    (log) {
                      final logDate = _parseDayKey(log.dayKey);
                      return logDate.year == date.year &&
                          logDate.month == date.month &&
                          logDate.day == date.day;
                    },
                    orElse: () => HabitLog(
                      id: '',
                      habitId: '',
                      dayKey: '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
                      status: HabitDayStatus.missed,
                    ),
                  );

                  Color dayColor;
                  switch (log.status) {
                    case HabitDayStatus.done:
                      dayColor = Colors.green;
                      break;
                    case HabitDayStatus.missed:
                      dayColor = Colors.red;
                      break;
                    default:
                      dayColor = Colors.grey;
                  }

                  return GestureDetector(
                    onTap: isPastDate
                        ? () {
                            // Acción para fechas pasadas (opcional)
                          }
                        : null, // No permitir interacción con fechas futuras
                    child: Container(
                      decoration: BoxDecoration(
                        color: dayColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${date.day}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
