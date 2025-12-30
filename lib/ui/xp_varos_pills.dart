import 'package:flutter/material.dart';
import 'package:mylifegame/ui/ui_token.dart';

class XpVarosPills extends StatelessWidget {
  const XpVarosPills({
    super.key,
    required this.xp,
    required this.varos,
    required this.hp,
    required this.xpLoss,
    required this.hpLoss,
  });

  final int xp;
  final int varos;
  final int hp;
  final int xpLoss;
  final int hpLoss;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _pill('+$xp XP', UiTokens.neonBlue),
        _pill('+$varos Varos', UiTokens.neonGreen),
        if (hp > 0) _pill('+$hp HP', UiTokens.neonGreen),
        _pill('-$xpLoss XP (fallar)', UiTokens.danger),
        _pill('-$hpLoss HP (fallar)', UiTokens.danger),
        _pill('Varos NO bajan al fallar', UiTokens.textSoft),
      ],
    );
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: UiTokens.borderSoft),
        color: UiTokens.card,
      ),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12)),
    );
  }
}