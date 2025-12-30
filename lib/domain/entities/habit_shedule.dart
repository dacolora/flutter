enum HabitFrequency { daily, specificDays, timesPerWeek, timesPerMonth }

/// Scheduling flexible tipo tu visual:
/// Daily, Specific Days, # per week, # per month.
class HabitSchedule {
  const HabitSchedule({
    required this.frequency,
    this.daysOfWeek = const [],
    this.targetCount,
  });

  final HabitFrequency frequency;

  /// ISO weekdays 1..7 (solo para specificDays).
  final List<int> daysOfWeek;

  /// Para timesPerWeek o timesPerMonth.
  final int? targetCount;

  bool isDueOn(int isoWeekday) {
    switch (frequency) {
      case HabitFrequency.daily:
        return true;
      case HabitFrequency.specificDays:
        return daysOfWeek.contains(isoWeekday);
      case HabitFrequency.timesPerWeek:
      case HabitFrequency.timesPerMonth:
        // “Due” todos los días, pero se evalúa por conteo.
        return true;
    }
  }

  Map<String, dynamic> toJson() => {
        'frequency': frequency.name,
        'daysOfWeek': daysOfWeek,
        'targetCount': targetCount,
      };

  static HabitSchedule fromJson(Map<String, dynamic> json) => HabitSchedule(
        frequency: HabitFrequency.values.firstWhere((e) => e.name == json['frequency']),
        daysOfWeek: (json['daysOfWeek'] as List<dynamic>).map((e) => (e as num).toInt()).toList(),
        targetCount: (json['targetCount'] as num?)?.toInt(),
      );
}