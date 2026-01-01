import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mylifegame/domain/entities/habit.dart';
import 'package:mylifegame/domain/entities/habit_log.dart';
import 'package:mylifegame/infraestructure/service/app_scope.dart';
import 'package:mylifegame/ui/habit_add_screen.dart';
import 'package:mylifegame/ui/habit_edit_screen.dart';
import 'package:mylifegame/ui/ui_token.dart';
import 'package:mylifegame/ui/xp_varos_pills.dart';

enum DayStatus {
  success, // verde
  fail, // rojo
  skipped, // gris oscuro
  none, // sin data (gris claro)
}

class HabitsMonthScreen extends StatefulWidget {
  final List<DateTime> day;
  final HabitDayStatus Function(DateTime day) statusOf;
  final Function(DateTime) onTapDay;
  final String habitId;
  final Habit habit;
  const HabitsMonthScreen({
    super.key,
    required this.statusOf,
    required this.day,
    required this.onTapDay,
    required this.habit,
    required this.habitId,
  });

  @override
  State<HabitsMonthScreen> createState() => _HabitsMonthScreenState();
}

class _HabitsMonthScreenState extends State<HabitsMonthScreen> {
  // Mes actualmente visible
  DateTime _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);

  // Ejemplo de data (puedes reemplazar por tu storage/backend)
  // key: DateTime(y,m,d) (solo fecha)

  @override
  Widget build(BuildContext context) {
    final monthTitle = DateFormat('MMMM yyyy').format(_visibleMonth);
    final days = _buildCalendarCells(_visibleMonth);
    final habits = AppScope.of(context).habitController;
    final totalRewards = habits.calculateTotalRewards(widget.habitId);
    final totalHP = habits.calculateTotalHP(widget.habitId);
    final totalVaros = habits.calculateTotalVaros(widget.habitId);

    return AnimatedBuilder(
      animation: habits,
      builder: (context, asyncSnapshot) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            foregroundColor: Colors.white,
            backgroundColor: Colors.black,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              'Progreso de Habito',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () => Navigator.maybePop(context),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HabitEditScreen(habit: widget.habit),
                    ),
                  );
                },
                child: const Text(
                  'Edit',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),
                Text(
                  'Segun la dificultad del habito esto son los atributos obtenidos por dia cumplido o fallido',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                  Text(
                   'Dificultad: ${difficultyLabel(widget.habit.difficulty)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                     const SizedBox(height: 10),

                XpVarosPills(
                  xp: widget.habit.rewards.xp,
                  varos: widget.habit.rewards.varos,
                  hp: widget.habit.rewards.hp,
                  xpLoss: widget.habit.penalties.xpLoss,
                  hpLoss: widget.habit.penalties.hpLoss,
                ),
                const SizedBox(height: 10),
                const SizedBox(height: 12),
                const Divider(height: 1),

                // Navegación de mes
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.chevron_left,
                          size: 28,
                          color: Colors.white,
                        ),
                        onPressed: () => setState(() {
                          _visibleMonth = DateTime(
                            _visibleMonth.year,
                            _visibleMonth.month - 1,
                          );
                        }),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _capitalize(monthTitle),
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          Icons.chevron_right,

                          size: 28,
                          color: Colors.white,
                        ),
                        onPressed: () => setState(() {
                          _visibleMonth = DateTime(
                            _visibleMonth.year,
                            _visibleMonth.month + 1,
                          );
                        }),
                      ),
                    ],
                  ),
                ),

                // Header días
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: const [
                      _DowCell('DO'),
                      _DowCell('LU'),
                      _DowCell('MA'),
                      _DowCell('MI'),
                      _DowCell('JU'),
                      _DowCell('VI'),
                      _DowCell('SA'),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                // Calendario
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: GridView.builder(
                      padding: const EdgeInsets.only(top: 4),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 1,
                          ),
                      itemCount: days.length,
                      itemBuilder: (context, index) {
                        final cell = days[index];
                        if (cell == null) {
                          return const SizedBox.shrink();
                        }

                        final isInMonth = cell.month == _visibleMonth.month;

                        return _DayCircle(
                          day: cell,
                          statusOf: widget.statusOf,
                          isInMonth: isInMonth,
                          onTap: isInMonth
                              ? () {
                                  setState(() {
                                    widget.onTapDay(cell);
                                  });
                                }
                              : null,
                        );
                      },
                    ),
                  ),
                ),
                Text(
                  'Total del Habito',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Divider(height: 1),
                const SizedBox(height: 10),

                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Experiencia : $totalRewards XP',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Vida : $totalHP HP',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Varos : $totalVaros Varos',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Construye un calendario estilo “mes” iniciando en domingo.
  /// Devuelve lista de 42 celdas (6 semanas), cada celda es DateTime o null.
  List<DateTime?> _buildCalendarCells(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    // weekday en Dart: Mon=1..Sun=7
    // Queremos Sunday=0..Saturday=6
    final firstWeekdaySundayBased = firstDay.weekday % 7; // Sun->0, Mon->1, ...

    final cells = List<DateTime?>.filled(42, null);

    // días del mes anterior para rellenar inicio
    final prevMonthLastDay = DateTime(month.year, month.month, 0);
    final prevMonthDays = prevMonthLastDay.day;

    // Llenar primeros offsets con días previos
    for (int i = 0; i < firstWeekdaySundayBased; i++) {
      final day = prevMonthDays - (firstWeekdaySundayBased - 1 - i);
      cells[i] = DateTime(prevMonthLastDay.year, prevMonthLastDay.month, day);
    }

    // Llenar días del mes
    int cursor = firstWeekdaySundayBased;
    for (int d = 1; d <= daysInMonth; d++) {
      cells[cursor++] = DateTime(month.year, month.month, d);
    }

    // Llenar resto con días del siguiente mes
    final nextMonth = DateTime(month.year, month.month + 1, 1);
    int nd = 1;
    while (cursor < cells.length) {
      cells[cursor++] = DateTime(nextMonth.year, nextMonth.month, nd++);
    }

    return cells;
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}

class _DowCell extends StatelessWidget {
  final String text;
  const _DowCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _DayCircle extends StatelessWidget {
  final DateTime day;
  final HabitDayStatus Function(DateTime day) statusOf;
  final bool isInMonth;
  final VoidCallback? onTap;

  const _DayCircle({
    required this.day,
    required this.statusOf,
    required this.isInMonth,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!isInMonth) {
      // Ocultar días fuera del mes
      return const SizedBox.shrink();
    }

    final status = statusOf(day);
    final fg = Colors.white;

    final (bg, border) = _colors(status);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: Border.all(color: border),
        ),
        alignment: Alignment.center,
        child: Text(
          '${day.day}',
          style: TextStyle(
            fontSize: 14,
            color: fg,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
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
}
