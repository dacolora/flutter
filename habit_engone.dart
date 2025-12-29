import '../../core/time.dart';
import '../../domain/entities/action_entry.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_log.dart';

/// Traduce un “click” de habit tracker en:
/// 1) log status
/// 2) action entry para tu motor (HP/XP/Varos).
class HabitEngine {
  /// done => +XP +Varos (+HP opcional)
  ActionEntry buildDoneAction(Habit habit, DateTime day) {
    return ActionEntry.habit(
      title: 'Hábito cumplido: ${habit.title}',
      type: ActionType.goodHabit,
      area: habit.area,
      hpDelta: habit.rewards.hp,
      varosDelta: habit.rewards.varos,
      xpDelta: habit.rewards.xp,
      notes: 'Día: ${Time.ymd(day)}',
    );
  }

  /// missed => -XP (menor que lo ganado) y -HP; varos 0.
  ActionEntry buildMissedAction(Habit habit, DateTime day) {
    return ActionEntry.habit(
      title: 'Hábito fallado: ${habit.title}',
      type: ActionType.badHabit,
      area: habit.area,
      hpDelta: -habit.penalties.hpLoss,
      varosDelta: 0,
      xpDelta: -habit.penalties.xpLoss,
      notes: 'Día: ${Time.ymd(day)}',
    );
  }

  HabitLog buildLog(Habit habit, DateTime day, HabitDayStatus status) {
    return HabitLog.forDay(habitId: habit.id, day: day, status: status);
  }
}