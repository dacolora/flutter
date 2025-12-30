import 'package:flutter/material.dart';
import 'package:mylifegame/dashboard_screen.dart';
import 'package:mylifegame/infraestructure/service/app_scope.dart';
import 'package:mylifegame/core/theme.dart';


class LifeRpgApp extends StatelessWidget {
  const LifeRpgApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Life RPG',
      theme: buildNeonTheme(),
      builder: (context, child){ return AppScope(
        child: child ?? SizedBox.shrink(),
      ); },
      home:  AppScope(child: MaterialApp(home: DashboardScreen())),
      
      debugShowCheckedModeBanner: false,
    );
  }
}