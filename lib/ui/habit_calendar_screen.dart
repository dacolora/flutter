import 'package:flutter/material.dart';
import 'package:mylifegame/ui/ui_token.dart';
import '../../core/time.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_log.dart';
import '../infraestructure/service/app_scope.dart';

/// Calendar mensual (heatmap simple por rendimiento diario).
/// Colores:
/// - Verde: buen día
/// - Amarillo: medio
/// - Rojo: bajo
/// - Gris: sin hábitos/logs
class HabitCalendarScreen extends StatefulWidget {
  const HabitCalendarScreen({super.key});

  @override
  State<HabitCalendarScreen> createState() => _HabitCalendarScreenState();
}

class _HabitCalendarScreenState extends State<HabitCalendarScreen> {
  late DateTime _month; // primer día del mes
  bool _loading = true;

  /// dayKey -> score 0..1 (done/due)
  Map<String, double> _dayScore = {};
  /// dayKey -> details
  Map<String, _DayDetail> _details = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month, 1);
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _dayScore = {};
      _details = {};
    });

    final scope = AppScope.of(context);
    final habits = scope.habitController.habits;
    final logs = await scope.habitRepo.getLogsForMonth(_month.year, _month.month);

    // Map habitId -> dayKey -> status
    final Map<String, Map<String, HabitDayStatus>> logMap = {};
    for (final l in logs) {
      logMap.putIfAbsent(l.habitId, () => {})[l.dayKey] = l.status;
    }

    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_month.year, _month.month, day);
      final key = Time.ymd(date);

      int due = 0;
      int done = 0;
      int missed = 0;
      int skipped = 0;

      for (final h in habits) {
        final isDue = h.schedule.isDueOn(Time.isoWeekday(date));
        if (!isDue) continue;

        due++;
        final st = logMap[h.id]?[key] ?? HabitDayStatus.pending;
        if (st == HabitDayStatus.done) done++;
        if (st == HabitDayStatus.missed) missed++;
        if (st == HabitDayStatus.skipped) skipped++;
      }

      if (due == 0) {
        _dayScore[key] = 0;
      } else {
        _dayScore[key] = done / due;
      }

      _details[key] = _DayDetail(
        date: date,
        due: due,
        done: done,
        missed: missed,
        skipped: skipped,
      );
    }

    setState(() => _loading = false);
  }

  void _prevMonth() {
    setState(() => _month = DateTime(_month.year, _month.month - 1, 1));
    _load();
  }

  void _nextMonth() {
    setState(() => _month = DateTime(_month.year, _month.month + 1, 1));
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final title = _monthTitle(_month);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Habits'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  decoration: UiTokens.neonCard(),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: _prevMonth,
                            icon: const Icon(Icons.chevron_left),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                            ),
                          ),
                          IconButton(
                            onPressed: _nextMonth,
                            icon: const Icon(Icons.chevron_right),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const _WeekHeader(),
                      const SizedBox(height: 10),
                      _MonthGrid(
                        month: _month,
                        scoreOf: (dayKey) => _dayScore[dayKey] ?? 0,
                        onTapDay: (dayKey) => _openDayDetails(dayKey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const Text('Tip: toca un día para ver el resumen del rendimiento.', style: TextStyle(color: UiTokens.textSoft)),
              ],
            ),
    );
  }

  Future<void> _openDayDetails(String dayKey) async {
    final d = _details[dayKey];
    if (d == null) return;

    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: UiTokens.card,
      builder: (_) {
        final pct = d.due == 0 ? 0 : (d.done / d.due);
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(dayKey, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            const SizedBox(height: 10),
            Text('Due: ${d.due}', style: const TextStyle(color: UiTokens.textSoft)),
            Text('Done: ${d.done}', style: const TextStyle(color: UiTokens.neonGreen, fontWeight: FontWeight.w800)),
            Text('Missed: ${d.missed}', style: const TextStyle(color: UiTokens.danger, fontWeight: FontWeight.w800)),
            Text('Skipped: ${d.skipped}', style: const TextStyle(color: UiTokens.textSoft)),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(value: pct.toDouble(), minHeight: 10),
            ),
            const SizedBox(height: 6),
            Text('Score: ${(pct * 100).round()}%', style: const TextStyle(color: UiTokens.textSoft)),
          ]),
        );
      },
    );
  }

  String _monthTitle(DateTime month) {
    const names = [
      'January','February','March','April','May','June','July','August','September','October','November','December'
    ];
    return '${names[month.month - 1]} ${month.year}';
  }
}

