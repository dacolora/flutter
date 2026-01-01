import 'package:mylifegame/domain/entities/habit_shedule.dart';

import '../../../core/id.dart';
import 'life_area.dart';

/// Rewards por completar.
class HabitRewards {
  const HabitRewards({required this.xp, required this.varos, this.hp = 0});
  final int xp;
  final int varos;
  final int hp;

  Map<String, dynamic> toJson() => {'xp': xp, 'varos': varos, 'hp': hp};
  static HabitRewards fromJson(Map<String, dynamic> json) => HabitRewards(
    xp: (json['xp'] as num).toInt(),
    varos: (json['varos'] as num).toInt(),
    hp: (json['hp'] as num?)?.toInt() ?? 0,
  );
}

/// Penalties por fallar.
/// REGLA: varos NO se quitan por fallar.
class HabitPenalties {
  const HabitPenalties({required this.xpLoss, required this.hpLoss});
  final int xpLoss;
  final int hpLoss;

  Map<String, dynamic> toJson() => {'xpLoss': xpLoss, 'hpLoss': hpLoss};
  static HabitPenalties fromJson(Map<String, dynamic> json) => HabitPenalties(
    xpLoss: (json['xpLoss'] as num).toInt(),
    hpLoss: (json['hpLoss'] as num).toInt(),
  );
}

enum HabitDifficulty { easy, normal, hard, legendary }

class Habit {
  Habit({
    required this.id,
    required this.title,
    this.description,
    this.area,
    required this.schedule,
    required this.difficulty,
    required this.rewards,
    required this.penalties,
    required this.isActive,
    required this.createdAt,
  });

  Habit update({
    String? title,
    String? description,
    LifeArea? area,
    HabitSchedule? schedule,
    HabitDifficulty? difficulty,
    HabitRewards? rewards,
    HabitPenalties? penalties,
    bool? isActive,
  }) {
    return copyWith(
      title: title,
      description: description,
      area: area,
      schedule: schedule,
      difficulty: difficulty,
      rewards: rewards,
      penalties: penalties,
      isActive: isActive,
    );
  }

  factory Habit.create({
    required String title,
    String? description,
    LifeArea? area,
    required HabitSchedule schedule,
    HabitDifficulty difficulty = HabitDifficulty.normal,
    HabitRewards? rewards,
    HabitPenalties? penalties,
  }) {
    final r = rewards ?? _defaultRewards(difficulty);
    final p = penalties ?? _defaultPenalties(r);
    return Habit(
      id: Id.newId(),
      title: title,
      description: description,
      area: area,
      schedule: schedule,
      difficulty: difficulty,
      rewards: r,
      penalties: p,
      isActive: true,
      createdAt: DateTime.now(),
    );
  }

  final String id;
  final String title;
  final String? description;
  final LifeArea? area;
  final HabitSchedule schedule;
  final HabitDifficulty difficulty;
  final HabitRewards rewards;
  final HabitPenalties penalties;
  final bool isActive;
  final DateTime createdAt;

  Habit copyWith({
    String? title,
    String? description,
    LifeArea? area,
    HabitSchedule? schedule,
    HabitDifficulty? difficulty,
    HabitRewards? rewards,
    HabitPenalties? penalties,
    bool? isActive,
  }) {
    return Habit(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      area: area ?? this.area,
      schedule: schedule ?? this.schedule,
      difficulty: difficulty ?? this.difficulty,
      rewards: rewards ?? this.rewards,
      penalties: penalties ?? this.penalties,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'area': area?.name,
    'schedule': schedule.toJson(),
    'difficulty': difficulty.name,
    'rewards': rewards.toJson(),
    'penalties': penalties.toJson(),
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
  };

  static Habit fromJson(Map<String, dynamic> json, List<LifeArea> lifeAreas) {
    print(json['area'] == null);
    print('area ${json['area']}');
    return Habit(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,

      schedule: HabitSchedule.fromJson(
        (json['schedule'] as Map).cast<String, dynamic>(),
      ),
      area: LifeArea.values.firstWhere((e) => e.name == json['area']),
      difficulty: HabitDifficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
      ),
      rewards: HabitRewards.fromJson(
        (json['rewards'] as Map).cast<String, dynamic>(),
      ),
      penalties: HabitPenalties.fromJson(
        (json['penalties'] as Map).cast<String, dynamic>(),
      ),
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  static HabitRewards _defaultRewards(HabitDifficulty d) {
    switch (d) {
      case HabitDifficulty.easy:
        return const HabitRewards(xp: 15, varos: 25, hp: 5);
      case HabitDifficulty.normal:
        return const HabitRewards(xp: 25, varos: 40, hp: 5);
      case HabitDifficulty.hard:
        return const HabitRewards(xp: 40, varos: 70, hp: 10);
      case HabitDifficulty.legendary:
        return const HabitRewards(xp: 70, varos: 120, hp: 15);
    }
  }

  /// Penalidad “menos que lo ganado”, como pediste.
  /// Ej: si gana 25 XP, perder 15 XP (≈ 0.6x).
  static HabitPenalties _defaultPenalties(HabitRewards r) {
    final xpLoss = (r.xp * 0.6).round();
    final hpLoss = (r.hp > 0
        ? (r.hp * 2)
        : 10); // hábitos “curativos” fallados duelen un poco más.
    return HabitPenalties(xpLoss: xpLoss, hpLoss: hpLoss);
  }
}
