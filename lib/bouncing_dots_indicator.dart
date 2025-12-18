import 'package:flutter/material.dart';

class BouncingDotsIndicator extends StatefulWidget {
  const BouncingDotsIndicator({super.key});

  @override
  _BouncingDotsIndicatorState createState() => _BouncingDotsIndicatorState();
}

class _BouncingDotsIndicatorState extends State<BouncingDotsIndicator>
    with TickerProviderStateMixin {
  late AnimationController _leftDotController;
  late AnimationController _rightDotController;

  @override
  void initState() {
    super.initState();
    _leftDotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _rightDotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _leftDotController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _leftDotController.reverse();
        _rightDotController.forward();
      }
    });

    _rightDotController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _rightDotController.reverse();
        _leftDotController.forward();
      }
    });

    _leftDotController.forward();
  }

  @override
  void dispose() {
    _leftDotController.dispose();
    _rightDotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _leftDotController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -20 * _leftDotController.value),
              child: const Dot(),
            );
          },
        ),
        const SizedBox(width: 10),
        const Dot(),
        const SizedBox(width: 10),
        AnimatedBuilder(
          animation: _rightDotController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -20 * _rightDotController.value),
              child: const Dot(),
            );
          },
        ),
      ],
    );
  }
}

class Dot extends StatelessWidget {
  const Dot({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
      ),
    );
  }
}
