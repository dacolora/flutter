PlayerState apply(ActionEntry entry) {
  // 1. Copiamos estado actual (inmutabilidad)
  final newHp = (hp + entry.hpDelta).clamp(0, 1000);
  final newXp = (xp + entry.xpDelta).clamp(0, 1 << 31);
  final newVaros = (varos + entry.varosDelta).clamp(0, 1 << 31);

  // 2. Progreso por área
  final updatedAreas = Map<String, AreaProgress>.from(areas);

  if (entry.areaId != null) {
    final current = updatedAreas[entry.areaId!] ??
        AreaProgress.initial(entry.areaId!);

    updatedAreas[entry.areaId!] =
        current.addXp(entry.xpDelta);
  }

  // 3. Historial
  final updatedHistory = List<ActionEntry>.from(history)
    ..add(entry);

  // 4. Nuevo estado
  return PlayerState(
    hp: newHp,
    xp: newXp,
    varos: newVaros,
    areas: updatedAreas,
    history: updatedHistory,
  );
}