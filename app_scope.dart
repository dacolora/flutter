import 'package:flutter/material.dart';

import '../../application/services/habit_engine.dart';
import '../../application/usecases/habits/add_habit.dart';
import '../../application/usecases/habits/get_habits.dart';
import '../../application/usecases/habits/toggle_habit_for_day.dart';
import '../../data/datasources/json_store.dart';
import '../../data/repositories/game_repository_impl.dart';
import '../../data/repositories/habit_repository_impl.dart';
import '../../domain/repositories/game_repository.dart';
import '../../domain/repositories/habit_repository.dart';
import 'game_controller.dart';
import 'habit_controller.dart';

/// AppScope: composición manual (DI) sin librerías externas.
/// - Monta repos
/// - monta usecases
/// - monta controllers
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
  late final AppControllers _controllers;

  @override
  void initState() {
    super.initState();

    // Data
    final habitRepo = HabitRepositoryImpl(JsonStore(fileName: 'my_life_game_habits.json'));
    final gameController = GameController(); // motor en memoria (adapter)
    final gameRepo = GameRepositoryImpl(onApply: gameController.apply);

    // Application
    final engine = HabitEngine();
    final getHabits = GetHabits(habitRepo);
    final addHabit = AddHabit(habitRepo);
    final toggle = ToggleHabitForDay(habitRepo: habitRepo, gameRepo: gameRepo, engine: engine);

    // Presentation controllers
    final habitController = HabitController(
      habitRepo: habitRepo,
      getHabits: getHabits,
      addHabit: addHabit,
      toggleHabitForDay: toggle,
    );

    _controllers = AppControllers(
      habitRepo: habitRepo,
      gameRepo: gameRepo,
      gameController: gameController,
      habitController: habitController,
    );

    // load initial
    habitController.load();
  }

  @override
  Widget build(BuildContext context) {
    return _AppInherited(
      controllers: _controllers,
      child: widget.child,
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