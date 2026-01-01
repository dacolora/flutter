import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mylifegame/domain/entities/life_area.dart';
import 'package:mylifegame/infraestructure/habit_state_controller.dart';
import 'package:mylifegame/infraestructure/service/usecase/add_habit.dart';
import 'package:mylifegame/infraestructure/service/usecase/get_habit.dart';
import 'package:mylifegame/infraestructure/service/usecase/toggle_habit_for_day.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

int calculateTotalRewards(String habitId) {
  final logs = _stateController.getLogsForHabit(habitId); // Obtén los logs del hábito
  final habit = habits.firstWhere((h) => h.id == habitId); // Obtén el hábito correspondiente

  return logs.fold(0, (sum, log) {
    if (log.status == HabitDayStatus.done) {
      return sum + habit.rewards.xp; // Usa los rewards del hábito
    }
     if (log.status == HabitDayStatus.missed) {
      return sum - habit.penalties.xpLoss; // Usa los rewards del hábito
    }
    return sum;
  });
}

int calculateTotalRewardsByArea(LifeArea area) {
  int totalRewards = 0;

  // Filtra los hábitos asociados al área
  final areaHabits = habits.where((habit) => habit.area == area).toList();

  for (final habit in areaHabits) {
    // Obtén los logs del hábito
    final logs = _stateController.getLogsForHabit(habit.id);

    // Suma los XP de los días completados
    for (final log in logs) {
      if (log.status == HabitDayStatus.done) {
        totalRewards += habit.rewards.xp;
      }
            if (log.status == HabitDayStatus.missed) {
        totalRewards -= habit.penalties.xpLoss;
      }
    }
  }

  return totalRewards;
}

int calculateHPCOMPLETE() {
  int totalHP = 100; // HP inicial

  for (final log in _logs) {
    final habit = habits.firstWhere((h) => h.id == log.habitId, );
    if (habit != null) {
      if (log.status == HabitDayStatus.done) {
        totalHP += habit.rewards.hp; // Suma HP por hábitos completados
      } else if (log.status == HabitDayStatus.missed) {
        totalHP -= habit.penalties.hpLoss; // Resta HP por hábitos fallidos
      }
    }
  }

  return totalHP;
}

int calculateVarosCOMPLETE() {
  int totalVaros = 0;

  for (final log in _logs) {
 
      final habit = habits.firstWhere((h) => h.id == log.habitId);
    
        totalVaros += habit.rewards.varos;
      
    
  }

  return totalVaros;
}


void deleteHabit(String habitId) async {
  habits.removeWhere((habit) => habit.id == habitId); // Elimina el hábito de la lista
  await _saveHabitsToSharedPreferences(); // Guarda los cambios en SharedPreferences
  notifyListeners(); // Notifica a la UI para que se redibuje
}
  Future<void> createHabit(Habit habit) async {
    habits.add(habit); // Agrega el hábito a la lista en memoria
    await _saveHabitsToSharedPreferences(); // Guarda los hábitos en SharedPreferences
    notifyListeners(); // Notifica a la UI para que se redibuje
  }

  Future<void> _saveHabitsToSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final habitsJson = habits.map((habit) => habit.toJson()).toList();
    await prefs.setString('habits', jsonEncode(habitsJson));
    print('Hábitos guardados: $habitsJson');
  }

  Future<void> loadHabitsFromSharedPreferences(playerState) async {
    final prefs = await SharedPreferences.getInstance();
    final habitsJson = prefs.getString('habits');
    if (habitsJson != null) {
      final List<dynamic> decoded = jsonDecode(habitsJson);
      habits.clear();
      habits.addAll(decoded.map((json) => Habit.fromJson(json,lifeAreas)).toList());
    }
          playerState.updateAreaProgress(habits);
  }


void updateHabit(Habit updatedHabit) {
  final index = habits.indexWhere((h) => h.id == updatedHabit.id);
  if (index != -1) {
    habits[index] = updatedHabit; // Actualiza el hábito en la lista
    saveHabits(); // Guarda los cambios en el almacenamiento persistente
    notifyListeners(); // Notifica a la UI para que se redibuje
  }
}

Future<void> saveHabits() async {
  final prefs = await SharedPreferences.getInstance();
  final habitsJson = habits.map((habit) => habit.toJson()).toList();
  await prefs.setString('habits', jsonEncode(habitsJson));
  print('Hábitos guardados: $habitsJson');
}


int calculateTotalHP(String habitId) {
  final logs = _stateController.getLogsForHabit(habitId); // Obtén los logs del hábito
  final habit = habits.firstWhere((h) => h.id == habitId); // Obtén el hábito correspondiente

  return logs.fold(0, (sum, log) {
    if (log.status == HabitDayStatus.done) {
      return sum + habit.rewards.hp; // Usa los rewards del hábito
    }
        if (log.status == HabitDayStatus.missed) {
      return sum + habit.penalties.hpLoss; // Usa los rewards del hábito
    }
    return sum;
  });
}
int calculateTotalVaros(String habitId) {
  final logs = _stateController.getLogsForHabit(habitId); // Obtén los logs del hábito
  final habit = habits.firstWhere((h) => h.id == habitId); // Obtén el hábito correspondiente

  return logs.fold(0, (sum, log) {
    if (log.status == HabitDayStatus.done) {
      return sum + habit.rewards.varos; // Usa los rewards del hábito
    }
    return sum;
  });
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
