import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mylifegame/domain/entities/habit_log.dart';
import 'package:mylifegame/ui/ui_token.dart';

enum DayStatus {
  success, // verde
  fail, // rojo
  skipped, // gris oscuro
  none, // sin data (gris claro)
}

class HabitsMonthScreen extends StatefulWidget {
  final List<DateTime> day;
  final HabitDayStatus Function(DateTime day) statusOf;
  const HabitsMonthScreen({
    super.key,
    required this.statusOf,
    required this.day,
  });

  @override
  State<HabitsMonthScreen> createState() => _HabitsMonthScreenState();
}

class _HabitsMonthScreenState extends State<HabitsMonthScreen> {
  // Mes actualmente visible
  DateTime _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);

  // Ejemplo de data (puedes reemplazar por tu storage/backend)
  // key: DateTime(y,m,d) (solo fecha)

  static const _teal = Color(0xFF1C93A8);

  @override
  Widget build(BuildContext context) {
    final monthTitle = DateFormat('MMMM yyyy').format(_visibleMonth);
    final days = _buildCalendarCells(_visibleMonth);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _teal,
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
            onPressed: () {},
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(
                    Icons.emoji_events,
                    size: 20,
                    color: Colors.black87,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Streak: +0  |  Overall: 31%  |  2 Friends',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),

            // Navegación de mes
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.chevron_left,
                      size: 28,
                      color: Colors.black54,
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
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(
                      Icons.chevron_right,
                      size: 28,
                      color: Colors.black54,
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
                  _DowCell('Do'),
                  _DowCell('MO'),
                  _DowCell('TU'),
                  _DowCell('WE'),
                  _DowCell('TH'),
                  _DowCell('FR'),
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
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                    final status = isInMonth
                        ? widget.statusOf(
                            cell,
                          ) // Usa el estado directamente desde `widget.statusOf`
                        : HabitDayStatus.pending;

                    return _DayCircle(
                      day: cell,
                      statusOf: widget.statusOf,
                      isInMonth: isInMonth,
                      onTap: isInMonth
                          ? () {
                              // Aquí puedes abrir detalle, comentarios, etc.
                              print('Tapped: $cell');
                            }
                          : null,
                    );
                  },
                ),
              ),
            ),

            const Divider(height: 1),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'No Comments',
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
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
            color: Colors.black54,
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

print('Day: $day, Status: ${statusOf(day)}');
    

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
