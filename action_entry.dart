import '../../core/id.dart';
import 'life_area.dart';

enum ActionType { goodHabit, badHabit, system }

/// Acción que alimenta tu motor (HP/XP/Varos).
class ActionEntry {
  ActionEntry({
    required this.id,
    required this.title,
    required this.type,
    this.area,
    required this.hpDelta,
    required this.varosDelta,
    required this.xpDelta,
    required this.createdAt,
    this.notes,
  });

  factory ActionEntry.habit({
    required String title,
    required ActionType type,
    LifeArea? area,
    required int hpDelta,
    required int varosDelta,
    required int xpDelta,
    String? notes,
  }) {
    return ActionEntry(
      id: Id.newId(),
      title: title,
      type: type,
      area: area,
      hpDelta: hpDelta,
      varosDelta: varosDelta,
      xpDelta: xpDelta,
      createdAt: DateTime.now(),
      notes: notes,
    );
  }

  final String id;
  final String title;
  final ActionType type;
  final LifeArea? area;
  final int hpDelta;
  final int varosDelta;
  final int xpDelta;
  final DateTime createdAt;
  final String? notes;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type.name,
        'area': area?.name,
        'hpDelta': hpDelta,
        'varosDelta': varosDelta,
        'xpDelta': xpDelta,
        'createdAt': createdAt.toIso8601String(),
        'notes': notes,
      };

  static ActionEntry fromJson(Map<String, dynamic> json) => ActionEntry(
        id: json['id'] as String,
        title: json['title'] as String,
        type: ActionType.values.firstWhere((e) => e.name == json['type']),
        area: json['area'] == null
            ? null
            : LifeArea.values.firstWhere((e) => e.name == json['area']),
        hpDelta: (json['hpDelta'] as num).toInt(),
        varosDelta: (json['varosDelta'] as num).toInt(),
        xpDelta: (json['xpDelta'] as num).toInt(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        notes: json['notes'] as String?,
      );
}