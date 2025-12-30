import 'package:flutter/material.dart';
import 'package:mylifegame/area_progess_card.dart';
import 'package:mylifegame/domain/entities/action_entry.dart';
import 'package:mylifegame/domain/entities/life_area.dart';
import 'package:mylifegame/infraestructure/service/app_scope.dart';
import 'package:mylifegame/ui/habit_screen.dart';
import 'package:mylifegame/ui/ui_token.dart';
import 'package:mylifegame/widgets/section_title.dart';
import '../../core/constants.dart';
import '../../core/formatters.dart';
import '../../models/player_state.dart';
import 'infraestructure/service/game_controller.dart';

import '../widgets/stat_card.dart';
import 'log_action_screen.dart';
import 'settings_screen.dart';
import 'shop_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final game = c.gameController;

    final s = game.state;

    return AnimatedBuilder(
      animation: game,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: const Text('Life RPG'),
          actions: [
            Builder(
              builder: (ctx) => IconButton(
                onPressed: () => Navigator.push(
                  ctx,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
                icon: const Icon(Icons.settings),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.grid_view_rounded),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HabitsScreen()),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: s.isDead
              ? null
              : () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LogActionScreen()),
                ),
          icon: const Icon(Icons.add),
          label: const Text('Registrar'),
        ),
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: _DeathBanner(state: s),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: UiTokens.neonCard(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Player HUD',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'HP: ${game.hp}/1000',
                      style: const TextStyle(color: UiTokens.textSoft),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: game.hp / 1000,
                        minHeight: 10,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Varos: ${game.varos}',
                      style: const TextStyle(color: UiTokens.textSoft),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Tip: Completa hábitos para subir XP por área. Fallar baja XP + HP, nunca Varos.',
                      style: TextStyle(color: UiTokens.textSoft),
                    ),
                  ],
                ),
              ),
            ),
            _TopStatsRow(state: s),
            const SectionTitle('Áreas (XP / Nivel)'),
            ...s.areas.values.map((p) => AreaProgressCard(progress: p)),
            const SectionTitle('Historial (último primero)'),
            ...s.history.take(12).map((e) => _HistoryTile(e)),
            const SizedBox(height: 90),
          ],
        ),
        bottomNavigationBar: _BottomBar(),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ShopScreen()),
                ),
                icon: const Icon(Icons.storefront),
                label: const Text('Tienda'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LogActionScreen()),
                ),
                icon: const Icon(Icons.bolt),
                label: const Text('Acción'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopStatsRow extends StatelessWidget {
  const _TopStatsRow({required this.state});
  final PlayerState state;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final s = controller.gameController.state;
    final hpPct = (s.hp / AppConstants.maxHp).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          StatCard(
            title: 'HP (Vida)',
            value: '${s.hp} / ${AppConstants.maxHp}',
            subtitle: s.isDead
                ? 'GAME OVER'
                : 'Mantén el respeto por ti mismo.',
            trailing: SizedBox(
              width: 90,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(value: hpPct, minHeight: 10),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${(hpPct * 100).toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          StatCard(
            title: 'Varos',
            value: Fmt.money(s.varos),
            subtitle: 'Moneda ficticia para placer controlado.',
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile(this.entry);
  final ActionEntry entry;

  @override
  Widget build(BuildContext context) {
    final sign = (int v) => v == 0 ? '' : (v > 0 ? '+$v' : '$v');

    return ListTile(
      title: Text(entry.title),
      subtitle: Text(
        '${Fmt.dt(entry.createdAt)}'
        '${entry.area == null ? '' : ' • ${entry.area!.label}'}'
        '${entry.notes == null ? '' : '\n${entry.notes}'}',
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('HP ${sign(entry.hpDelta)}'),
          Text('V ${sign(entry.varosDelta)}'),
          Text('XP ${sign(entry.xpDelta)}'),
        ],
      ),
      isThreeLine: entry.notes != null,
    );
  }
}

class _DeathBanner extends StatelessWidget {
  const _DeathBanner({required this.state});
  final PlayerState state;

  @override
  Widget build(BuildContext context) {
    if (!state.isDead) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'GAME OVER: Tu HP llegó a 0.\nVe a Ajustes para REVIVIR (ÉPICO o COSTOSO).',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
