import 'package:flutter/material.dart';
import '../../core/formatters.dart';
import '../../models/shop_item.dart';
import '../../state/game_controller.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GameControllerScope.of(context);
    final s = controller.state;

    final items = <ShopItem>[
      ShopItem.create(title: 'Cerveza', costVaros: 200, hpDelta: -10, notes: 'Placer controlado. No abuses.'),
      ShopItem.create(title: 'Comida chatarra', costVaros: 300, hpDelta: -15),
      ShopItem.create(title: 'Cine / Salida', costVaros: 400),
      ShopItem.create(title: 'Día libre sin culpa', costVaros: 500, notes: 'Solo si llevas la semana fuerte.'),
      ShopItem.create(title: 'Postre', costVaros: 150, hpDelta: -5),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Tienda (Varos)')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet_outlined),
                  const SizedBox(width: 10),
                  Text('Tus Varos: ${Fmt.money(s.varos)}', style: const TextStyle(fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          ...items.map((it) => Card(
                child: ListTile(
                  title: Text(it.title),
                  subtitle: Text('Costo: ${Fmt.money(it.costVaros)}'
                      '${it.hpDelta == 0 ? '' : ' • HP ${it.hpDelta}'}'
                      '${it.notes == null ? '' : '\n${it.notes}'}'),
                  trailing: FilledButton(
                    onPressed: s.varos < it.costVaros ? null : () => controller.buyItem(it),
                    child: const Text('Comprar'),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}