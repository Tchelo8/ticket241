
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/theme/design_tokens.dart';

class StartingScreen extends StatelessWidget {
  const StartingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenForm),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Spacer(flex: 3),
              Text('Commençons', textAlign: TextAlign.center, style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Bienvenue sur', style: TextStyle(fontSize: 18, color: c.ink2)),
                  const SizedBox(width: 6),
                  Image.asset('assets/images/texte.png', height: 24),
                ],
              ),
              const Spacer(flex: 2),
              SizedBox(
                height: 220,
                child: Center(child: Image.asset('assets/images/logGraf.png', width: 180)),
              ),
              const Spacer(flex: 3),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Continuer avec le numéro'),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Vous n\'avez pas de compte ?', style: TextStyle(color: c.ink2, fontSize: 15)),
                  TextButton(
                    onPressed: () => context.go('/signup'),
                    child: Text('S\'inscrire', style: TextStyle(color: c.acc, fontWeight: FontWeight.w700, fontSize: 15)),
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
