import 'package:flutter/material.dart';
import 'package:mylifegame/ui/ui_token.dart';

ThemeData buildAppTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(
      primary: const Color(0xFF7CFF6B),
      secondary: const Color(0xFF6BE4FF),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}

ThemeData buildNeonTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: UiTokens.bg,
    colorScheme: base.colorScheme.copyWith(
      primary: UiTokens.neonGreen,
      secondary: UiTokens.neonBlue,
      surface: UiTokens.card,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: UiTokens.bg,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: UiTokens.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(UiTokens.radius)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: UiTokens.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: UiTokens.borderSoft),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: UiTokens.borderSoft),
      ),
    ),
  );
}