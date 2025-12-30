import 'package:mylifegame/infraestructure/service/habit_engine.dart';

import '../../../../../core/result.dart';
import '../../../../../core/errors.dart';
import '../../../../../core/time.dart';
import '../../../../../domain/entities/habit.dart';
import '../../../../../domain/entities/habit_log.dart';
import '../../../../../domain/repositories/habit_repository.dart';
import '../../../../../domain/repositories/game_repository.dart';

class ToggleHabitForDay {
  ToggleHabitForDay({
    required HabitRepository habitRepo,
    required GameRepository gameRepo,
    required HabitEngine engine,
  })  : _habitRepo = habitRepo,
        _gameRepo = gameRepo,
        _engine = engine;

  final HabitRepository _habitRepo;
  final GameRepository _gameRepo;
  final HabitEngine _engine;

  /// status: done/missed/skipped/pending
  Future<Result<void>> call({
    required Habit habit,
    required DateTime day,
    required HabitDayStatus status,
  }) async {
    try {
      final dayKey = Time.ymd(day);

      // 1) persist log
      final log = _engine.buildLog(habit, day, status);
      await _habitRepo.upsertLog(log);

      // 2) generate action to game engine (only for done/missed)
      if (status == HabitDayStatus.done) {
        await _gameRepo.apply(_engine.buildDoneAction(habit, day));
      } else if (status == HabitDayStatus.missed) {
        await _gameRepo.apply(_engine.buildMissedAction(habit, day));
      }

      return const Ok(null);
    } catch (e) {
      return Err(AppError('No se pudo togglear hábito', cause: e));
    }
  }
}