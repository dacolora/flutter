import 'package:flutter/material.dart';

class HabitsScreenHelper {
  // ...existing code...

  static List<DateTime> getMonthDays(DateTime date) {
    // Helper to get all days of the current month
    final firstDay = DateTime(date.year, date.month, 1);
    final lastDay = DateTime(date.year, date.month + 1, 0);
    return List.generate(
      lastDay.day,
      (index) => DateTime(date.year, date.month, index + 1),
    );
  }

  static List<DateTime> getLast7Days(DateTime date) {
    // Helper to get the last 7 days
    return List.generate(
      7,
      (index) => date.subtract(Duration(days: index)),
    ).reversed.toList();
  }

}
