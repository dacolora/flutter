import 'package:mylifegame/domain/entities/habit.dart';
import 'package:mylifegame/domain/entities/habit_log.dart';
import 'package:mylifegame/domain/entities/life_area.dart';

abstract class HabitRepository {
  Future<List<Habit>> getHabits(List<LifeArea> lifeAreas);
  Future<void> upsertHabit(Habit habit);
  Future<void> deleteHabit(String habitId);

  Future<HabitLog?> getLog(String habitId, String dayKey);
  Future<void> upsertLog(HabitLog log);
  Future<List<HabitLog>> getLogsForMonth(int year, int month);
}