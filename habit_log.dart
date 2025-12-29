import '../../core/id.dart';
import '../../core/time.dart';

enum HabitDayStatus { pending, done, missed, skipped }

/// Log diario por hábito (la base del tracker visual).
class HabitLog {
  HabitLog({
    required this.id,
    required this.habitId,
    required this.dayKey,
    required this.status,
    this.completedAt,
  });

  factory HabitLog.forDay({
    required String habitId,
    required DateTime day,
    HabitDayStatus status = HabitDayStatus.pending,
  }) {
    return HabitLog(
      id: Id.newId(),
      habitId: habitId,
      dayKey: Time.ymd(day),
      status: status,
      completedAt: status == HabitDayStatus.done ? DateTime.now() : null,
    );
  }

  final String id;
  final String habitId;

  /// YYYY-MM-DD (zona local) para indexar fácil.
  final String dayKey;

  final HabitDayStatus status;
  final DateTime? completedAt;

  HabitLog copyWith({HabitDayStatus? status, DateTime? completedAt}) {
    return HabitLog(
      id: id,
      habitId: habitId,
      dayKey: dayKey,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'habitId': habitId,
        'dayKey': dayKey,
        'status': status.name,
        'completedAt': completedAt?.toIso8601String(),
      };

  static HabitLog fromJson(Map<String, dynamic> json) => HabitLog(
        id: json['id'] as String,
        habitId: json['habitId'] as String,
        dayKey: json['dayKey'] as String,
        status: HabitDayStatus.values.firstWhere((e) => e.name == json['status']),
        completedAt: json['completedAt'] == null ? null : DateTime.parse(json['completedAt']),
      );
}