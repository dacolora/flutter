import '../../../core/errors.dart';
import '../../../core/result.dart';
import '../../../domain/entities/habit.dart';
import '../../../domain/repositories/habit_repository.dart';

class GetHabits {
  GetHabits(this._repo);
  final HabitRepository _repo;

  Future<Result<List<Habit>>> call() async {
    try {
      final habits = await _repo.getHabits();
      habits.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return Ok(habits);
    } catch (e) {
      return Err(AppError('No se pudieron cargar hábitos', cause: e));
    }
  }
}