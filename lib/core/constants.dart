class AppConstants {
  static const int maxHp = 1000;
  static const int minHp = 0;

  static const int minLevel = 1;
  static const int maxLevel = 10;

  /// XP needed to go from level N to N+1 (simple curve)
  /// You can replace with any formula later.
  static int xpToNextLevel(int level) {
    // Level 1->2: 120, 2->3: 160, ... grows slowly
    return 800 + (level * 840);
  }
}