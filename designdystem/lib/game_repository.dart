import '../core/storage/local_storage.dart';
import '../models/player_state.dart';

class GameRepository {
  GameRepository(this._storage);

  final LocalStorage _storage;

  static const _key = 'life_rpg_state_v1';

  Future<PlayerState> load() async {
    final json = _storage.getJson(_key);
    if (json == null) return PlayerState.initial();
    return PlayerState.fromJson(json);
  }

  Future<void> save(PlayerState state) async {
    await _storage.setJson(_key, state.toJson());
  }

  Future<void> reset() async {
    await _storage.remove(_key);
  }
}