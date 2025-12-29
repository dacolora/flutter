import '../../../core/errors.dart';
import '../../../core/result.dart';
import '../../../domain/entities/habit.dart';
import '../../../domain/repositories/habit_repository.dart';

class AddHabit {
  AddHabit(this._repo);
  final HabitRepository _repo;

  Future<Result<void>> call(Habit habit) async {
    try {
      await _repo.upsertHabit(habit);
      return const Ok(null);
    } catch (e) {
      return Err(AppError('No se pudo crear hábito', cause: e));
    }
  }
}