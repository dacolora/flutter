// enum LifeArea {
//   mind,
//   health,
//   spirituality,
//   money,
//   projects,
//   love,
//   family,
//   adventure,
//   creativity,
// }

// extension LifeAreaUi on LifeArea {
//   String get label {
//     switch (this) {
//       case LifeArea.mind:
//         return 'Mente';
//       case LifeArea.health:
//         return 'Salud';
//       case LifeArea.spirituality:
//         return 'Espiritualidad';
//       case LifeArea.money:
//         return 'Dinero';
//       case LifeArea.projects:
//         return 'Proyectos';
//       case LifeArea.love:
//         return 'Amor';
//       case LifeArea.family:
//         return 'Familia';
//       case LifeArea.adventure:
//         return 'Aventura';
//       case LifeArea.creativity:
//         return 'Creatividad';
//     }
//   }
// }

import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class LifeArea {
  final String id;
  final String label;

  LifeArea({required this.id, required this.label});

  factory LifeArea.fromJson(Map<String, dynamic> json) {
    return LifeArea(
      id: json['id'] as String,
      label: json['label'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
    };
  }
}

class LifeAreaRepository {
  static const _fileName = 'life_areas.json';

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<List<LifeArea>> getLifeAreas() async {
    try {
      final file = await _getFile();
      if (!file.existsSync()) {
        // Si el archivo no existe, crea uno con valores predeterminados
        final defaultAreas = defaultLifeAreas();
        await file.writeAsString(jsonEncode(defaultAreas.map((e) => e.toJson()).toList()));
        return defaultAreas;
      }
      final raw = await file.readAsString();
      final data = jsonDecode(raw) as List<dynamic>;
      return data.map((e) => LifeArea.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Error al cargar las áreas de la vida: $e');
    }
  }

  Future<void> saveLifeAreas(List<LifeArea> areas) async {
    final file = await _getFile();
    await file.writeAsString(jsonEncode(areas.map((e) => e.toJson()).toList()));
  }

  static List<LifeArea> defaultLifeAreas() {
    return [
      LifeArea(id: 'mind', label: 'Mente'),
      LifeArea(id: 'health', label: 'Salud'),
      LifeArea(id: 'spirituality', label: 'Espiritualidad'),
      LifeArea(id: 'money', label: 'Dinero'),
      LifeArea(id: 'projects', label: 'Proyectos'),
      LifeArea(id: 'love', label: 'Amor'),
      LifeArea(id: 'family', label: 'Familia'),
      LifeArea(id: 'adventure', label: 'Aventura'),
      LifeArea(id: 'creativity', label: 'Creatividad'),
    ];
  }
}