import 'package:flutter/material.dart';
import 'package:mylifegame/ui/habit_card.dart';
import 'package:mylifegame/ui/habit_add_screen.dart';
import 'package:mylifegame/ui/habit_month.dart';
import 'package:mylifegame/ui/ui_token.dart';
import '../../core/time.dart';
import '../../domain/entities/habit_log.dart';
import '../infraestructure/service/app_scope.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  @override
  Widget build(BuildContext context) {
    final habits = AppScope.of(context).habitController;

    return AnimatedBuilder(
      animation: habits,
      builder: (context, _) {
            print('Redibujando UI');
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: const Text('Mis Habitos'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HabitAddScreen()),
                ),
              ),
            ],
          ),
          body: habits.loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _TopWeekHeader(day: habits.today),
                    const SizedBox(height: 12),
                    if (habits.error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          habits.error!,
                          style: const TextStyle(color: UiTokens.danger),
                        ),
                      ),
                    ...habits.habits.map((h) {
                      getDynamicWeekDays(
                        habits.today,
                      ); // Últimos 7 días
                      final last7Days = getDynamicWeekDays(
                        DateTime.now(),
                      ); // Últimos 7 días

                      final yearlyStatus = habits.getYearlyStatus(
                        h.id,
                        DateTime.now().year,
                      );
                      yearlyStatus.keys
                          .where((d) => d.month == DateTime.now().month)
                          .toList();
          

                      return GestureDetector(
                        onTap: () => Navigator.push(
                          
                          context,
                          MaterialPageRoute(
                            builder: (_) => HabitsMonthScreen(
                              
                              day: yearlyStatus.keys.toList(),
                              statusOf: (d) =>
                                  habits.statusOf(h.id, d),
                            ),
                          ),
                        ),
                        child: HabitCard(
                          habit: h,
                          weekDays: last7Days,
                          isDueToday: h.schedule.isDueOn(
                            Time.isoWeekday(habits.today),
                          ),
                          statusOf: (d) => habits.statusOf(h.id, d),
                          onTapDay: (d) {
                              _openDayPicker(context, h.title, (status) {
                                habits.setStatus(h, d, status);
                              });
                              setState(() {
                                
                              });
                          },
                        ),
                      );
                    }),
                    const SizedBox(height: 80),
                  ],
                ),
        );
      },
    );
  }

  List<DateTime> getDynamicWeekDays(DateTime today) {
    final weekStart = today.subtract(
      Duration(days: today.weekday - 1),
    ); // Lunes
    final weekDays = List.generate(
      7,
      (index) => weekStart.add(Duration(days: index)),
    );

    // Reorganiza los días para que el día actual esté al final
    final todayIndex = today.weekday - 1; // Índice del día actual (0 = lunes)
    return [
      ...weekDays.sublist(todayIndex + 1), // Días restantes de la semana
      ...weekDays.sublist(0, todayIndex + 1), // Días anteriores al día actual
    ];
  }

  Future<void> _openDayPicker(
    BuildContext context,
    String habitTitle,
    void Function(HabitDayStatus status) onPick,
  ) async {
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: UiTokens.card,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              habitTitle,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            const SizedBox(height: 12),
            _PickTile(
              '✅ Completar',
              UiTokens.neonGreen,
              () => onPick(HabitDayStatus.done),
            ),
            _PickTile(
              '❌ Fallé',
              UiTokens.danger,
              () => onPick(HabitDayStatus.missed),
            ),
            _PickTile(
              '⏭ Skip (sin castigo)',
              UiTokens.textSoft,
              () => onPick(HabitDayStatus.skipped),
            ),
            _PickTile(
              '⏳ Pendiente',
              UiTokens.textSoft,
              () => onPick(HabitDayStatus.pending),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickTile extends StatelessWidget {
  const _PickTile(this.text, this.color, this.onTap);

  final String text;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w800),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}

class _TopWeekHeader extends StatelessWidget {
  const _TopWeekHeader({required this.day});
  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final weekDays = getDynamicWeekDays(day); // Usa el método dinámico
    final weekStart = weekDays.first;
    final weekEnd = weekDays.last;

    return Container(
      decoration: UiTokens.neonCard(),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const Icon(Icons.emoji_events, color: UiTokens.neonBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Semana: ${Time.ymd(weekStart)} → ${Time.ymd(weekEnd)}',
              style: const TextStyle(
                color: UiTokens.textSoft,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

List<DateTime> getDynamicWeekDays(DateTime today) {
  final weekStart = today.subtract(Duration(days: today.weekday - 1)); // Lunes
  final weekDays = List.generate(
    7,
    (index) => weekStart.add(Duration(days: index)),
  );

  // Reorganiza los días para que el día actual esté al final
  final todayIndex = today.weekday - 1; // Índice del día actual (0 = lunes)
  return [
    ...weekDays.sublist(todayIndex + 1), // Días restantes de la semana
    ...weekDays.sublist(0, todayIndex + 1), // Días anteriores al día actual
  ];
}
