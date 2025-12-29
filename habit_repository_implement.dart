import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_log.dart';
import '../../domain/repositories/habit_repository.dart';
import '../datasources/json_store.dart';

class HabitRepositoryImpl implements HabitRepository {
  HabitRepositoryImpl(this._store);

  final JsonStore _store;

  static const _kHabits = 'habits';
  static const _kLogs = 'logs';

  @override
  Future<List<Habit>> getHabits() async {
    final json = await _store.read();
    final list = (json[_kHabits] as List<dynamic>? ?? []);
    return list.map((e) => Habit.fromJson((e as Map).cast<String, dynamic>())).toList();
  }

  @override
  Future<void> upsertHabit(Habit habit) async {
    final json = await _store.read();
    final list = (json[_kHabits] as List<dynamic>? ?? []).map((e) => (e as Map).cast<String, dynamic>()).toList();

    final idx = list.indexWhere((e) => e['id'] == habit.id);
    if (idx >= 0) {
      list[idx] = habit.toJson();
    } else {
      list.add(habit.toJson());
    }

    json[_kHabits] = list;
    await _store.write(json);
  }

  @override
  Future<void> deleteHabit(String habitId) async {
    final json = await _store.read();
    final list = (json[_kHabits] as List<dynamic>? ?? []).map((e) => (e as Map).cast<String, dynamic>()).toList();
    list.removeWhere((e) => e['id'] == habitId);
    json[_kHabits] = list;
    await _store.write(json);
  }

  @override
  Future<HabitLog?> getLog(String habitId, String dayKey) async {
    final json = await _store.read();
    final list = (json[_kLogs] as List<dynamic>? ?? []).map((e) => (e as Map).cast<String, dynamic>()).toList();
    final found = list.cast<Map<String, dynamic>>().where((e) => e['habitId'] == habitId && e['dayKey'] == dayKey);
    if (found.isEmpty) return null;
    return HabitLog.fromJson(found.first);
  }

  @override
  Future<void> upsertLog(HabitLog log) async {
    final json = await _store.read();
    final list = (json[_kLogs] as List<dynamic>? ?? []).map((e) => (e as Map).cast<String, dynamic>()).toList();

    final idx = list.indexWhere((e) => e['habitId'] == log.habitId && e['dayKey'] == log.dayKey);
    if (idx >= 0) {
      list[idx] = log.toJson();
    } else {
      list.add(log.toJson());
    }

    json[_kLogs] = list;
    await _store.write(json);
  }

  @override
  Future<List<HabitLog>> getLogsForMonth(int year, int month) async {
    final json = await _store.read();
    final list = (json[_kLogs] as List<dynamic>? ?? [])
        .map((e) => HabitLog.fromJson((e as Map).cast<String, dynamic>()))
        .toList();

    final prefix = '$year-${month < 10 ? '0$month' : '$month'}-';
    return list.where((l) => l.dayKey.startsWith(prefix)).toList();
  }
}