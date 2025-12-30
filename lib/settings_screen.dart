import 'package:flutter/material.dart';
import 'package:mylifegame/infraestructure/service/app_scope.dart';
import 'infraestructure/service/game_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final dead = controller.gameController.state.isDead;

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                dead
                    ? 'Estás en GAME OVER. Debes REVIVIR.'
                    : 'Aquí ajustas el sistema: revive, reset, etc.',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: dead ? () => controller.gameController. revive(reviveType: 'epic') : null,
            icon: const Icon(Icons.flash_on),
            label: const Text('Revivir ÉPICO (full HP)'),
          ),
          const SizedBox(height: 10),
          FilledButton.tonalIcon(
            onPressed: dead ? () => controller.gameController.revive(reviveType: 'costly') : null,
            icon: const Icon(Icons.warning_amber),
            label: const Text('Revivir COSTOSO (penalizado)'),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () async {
              final ok = await _confirm(context, '¿Resetear TODO? Esto borra tu progreso.');
              if (ok) await controller.gameController.resetAll();
              if (context.mounted) Navigator.pop(context);
            },
            icon: const Icon(Icons.delete_forever),
            label: const Text('Reset total'),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirm(BuildContext context, String msg) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar'),
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sí')),
        ],
      ),
    );
    return res ?? false;
  }
}