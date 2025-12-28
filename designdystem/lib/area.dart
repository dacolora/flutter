enum LifeArea {
  mind,
  health,
  spirituality,
  money,
  projects,
  love,
  family,
  adventure,
  creativity,
}

extension LifeAreaX on LifeArea {
  String get label {
    switch (this) {
      case LifeArea.mind:
        return 'Mente / Disciplina';
      case LifeArea.health:
        return 'Salud / Físico';
      case LifeArea.spirituality:
        return 'Espiritualidad';
      case LifeArea.money:
        return 'Dinero / Carrera';
      case LifeArea.projects:
        return 'Proyectos';
      case LifeArea.love:
        return 'Relación Amorosa';
      case LifeArea.family:
        return 'Familia';
      case LifeArea.adventure:
        return 'Aventura';
      case LifeArea.creativity:
        return 'Creatividad';
    }
  }

  String get id => name;
}