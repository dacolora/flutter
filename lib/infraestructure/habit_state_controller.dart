import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mylifegame/core/time.dart';
import 'package:mylifegame/domain/entities/habit_log.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HabitStateController extends ChangeNotifier {
  final List<HabitLog> _logs = [];
  HabitStateController() {
    loadLogs(); // Carga los logs al inicializar el controlador
  }


  // Agregar o actualizar un log
  void setLog(String habitId, DateTime day, HabitDayStatus status) {
    final dayKey = Time.ymd(day);
    final existingLog = _logs.firstWhere(
      (log) => log.habitId == habitId && log.dayKey == dayKey,
      orElse: () => HabitLog.forDay(habitId: habitId, day: day),
    );

    final updatedLog = existingLog.copyWith(
      status: status,
      completedAt: status == HabitDayStatus.done ? DateTime.now() : null,
    );

    // Si el log ya existe, actualízalo; si no, agrégalo
    if (_logs.contains(existingLog)) {
      _logs[_logs.indexOf(existingLog)] = updatedLog;
    } else {
      _logs.add(updatedLog);
    }
saveLogs();
    notifyListeners(); // Notifica a la UI para que se actualice
  }

void updateLog(HabitLog log) {
  final existingLogIndex = _logs.indexWhere(
    (existingLog) => existingLog.habitId == log.habitId && existingLog.dayKey == log.dayKey,
  );

  if (existingLogIndex != -1) {
    // Actualiza el log existente
    _logs[existingLogIndex] = log;
  } else {
    // Agrega un nuevo log
    _logs.add(log);
  }
saveLogs();
  notifyListeners(); // Notifica a la UI para que se actualice
}

  // Obtener los logs de un hábito
  List<HabitLog> getLogsForHabit(String habitId) {
    return _logs.where((log) => log.habitId == habitId).toList();
  }

Future<void> saveLogs() async {
  final prefs = await SharedPreferences.getInstance();
  final logsJson = _logs.map((log) => log.toJson()).toList();
  await prefs.setString('logs', jsonEncode(logsJson));
  print('Logs guardados: $_logs');
}

Future<void> loadLogs() async {
  final prefs = await SharedPreferences.getInstance();
  final logsJson = prefs.getString('logs');
  if (logsJson != null) {
    final List<dynamic> decoded = jsonDecode(logsJson);
    _logs.clear();
    _logs.addAll(decoded.map((json) => HabitLog.fromJson(json)).toList());
  }
}


  // Obtener el log de un día específico
  HabitDayStatus getStatusForDay(String habitId, DateTime day) {
    final dayKey = Time.ymd(day);
    return _logs
        .firstWhere(
          (log) => log.habitId == habitId && log.dayKey == dayKey,
          orElse: () => HabitLog.forDay(habitId: habitId, day: day),
        )
        .status;
  }
}