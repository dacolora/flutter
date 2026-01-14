

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

class LifeAreaModel {
  final LifeArea id;
  final String title;
  final String tagline; // micro-frase para la card
  final String becomeTitle; // "Te conviertes en..."
  final String becomeDescription; // narrativa poderosa
  final List<OnboardingSlide> slides;
  final int accentColor; // ARGB int
  final String iconGlyph; // emoji / fallback

  const LifeAreaModel({
    required this.id,
    required this.title,
    required this.tagline,
    required this.becomeTitle,
    required this.becomeDescription,
    required this.slides,
    required this.accentColor,
    required this.iconGlyph,
  });
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

class OnboardingSlide {
  final String title;
  final String description;
  final String powerUp; // “+Focus”, “+Disciplina”, etc.
  final String symbol; // emoji / glyph

  const OnboardingSlide({
    required this.title,
    required this.description,
    required this.powerUp,
    required this.symbol,
  });
}