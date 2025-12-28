import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/storage/local_storage.dart';
import '../models/action_entry.dart';
import '../models/area.dart';
import '../models/player_state.dart';
import '../models/shop_item.dart';
import '../repositories/game_repository.dart';

class GameController extends ChangeNotifier {
  GameController(this._repo);

  final GameRepository _repo;

  PlayerState _state = PlayerState.initial();
  PlayerState get state => _state;

  bool _loading = true;
  bool get isLoading => _loading;

  Future<void> init() async {
    _loading = true;
    notifyListeners();
    _state = await _repo.load();
    _loading = false;
    notifyListeners();
  }

  Future<void> _persist() async => _repo.save(_state);

  int _clampHp(int hp) => hp.clamp(AppConstants.minHp, AppConstants.maxHp);

  // --- Core mechanic: apply action
  Future<void> addAction(ActionEntry entry) async {
    // Update HP / varos
    final newHp = _clampHp(_state.hp + entry.hpDelta);
    final newVaros = (_state.varos + entry.varosDelta);

    // Update area progress (if area exists and xpDelta != 0)
    final newAreas = Map<LifeArea, AreaProgress>.from(_state.areas);
    if (entry.area != null && entry.xpDelta != 0) {
      final current = newAreas[entry.area]!;
      final updated = _applyXp(current, entry.xpDelta);
      newAreas[entry.area!] = updated;
    }

    final newHistory = [entry, ..._state.history];
    _state = _state.copyWith(hp: newHp, varos: newVaros, areas: newAreas, history: newHistory);

    await _persist();
    notifyListeners();
  }

  AreaProgress _applyXp(AreaProgress progress, int xpDelta) {
    var level = progress.level;
    var xpInLevel = progress.xpInLevel + xpDelta;

    // Negative XP? allow but don't go under 0 in level
    if (xpInLevel < 0) xpInLevel = 0;

    // Level up
    while (level < AppConstants.maxLevel) {
      final need = AppConstants.xpToNextLevel(level);
      if (xpInLevel >= need) {
        xpInLevel -= need;
        level += 1;
      } else {
        break;
      }
    }

    // If max level, cap xpInLevel
    if (level == AppConstants.maxLevel) {
      xpInLevel = 0;
    }

    return progress.copyWith(level: level, xpInLevel: xpInLevel);
  }

  // --- Shop
  Future<void> buyItem(ShopItem item) async {
    if (_state.varos < item.costVaros) return;

    final entry = ActionEntry.create(
      title: 'Compra: ${item.title}',
      type: ActionType.shopPurchase,
      hpDelta: item.hpDelta,
      varosDelta: -item.costVaros,
      xpDelta: 0,
      notes: item.notes,
    );
    await addAction(entry);
  }

  // --- Revive (hardcore rule)
  /// reviveType:
  /// - "epic": you completed the epic revive (e.g. 50km<24h) => full HP
  /// - "costly": revive with penalties
  Future<void> revive({required String reviveType}) async {
    if (!_state.isDead) return;

    if (reviveType == 'epic') {
      final entry = ActionEntry.create(
        title: 'REVIVIR ÉPICO (cumplido)',
        type: ActionType.revive,
        hpDelta: AppConstants.maxHp,
        varosDelta: 0,
      );
      // set hp directly to max: use delta big enough:
      _state = _state.copyWith(hp: AppConstants.maxHp);
      await addAction(entry);
      return;
    }

    // costly revive: set hp to 400, varos -500, and drop 1 level from 3 areas (worst ones)
    final newAreas = Map<LifeArea, AreaProgress>.from(_state.areas);
    final sorted = newAreas.values.toList()
      ..sort((a, b) {
        if (a.level != b.level) return a.level.compareTo(b.level);
        return a.xpInLevel.compareTo(b.xpInLevel);
      });

    for (var i = 0; i < 3 && i < sorted.length; i++) {
      final p = sorted[i];
      final newLevel = (p.level - 1).clamp(AppConstants.minLevel, AppConstants.maxLevel);
      newAreas[p.area] = p.copyWith(level: newLevel, xpInLevel: 0);
    }

    _state = _state.copyWith(
      hp: 400,
      varos: _state.varos - 500,
      areas: newAreas,
    );

    final entry = ActionEntry.create(
      title: 'REVIVIR COSTOSO (penalizado)',
      type: ActionType.revive,
      hpDelta: 0,
      varosDelta: 0,
      notes: 'HP=400, -500 varos, -1 nivel en 3 áreas más bajas.',
    );

    await addAction(entry);
  }

  Future<void> resetAll() async {
    await _repo.reset();
    _state = PlayerState.initial();
    await _persist();
    notifyListeners();
  }
}

// --- Scope (simple DI)
class GameControllerScope extends StatefulWidget {
  const GameControllerScope({super.key, required this.child});
  final Widget child;

  static GameController of(BuildContext context) {
    final inherited = context.dependOnInheritedWidgetOfExactType<_GameInherited>();
    assert(inherited != null, 'GameControllerScope not found');
    return inherited!.controller;
  }

  @override
  State<GameControllerScope> createState() => _GameControllerScopeState();
}

class _GameControllerScopeState extends State<GameControllerScope> {
  GameController? _controller;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final storage = await LocalStorage.create();
    final repo = GameRepository(storage);
    final controller = GameController(repo);
    await controller.init();
    setState(() => _controller = controller);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) {
      return const MaterialApp(home: Scaffold(body: Center(child: CircularProgressIndicator())));
    }

    return _GameInherited(
      controller: controller,
      child: AnimatedBuilder(
        animation: controller,
        builder: (_, __) => widget.child,
      ),
    );
  }
}

class _GameInherited extends InheritedWidget {
  const _GameInherited({required this.controller, required super.child});

  final GameController controller;

  @override
  bool updateShouldNotify(covariant _GameInherited oldWidget) => controller != oldWidget.controller;
}