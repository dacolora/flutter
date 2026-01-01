

// ignore_for_file: constant_identifier_names

enum LifeArea {
  Mente,
  Salud,
  Espiritualidad,
  Money,
  Proyectos,
  Amor,
  Familia,
  Aventura,
  Creatividad,
}

extension LifeAreaUi on LifeArea {
  String get label {
    switch (this) {
      case LifeArea.Mente:
        return 'Mente';
      case LifeArea.Salud:
        return 'Salud';
      case LifeArea.Espiritualidad:
        return 'Espiritualidad';
      case LifeArea.Money:
        return 'Dinero';
      case LifeArea.Proyectos:
        return 'Proyectos';
      case LifeArea.Amor:
        return 'Amor';
      case LifeArea.Familia:
        return 'Familia';
      case LifeArea.Aventura:
        return 'Aventura';
      case LifeArea.Creatividad:
        return 'Creatividad';
    }
  }
}

List<LifeArea> defaultLifeAreas() {
  return [
    LifeArea.Mente,
    LifeArea.Salud,
    LifeArea.Espiritualidad,
    LifeArea.Money,
    LifeArea.Proyectos,
    LifeArea.Amor,
    LifeArea.Familia,
    LifeArea.Aventura,
    LifeArea.Creatividad,
  ];
}
