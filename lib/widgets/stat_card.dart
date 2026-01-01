import 'package:flutter/material.dart';
import 'package:mylifegame/ui/ui_token.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String value;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
                decoration: UiTokens.neonCard(),
      
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
                  const SizedBox(height: 6),
                  Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900,color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white)),
                ]),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}