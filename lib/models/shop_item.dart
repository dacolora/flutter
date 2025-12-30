import 'package:mylifegame/core/id.dart';

class ShopItem {
  ShopItem({
    required this.id,
    required this.title,
    required this.costVaros,
    this.hpDelta = 0,
    this.notes,
  });

  factory ShopItem.create({
    required String title,
    required int costVaros,
    int hpDelta = 0,
    String? notes,
  }) {
    return ShopItem(
      id: Id.newId(),
      title: title,
      costVaros: costVaros,
      hpDelta: hpDelta,
      notes: notes,
    );
  }

  final String id;
  final String title;
  final int costVaros; // cost is positive
  final int hpDelta; // optional effect (e.g. -20 hp for alcohol)
  final String? notes;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'costVaros': costVaros,
    'hpDelta': hpDelta,
    'notes': notes,
  };

  static ShopItem fromJson(Map<String, dynamic> json) => ShopItem(
    id: json['id'] as String,
    title: json['title'] as String,
    costVaros: (json['costVaros'] as num).toInt(),
    hpDelta: (json['hpDelta'] as num).toInt(),
    notes: json['notes'] as String?,
  );
}