class _WeekHeader extends StatelessWidget {
  const _WeekHeader();

  @override
  Widget build(BuildContext context) {
    const labels = ['SU', 'MO', 'TU', 'WE', 'TH', 'FR', 'SA'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: labels
          .map((e) => SizedBox(
                width: 36,
                child: Center(
                  child: Text(e, style: const TextStyle(color: UiTokens.textSoft, fontWeight: FontWeight.w900, fontSize: 12)),
                ),
              ))
          .toList(),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.scoreOf,
    required this.onTapDay,
  });

  final DateTime month;
  final double Function(String dayKey) scoreOf;
  final void Function(String dayKey) onTapDay;

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    // Grid start offset based on first day weekday.
    // Dart weekday: Mon=1..Sun=7
    // Queremos grid con SU como primer columna.
    final first = DateTime(month.year, month.month, 1);
    final firstWeekday = first.weekday; // 1..7
    final offset = _sunStartOffset(firstWeekday); // 0..6

    final totalCells = ((offset + daysInMonth) <= 35) ? 35 : 42;

    return Wrap(
      spacing: 8,
      runSpacing: 10,
      children: List.generate(totalCells, (i) {
        final dayNum = i - offset + 1;
        if (dayNum < 1 || dayNum > daysInMonth) {
          return const SizedBox(width: 36, height: 36);
        }

        final date = DateTime(month.year, month.month, dayNum);
        final key = Time.ymd(date);
        final score = scoreOf(key);
        final c = _colorForScore(score);

        return GestureDetector(
          onTap: () => onTapDay(key),
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: c.bg,
              border: Border.all(color: c.border),
            ),
            child: Text(
              '$dayNum',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: c.text,
                fontSize: 12,
              ),
            ),
          ),
        );
      }),
    );
  }

  int _sunStartOffset(int dartWeekday) {
    // dart: Mon=1 Tue=2 ... Sun=7
    // grid: Sun=0 Mon=1 ... Sat=6
    switch (dartWeekday) {
      case 7:
        return 0; // Sun
      case 1:
        return 1; // Mon
      case 2:
        return 2;
      case 3:
        return 3;
      case 4:
        return 4;
      case 5:
        return 5;
      case 6:
        return 6; // Sat
      default:
        return 0;
    }
  }

  _CellColor _colorForScore(double s) {
    // 0 => gris (sin progreso)
    if (s <= 0) {
      return _CellColor(
        bg: UiTokens.card,
        border: UiTokens.borderSoft,
        text: UiTokens.textSoft,
      );
    }

    // heatmap simple
    if (s >= 0.8) {
      return _CellColor(
        bg: UiTokens.neonGreen.withOpacity(0.20),
        border: UiTokens.neonGreen,
        text: UiTokens.neonGreen,
      );
    }
    if (s >= 0.5) {
      // amarillo “gamificado” usando neonBlue + danger mix
      return _CellColor(
        bg: UiTokens.neonBlue.withOpacity(0.18),
        border: UiTokens.neonBlue,
        text: UiTokens.neonBlue,
      );
    }
    return _CellColor(
      bg: UiTokens.danger.withOpacity(0.18),
      border: UiTokens.danger,
      text: UiTokens.danger,
    );
  }
}

class _CellColor {
  _CellColor({required this.bg, required this.border, required this.text});
  final Color bg;
  final Color border;
  final Color text;
}

class _DayDetail {
  _DayDetail({
    required this.date,
    required this.due,
    required this.done,
    required this.missed,
    required this.skipped,
  });

  final DateTime date;
  final int due;
  final int done;
  final int missed;
  final int skipped;
}