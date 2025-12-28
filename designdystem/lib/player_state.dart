import '../core/constants.dart';
import 'area.dart';
import 'action_entry.dart';

class AreaProgress {
  AreaProgress({
    required this.area,
    required this.level,
    required this.xpInLevel,
  });

  final LifeArea area;
  final int level;
  final int xpInLevel;

  int get xpToNext => AppConstants.xpToNextLevel(level);

  AreaProgress copyWith({int? level, int? xpInLevel}) => AreaProgress(
        area: area,
        level: level ?? this.level,
        xpInLevel: xpInLevel ?? this.xpInLevel,
      );

  Map<String, dynamic> toJson() => {
        'area': area.name,
        'level': level,
        'xpInLevel': xpInLevel,
      };

  static AreaProgress fromJson(Map<String, dynamic> json) => AreaProgress(
        area: LifeArea.values.firstWhere((e) => e.name == json['area']),
        level: (json['level'] as num).toInt(),
        xpInLevel: (json['xpInLevel'] as num).toInt(),
      );
}

class PlayerState {
  PlayerState({
    required this.hp,
    required this.varos,
    required this.areas,
    required this.history,
  });

  final int hp;
  final int varos;
  final Map<LifeArea, AreaProgress> areas;
  final List<ActionEntry> history;

  factory PlayerState.initial() {
    final map = <LifeArea, AreaProgress>{};
    for (final a in LifeArea.values) {
      map[a] = AreaProgress(area: a, level: AppConstants.minLevel, xpInLevel: 0);
    }
    return PlayerState(hp: AppConstants.maxHp, varos: 0, areas: map, history: []);
  }

  PlayerState copyWith({
    int? hp,
    int? varos,
    Map<LifeArea, AreaProgress>? areas,
    List<ActionEntry>? history,
  }) {
    return PlayerState(
      hp: hp ?? this.hp,
      varos: varos ?? this.varos,
      areas: areas ?? this.areas,
      history: history ?? this.history,
    );
  }

  bool get isDead => hp <= AppConstants.minHp;

  Map<String, dynamic> toJson() => {
        'hp': hp,
        'varos': varos,
        'areas': areas.map((k, v) => MapEntry(k.name, v.toJson())),
        'history': history.map((e) => e.toJson()).toList(),
      };

  static PlayerState fromJson(Map<String, dynamic> json) {
    final areasJson = (json['areas'] as Map).cast<String, dynamic>();
    final areaMap = <LifeArea, AreaProgress>{};
    for (final entry in areasJson.entries) {
      final area = LifeArea.values.firstWhere((e) => e.name == entry.key);
      areaMap[area] = AreaProgress.fromJson((entry.value as Map).cast<String, dynamic>());
    }
    final hist = (json['history'] as List<dynamic>)
        .map((e) => ActionEntry.fromJson((e as Map).cast<String, dynamic>()))
        .toList();

    return PlayerState(
      hp: (json['hp'] as num).toInt(),
      varos: (json['varos'] as num).toInt(),
      areas: areaMap,
      history: hist,
    );
  }
}