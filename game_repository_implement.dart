import '../../domain/entities/action_entry.dart';
import '../../domain/repositories/game_repository.dart';

/// Aquí conectas con tu motor actual.
/// Por ahora lo dejamos como “adapter” para que lo enchufes a tu GameController real.
class GameRepositoryImpl implements GameRepository {
  GameRepositoryImpl({required this.onApply});

  final Future<void> Function(ActionEntry entry) onApply;

  @override
  Future<void> apply(ActionEntry entry) => onApply(entry);
}