import 'package:flutter/material.dart';
import 'package:mylifegame/core/local_storage.dart';
import 'package:mylifegame/infraestructure/data/game_repository_implement.dart';
import 'package:mylifegame/infraestructure/data/habit_repository_implement.dart';
import 'package:mylifegame/infraestructure/data/json_store.dart';
import 'package:mylifegame/infraestructure/service/habit_engine.dart';
import 'package:mylifegame/infraestructure/service/usecase/add_habit.dart';
import 'package:mylifegame/infraestructure/service/usecase/get_habit.dart';
import 'package:mylifegame/infraestructure/service/usecase/toggle_habit_for_day.dart';

import '../../../domain/repositories/game_repository.dart';
import '../../../domain/repositories/habit_repository.dart';
import 'game_controller.dart';
import 'habit_controller.dart';

class AppScope extends StatefulWidget {
  const AppScope({super.key, required this.child});
  final Widget child;

  static AppControllers of(BuildContext context) {
    final inh = context.dependOnInheritedWidgetOfExactType<_AppInherited>();
    assert(inh != null, 'AppScope not found');
    return inh!.controllers;
  }

  @override
  State<AppScope> createState() => _AppScopeState();
}

class _AppScopeState extends State<AppScope> {
  late Future<void> _bootFuture;
  late final AppControllers _controllers;

  @override
  void initState() {
    super.initState();
    _bootFuture = _boot();
  }

  Future<void> _boot() async {
    try {
      final storage = await LocalStorage.create();
      final repo = StorageRepository(storage);
      final lifeAreas = await repo.loadLifeAreas();
      final gameController = GameController(repo,lifeAreas);
      await gameController.init();

      final gameRepo = GameRepositoryImpl(onApply: gameController.apply);

      // Data
      final habitRepo = HabitRepositoryImpl(
        JsonStore(fileName: 'my_life_game_habits.json'),
      );

      // motor en memoria (adapter)
      final engine = HabitEngine();
      final getHabits = GetHabits(habitRepo);
      final addHabit = AddHabit(habitRepo);
      final toggle = ToggleHabitForDay(
        habitRepo: habitRepo,
        gameRepo: gameRepo,
        engine: engine,
      );

      // Presentation controllers
      final habitController = HabitController(
        habitRepo: habitRepo,
        getHabits: getHabits,
        addHabit: addHabit,
        toggleHabitForDay: toggle, lifeAreas: lifeAreas,
      );

      _controllers = AppControllers(
        habitRepo: habitRepo,
        gameRepo: gameRepo,
        gameController: gameController,
        habitController: habitController,
      );

      // load initial
      habitController.load();
    } catch (e, stackTrace) {
      print('Error during boot: $e');
      print(stackTrace);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _bootFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        } else {
          return _AppInherited(
            controllers: _controllers,
            child: widget.child,
          );
        }
      },
    );
  }
}

class _AppInherited extends InheritedWidget {
  const _AppInherited({required this.controllers, required super.child});
  final AppControllers controllers;

  @override
  bool updateShouldNotify(covariant _AppInherited oldWidget) => false;
}

class AppControllers {
  AppControllers({
    required this.habitRepo,
    required this.gameRepo,
    required this.gameController,
    required this.habitController,
  });

  final HabitRepository habitRepo;
  final GameRepository gameRepo;

  final GameController gameController;
  final HabitController habitController;
}