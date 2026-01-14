import 'package:flutter/material.dart';
import 'package:mylifegame/create_habit/glow_card.dart';
import 'package:mylifegame/ui/habit_screen.dart';



class HabitRouteCard extends StatefulWidget {


  const HabitRouteCard();

  @override
  State<HabitRouteCard> createState() => HabitRouteCard2State();
}

class HabitRouteCard2State extends State<HabitRouteCard> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTapDown: (_) => setState(() => pressed = true),
      onTapCancel: () => setState(() => pressed = false),
      onTapUp: (_) => setState(() => pressed = false),
      onTap: (){
        Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HabitsScreen()),
              );
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        scale: pressed ? 1.03 : 1.0,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity:  0.72,
          child: GlowCard(
            glowColor: Colors.blueAccent,
            selected: true,
            child: HabitRouteCard2Content( glow: Colors.blueAccent),
          ),
        ),
      ),
    );
  }
}

class HabitRouteCard2Content extends StatelessWidget {
  final Color glow;

  const HabitRouteCard2Content({ required this.glow});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // icon "holograma"
          Container(
       
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  glow.withOpacity(0.45),
                  glow.withOpacity(0.10),
                  Colors.transparent,
                ],
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '🗓️',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 28, color: Colors.white),
            ),
          ),
          Text(
            'Registrar Habitos',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
     
          
        ],
      ),
    );
  }
}