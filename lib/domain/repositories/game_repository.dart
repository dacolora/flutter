import 'package:mylifegame/core/local_storage.dart';
import 'package:mylifegame/domain/entities/action_entry.dart';
import 'package:mylifegame/domain/entities/life_area.dart';
import 'package:mylifegame/models/player_state.dart';

abstract class GameRepository {
  Future<void> apply(ActionEntry entry);
}

class StorageRepository {
  final LocalStorage _storage;

  StorageRepository(this._storage);

  Future<List<LifeArea>> loadLifeAreas() async {
    return LifeAreaRepository.defaultLifeAreas();
  }

  Future<PlayerState> loadPlayerState(List<LifeArea> lifeAreas) async {
    final data = await _storage.read('player_state');
    if (data == null) {
      return PlayerState.initial(lifeAreas);
    }
    return PlayerState.fromJson(data as Map<String, dynamic>, lifeAreas);
  }

  Future<void> savePlayerState(PlayerState state) async {
    await _storage.write('player_state', state.toJson());
  }

  Future<void> reset() async {
    await _storage.clear();
  }
}
