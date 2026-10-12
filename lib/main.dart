import 'package:flutter/material.dart';

void main() {
  runApp(const HabitStudyTrackerApp());
}

/// Неделя 1: стартовое приложение «Hello World».
class HabitStudyTrackerApp extends StatelessWidget {
  const HabitStudyTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit & Study Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const Scaffold(
        body: Center(
          child: Text(
            'Hello World!\nHabit & Study Tracker',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}
