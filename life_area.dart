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

extension LifeAreaUi on LifeArea {
  String get label {
    switch (this) {
      case LifeArea.mind:
        return 'Mente';
      case LifeArea.health:
        return 'Salud';
      case LifeArea.spirituality:
        return 'Espiritualidad';
      case LifeArea.money:
        return 'Dinero';
      case LifeArea.projects:
        return 'Proyectos';
      case LifeArea.love:
        return 'Amor';
      case LifeArea.family:
        return 'Familia';
      case LifeArea.adventure:
        return 'Aventura';
      case LifeArea.creativity:
        return 'Creatividad';
    }
  }
}