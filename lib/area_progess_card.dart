import 'package:flutter/material.dart';
import 'package:mylifegame/domain/entities/life_area.dart';
import 'package:mylifegame/infraestructure/service/app_scope.dart';
import 'package:mylifegame/ui/ui_token.dart';
import '../../models/player_state.dart';

class AreaProgressCard extends StatelessWidget {
  const AreaProgressCard({super.key, required this.progress});

  final AreaProgress progress;

  @override
  Widget build(BuildContext context) {
        final c = AppScope.of(context);
    final game = c.gameController;

    final playerState = game.state;
    final level = progress.level;
    final xp = progress.xpInLevel;
    final max = progress.xpToNext;
    final pct = (max == 0) ? 1.0 : (xp / max).clamp(0.0, 1.0);

    for (final entry in playerState.areas.entries) {
  final area = entry.key;
  final progress = entry.value;

  print('Área: ${area.label}, Nivel: ${progress.level}, XP: ${progress.xpInLevel}/${progress.xpToNext}');
}

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
                   decoration: UiTokens.neonCard(),
        
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(progress.area.label, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text('Nivel $level', style: const TextStyle(fontWeight: FontWeight.w800,color: Colors.white)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(value: pct, minHeight: 10),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                level >= 10 ? 'MAX' : 'XP: $xp / $max',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}