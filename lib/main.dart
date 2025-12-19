import 'package:flutter/material.dart';
import 'package:myapp/onboarding_screen.dart';
import 'package:myapp/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ticket241',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E90FF)),
      ),
      home: const SplashScreen(), // Change back to SplashScreen
    );
  }
}
