
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StartingScreen extends StatelessWidget {
  const StartingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Spacer(flex: 3),
              // Header
              const Text(
                'Commençons',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Bienvenue sur',
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(width: 5), // Reduced spacing
                  Image.asset(
                    'assets/images/texte.png',
                    height: 28, // Increased height
                  ),
                ],
              ),
              const Spacer(flex: 2),

              // Central Graphic
              SizedBox(
                height: 220,
                child: Center(
                  child: Image.asset(
                    'assets/images/logGraf.png',
                     width: 180,
                  ),
                ),
              ),
              const Spacer(flex: 3),

              // "Continue with number" Button
              ElevatedButton(
                onPressed: () {
                   context.go('/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E90FF),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                  shadowColor: Colors.black.withAlpha((255 * 0.3).round()),
                ),
                child: const Text(
                  'Continuer avec le numéro',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
              const SizedBox(height: 24),

              // Sign up Text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Vous n'avez pas de compte ?",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  TextButton(
                    onPressed: () {
                      context.go('/signup'); 
                    },
                    child: const Text(
                      "S'inscrire",
                      style: TextStyle(
                        color: Color(0xFF1E90FF),
                        fontWeight: FontWeight.bold,
                        fontSize: 16
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
