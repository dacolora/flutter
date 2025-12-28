import 'package:flutter/material.dart';
import 'state/game_controller.dart';
import 'ui/screens/dashboard_screen.dart';
import 'ui/theme.dart';

class LifeRpgApp extends StatelessWidget {
  const LifeRpgApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Life RPG',
      theme: buildAppTheme(),
      home: GameControllerScope(
        child: const DashboardScreen(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}