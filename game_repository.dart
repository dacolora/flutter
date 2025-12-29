import '../entities/action_entry.dart';

abstract class GameRepository {
  Future<void> apply(ActionEntry entry);
}