import 'package:flutter/material.dart';
import 'package:mylifegame/infraestructure/habit_state_controller.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

    final habitStateController = HabitStateController();
    
  await habitStateController.loadLogs();

  runApp(const LifeRpgApp());
}

// \