import 'package:flutter/foundation.dart';
import 'package:mylifegame/domain/entities/life_area.dart';
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
    required HabitRepository habitRepo,
    required GetHabits getHabits,
    required AddHabit addHabit,
    required ToggleHabitForDay toggleHabitForDay,
    required this.lifeAreas,
  })  : _repo = habitRepo,
        _getHabits = getHabits,
        _addHabit = addHabit,
        _toggle = toggleHabitForDay;

  final HabitRepository _repo;
  final GetHabits _getHabits;
  final AddHabit _addHabit;
  final ToggleHabitForDay _toggle;
  final List<LifeArea> lifeAreas; 

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
      print('Hábitos cargados: ${list.length}');
      habits = list.where((h) => h.isActive).toList();
      await _warmWeekCache();
      loading = false;
      notifyListeners();
    },
    err: (e) {
      print('Error al cargar los hábitos: ${e.message}');
      error = e.message;
      loading = false;
      notifyListeners();
    },
  );
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
    final key = Time.ymd(day);
    return _weekCache[habitId]?[key] ?? HabitDayStatus.pending;
  }

  Future<void> setStatus(Habit habit, DateTime day, HabitDayStatus status) async {
    final res = await _toggle(habit: habit, day: day, status: status);
    res.when(
      ok: (_) async {
        _weekCache.putIfAbsent(habit.id, () => {})[Time.ymd(day)] = status;
        notifyListeners();
      },
      err: (e) {
        error = e.message;
        notifyListeners();
      },
    );
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