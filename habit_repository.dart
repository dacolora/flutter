import '../entities/habit.dart';
import '../entities/habit_log.dart';

abstract class HabitRepository {
  Future<List<Habit>> getHabits();
  Future<void> upsertHabit(Habit habit);
  Future<void> deleteHabit(String habitId);

  Future<HabitLog?> getLog(String habitId, String dayKey);
  Future<void> upsertLog(HabitLog log);
  Future<List<HabitLog>> getLogsForMonth(int year, int month);
}