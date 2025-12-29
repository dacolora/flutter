import 'package:flutter/foundation.dart';
import '../../domain/entities/action_entry.dart';
import '../../domain/entities/life_area.dart';

/// Motor simple (HP/XP/Varos) in-memory.
/// Tú ya tienes uno más completo: aquí solo es “muestra” y adapter.
/// Enchufarlo al tuyo es directo.
class GameController extends ChangeNotifier {
  int hp = 1000;
  int varos = 0;

  final Map<LifeArea, int> xp = {for (final a in LifeArea.values) a: 0};

  Future<void> apply(ActionEntry entry) async {
    hp = (hp + entry.hpDelta).clamp(0, 1000);
    varos += entry.varosDelta;

    if (entry.area != null) {
      xp[entry.area!] = (xp[entry.area!] ?? 0) + entry.xpDelta;
      if (xp[entry.area!]! < 0) xp[entry.area!] = 0;
    }
    notifyListeners();
  }
}