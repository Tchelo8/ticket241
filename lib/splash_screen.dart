import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/theme/design_tokens.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _popController;
  late final Animation<double> _popScale;
  late final AnimationController _barController;
  late final Animation<double> _barValue;

  @override
  void initState() {
    super.initState();
    _popController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _popScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.6, end: 1.06).chain(CurveTween(curve: Curves.easeOut)), weight: 70),
      TweenSequenceItem(tween: Tween(begin: 1.06, end: 1.0).chain(CurveTween(curve: Curves.easeOut)), weight: 30),
    ]).animate(_popController);
    _popController.forward();

    _barController = AnimationController(vsync: this, duration: const Duration(milliseconds: 5800));
    _barValue = Tween<double>(begin: 0.06, end: 1.0).animate(CurvedAnimation(parent: _barController, curve: AppMotion.standard));
    _barController.forward();

    Timer(const Duration(milliseconds: 6000), () {
      if (mounted) context.go('/onboarding');
    });
  }

  @override
  void dispose() {
    _popController.dispose();
    _barController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Scaffold(
      backgroundColor: c.bg,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _popScale,
                  child: Image.asset('assets/images/logo.png', width: 196),
                ),
                const SizedBox(height: 14),
                Text('La billetterie du Gabon',
                    style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic, color: c.ink2)),
                const SizedBox(height: 44),
                Container(
                  width: 132,
                  height: 2,
                  decoration: BoxDecoration(color: c.line, borderRadius: BorderRadius.circular(1)),
                  child: AnimatedBuilder(
                    animation: _barValue,
                    builder: (context, _) => Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: _barValue.value,
                        child: Container(decoration: BoxDecoration(color: c.acc, borderRadius: BorderRadius.circular(1))),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 32,
            child: Center(
              child: Text('LIBREVILLE · GABON',
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, letterSpacing: 2, color: c.ink3)),
            ),
          ),
        ],
      ),
    );
  }
}
