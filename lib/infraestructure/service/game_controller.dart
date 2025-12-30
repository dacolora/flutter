import 'package:flutter/material.dart';
import 'package:mylifegame/core/local_storage.dart';
import 'package:mylifegame/domain/entities/action_entry.dart';
import 'package:mylifegame/domain/entities/life_area.dart';
import 'package:mylifegame/domain/repositories/game_repository.dart';
import 'package:mylifegame/models/player_state.dart';
import '../../../core/constants.dart';
import '../../../models/player_state.dart';
import '../../../models/shop_item.dart';



class GameController extends ChangeNotifier {
  GameController(this._repo, this._lifeAreas)
      : xp = {for (final a in _lifeAreas) a: 0}, // Inicializa aquí
        _state = PlayerState.initial(_lifeAreas);


  final StorageRepository _repo;
    final List<LifeArea> _lifeAreas;
   final Map<LifeArea, int> xp;

  PlayerState _state;
  PlayerState get state => _state;
  int hp = 1000;
  int varos = 0;
  bool _loading = true;
  bool get isLoading => _loading;



Future<void> init() async {
  _loading = true;
  notifyListeners();

  // Cargar las áreas de la vida
  final lifeAreas = await _repo.loadLifeAreas();

  // Cargar el estado del jugador
  _state = await _repo.loadPlayerState(lifeAreas);

  _loading = false;
  notifyListeners();
}

Future<void> _persist() async => _repo.savePlayerState(_state);

  int _clampHp(int hp) => hp.clamp(AppConstants.minHp, AppConstants.maxHp);

  // --- Core mechanic: apply action
Future<void> addAction(ActionEntry entry) async {
  // Actualizar HP y varos
  final newHp = _clampHp(_state.hp + entry.hpDelta);
  final newVaros = _state.varos + entry.varosDelta;

  // Actualizar progreso de áreas
  final newAreas = Map<LifeArea, AreaProgress>.from(_state.areas);
  if (entry.area != null && entry.xpDelta != 0) {
    final current = newAreas[entry.area]!;
    final updated = _applyXp(current, entry.xpDelta);
    newAreas[entry.area!] = updated;
  }

  // Actualizar historial
  final newHistory = [entry, ..._state.history];

  // Actualizar el estado
  _state = _state.copyWith(
    hp: newHp,
    varos: newVaros,
    areas: newAreas,
    history: newHistory,
  );

  await _persist();
  notifyListeners();
}
///// DEL PASADO .................

    Future<void> apply(ActionEntry entry) async {
    hp = (hp + entry.hpDelta).clamp(0, 1000);
    varos += entry.varosDelta;

    if (entry.area != null) {
      xp[entry.area!] = (xp[entry.area!] ?? 0) + entry.xpDelta;
      if (xp[entry.area!]! < 0) xp[entry.area!] = 0;
    }
    notifyListeners();
  }

  ///// DEL PASADO FIN .................

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
  

  void updateAreaXp(LifeArea area, int xpDelta) {
  final currentProgress = _state.areas[area];
  if (currentProgress != null) {
    final updatedProgress = _applyXp(currentProgress, xpDelta);
    _state = _state.copyWith(
      areas: {
        ..._state.areas,
        area: updatedProgress,
      },
    );
    notifyListeners(); // Notifica a los widgets que escuchan este controlador
  }
}

  // --- Shop
  Future<void> buyItem(ShopItem item) async {
    if (_state.varos < item.costVaros) return;

    final entry = ActionEntry.habit(
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
      final entry = ActionEntry.habit(
        title: 'REVIVIR ÉPICO (cumplido)',
        type: ActionType.revive,
        hpDelta: AppConstants.maxHp,
        varosDelta: 0,
        xpDelta: 0,
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
      final newLevel = (p.level - 1).clamp(
        AppConstants.minLevel,
        AppConstants.maxLevel,
      );
      newAreas[p.area] = p.copyWith(level: newLevel, xpInLevel: 0);
    }

    _state = _state.copyWith(
      hp: 400,
      varos: _state.varos - 500,
      areas: newAreas,
    );

    final entry = ActionEntry.habit(
      title: 'REVIVIR COSTOSO (penalizado)',
      type: ActionType.revive,
      hpDelta: 0,
      varosDelta: 0,
      notes: 'HP=400, -500 varos, -1 nivel en 3 áreas más bajas.',
      xpDelta: 0,
    );

    await addAction(entry);
  }

Future<void> resetAll() async {
  await _repo.reset();
  _state = PlayerState.initial(_lifeAreas);
  await _persist();
  notifyListeners();
}
}

// // --- Scope (simple DI)
// class GameControllerScope extends StatefulWidget {
//   const GameControllerScope({super.key, required this.child});
//   final Widget child;

//   static GameController of(BuildContext context) {
//     final inherited = context
//         .dependOnInheritedWidgetOfExactType<_GameInherited>();
//     assert(inherited != null, 'GameControllerScope not found');
//     return inherited!.controller;
//   }

//   @override
//   State<GameControllerScope> createState() => _GameControllerScopeState();
// }

// class _GameControllerScopeState extends State<GameControllerScope> {
//   GameController? _controller;

//   @override
//   void initState() {
//     super.initState();
//     _boot();
//   }

//   Future<void> _boot() async {
//     final storage = await LocalStorage.create();
//     final repo = StorageRepository(storage);
//     final controller = GameController(repo);
//     await controller.init();
//     setState(() => _controller = controller);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final controller = _controller;
//     if (controller == null) {
//       return const MaterialApp(
//         home: Scaffold(body: Center(child: CircularProgressIndicator())),
//       );
//     }

//     return _GameInherited(
//       controller: controller,
//       child: AnimatedBuilder(
//         animation: controller,
//         builder: (_, __) => widget.child,
//       ),
//     );
//   }
// }

// class _GameInherited extends InheritedWidget {
//   const _GameInherited({required this.controller, required super.child});

//   final GameController controller;

//   @override
//   bool updateShouldNotify(covariant _GameInherited oldWidget) =>
//       controller != oldWidget.controller;
// }
