import 'package:flutter/material.dart';
import '../state/app_scope.dart';
import '../screens/habits_screen.dart';
import '../../core/ui_tokens.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final game = c.gameController;

    return AnimatedBuilder(
      animation: game,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: const Text('My Life Game'),
          actions: [
            IconButton(
              icon: const Icon(Icons.grid_view_rounded),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HabitsScreen()),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: UiTokens.neonCard(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Player HUD', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                const SizedBox(height: 12),
                Text('HP: ${game.hp}/1000', style: const TextStyle(color: UiTokens.textSoft)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(value: game.hp / 1000, minHeight: 10),
                ),
                const SizedBox(height: 14),
                Text('Varos: ${game.varos}', style: const TextStyle(color: UiTokens.textSoft)),
                const SizedBox(height: 14),
                const Text('Tip: Completa hábitos para subir XP por área. Fallar baja XP + HP, nunca Varos.',
                    style: TextStyle(color: UiTokens.textSoft)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}