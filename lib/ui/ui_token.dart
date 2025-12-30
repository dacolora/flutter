import 'package:flutter/material.dart';

class UiTokens {
  static const bg = Color(0xFF070A12);
  static const card = Color(0xFF0E1424);

  static const neonGreen = Color(0xFF7CFF6B);
  static const neonBlue = Color(0xFF6BE4FF);
  static const neonPurple = Color(0xFFB56BFF);
  static const danger = Color(0xFFFF4D6D);

  static const textSoft = Colors.white70;
  static const borderSoft = Colors.white24;

  static const radius = 18.0;

  static BoxDecoration neonCard() => BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderSoft),
      );
}