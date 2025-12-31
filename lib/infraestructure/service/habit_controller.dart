import 'package:flutter/foundation.dart';
import 'package:mylifegame/domain/entities/life_area.dart';
import 'package:mylifegame/infraestructure/habit_state_controller.dart';
import 'package:mylifegame/infraestructure/service/usecase/add_habit.dart';
import 'package:mylifegame/infraestructure/service/usecase/get_habit.dart';
import 'package:mylifegame/infraestructure/service/usecase/toggle_habit_for_day.dart';

import '../../../core/time.dart';
import '../../../domain/entities/habit.dart';
import '../../../domain/entities/habit_log.dart';
import '../../../domain/repositories/habit_repository.dart';

/// Estado para UI (lista + logs cacheados por semana).
class HabitController extends ChangeNotifier {
  HabitController({
    required HabitStateController habitStateController,
    required HabitRepository habitRepo,
    required GetHabits getHabits,
    required AddHabit addHabit,
    required ToggleHabitForDay toggleHabitForDay,
    required this.lifeAreas,
  }) : _stateController = habitStateController,
       _repo = habitRepo,
       _getHabits = getHabits,
       _addHabit = addHabit,
       _toggle = toggleHabitForDay;

  final HabitRepository _repo;
  final HabitStateController _stateController;

  final GetHabits _getHabits;
  final AddHabit _addHabit;
  final ToggleHabitForDay _toggle;
  final List<LifeArea> lifeAreas;
  final List<HabitLog> _logs = [];

  bool loading = false;
  String? error;

  List<Habit> habits = [];

  /// cache: habitId -> dayKey -> status
  final Map<String, Map<String, HabitDayStatus>> _weekCache = {};

  DateTime get today => Time.startOfDay(DateTime.now());

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();

    final res = await _getHabits(lifeAreas); // Pasa la lista de áreas aquí
    res.when(
      ok: (list) async {
        habits = list.where((h) => h.isActive).toList();

        // Cargar los logs de los hábitos
        _logs.clear();
        for (final habit in habits) {
          final logs = await _stateController.getLogsForHabit(habit.id);
          _logs.addAll(logs);
        }

        await _warmWeekCache();
        loading = false;
        notifyListeners();
      },
      err: (e) {
        error = e.message;
        loading = false;
        notifyListeners();
      },
    );
  }

  Map<DateTime, HabitDayStatus> getYearlyStatus(String habitId, int year) {
    final Map<DateTime, HabitDayStatus> yearlyStatus = {};
    for (int month = 1; month <= 12; month++) {
      final daysInMonth = getDaysInMonth(year, month);
      for (final day in daysInMonth) {
        yearlyStatus[day] = getStatusForDay(
          habitId,
          day,
        ); // Obtén el estado del día
      }
    }
    return yearlyStatus;
  }

  List<DateTime> getDaysInMonth(int year, int month) {
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0); // Último día del mes
    return List.generate(
      lastDay.day,
      (index) => DateTime(year, month, index + 1),
    );
  }

  HabitDayStatus getStatusForDay(String habitId, DateTime day) {
    // Obtén el estado del día desde los logs o devuelve un estado predeterminado
    final dayKey = Time.ymd(day);
    return _logs
        .firstWhere(
          (log) => log.habitId == habitId && log.dayKey == dayKey,
          orElse: () => HabitLog.forDay(habitId: habitId, day: day),
        )
        .status;
  }

  Future<void> createHabit(Habit habit) async {
    final res = await _addHabit(habit);
    res.when(
      ok: (_) => load(),
      err: (e) {
        error = e.message;
        notifyListeners();
      },
    );
  }

  /// Week view helpers
  List<DateTime> weekDaysFrom(DateTime day) {
    final base = Time.startOfDay(day);
    final monday = base.subtract(Duration(days: base.weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

HabitDayStatus statusOf(String habitId, DateTime day) {
  return _stateController.getStatusForDay(habitId, day);
}

 void setStatus(Habit habit, DateTime day, HabitDayStatus status) {
  final dayKey = Time.ymd(day);

  // Actualiza el estado en memoria
  _stateController.updateLog(
    HabitLog.forDay(
      habitId: habit.id,
      day: day,
      status: status,
    ),
  );

  // Persistir el cambio en el repositorio
  _repo.upsertLog(
    HabitLog.forDay(
      habitId: habit.id,
      day: day,
      status: status,
    ),
  );
    final habitIndex = habits.indexWhere((h) => h.id == habit.id);
  if (habitIndex != -1) {
    habits[habitIndex] = habit.copyWith(
      // Actualiza cualquier campo necesario en el hábito
    );
  }
  print('Estado actualizado: $habit, Día: $day, Estado: $status');

  notifyListeners(); // Notifica a la UI para que se actualice
}

  Future<void> _warmWeekCache() async {
    _weekCache.clear();
    final days = weekDaysFrom(today);

    for (final h in habits) {
      _weekCache[h.id] = {};
      for (final d in days) {
        final key = Time.ymd(d);
        final log = await _repo.getLog(h.id, key);
        _weekCache[h.id]![key] = log?.status ?? HabitDayStatus.pending;
      }
    }
  }
}
