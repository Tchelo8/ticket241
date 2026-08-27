import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/theme/design_tokens.dart';
import 'package:myapp/widgets/interpolated_page_indicator.dart';

class _Slide {
  final String kicker;
  final String title;
  final String body;
  final String image;
  final BoxFit fit;
  const _Slide({required this.kicker, required this.title, required this.body, required this.image, this.fit = BoxFit.cover});
}

const _slides = [
  _Slide(
    kicker: 'Découvrir',
    title: 'Tout ce qui se joue au Gabon, ce soir.',
    body: 'Concerts, matchs, festivals : ce qui bouge près de chez vous, en un coup d\'œil.',
    image: 'assets/images/jazz.png',
  ),
  _Slide(
    kicker: 'Payer',
    title: 'Airtel Money ou Moov Money. Rien d\'autre.',
    body: 'Le paiement mobile que vous utilisez déjà, sans carte ni compte à créer.',
    image: 'assets/images/party.png',
  ),
  _Slide(
    kicker: 'Entrer',
    title: 'Votre billet vit dans votre poche.',
    body: 'Un QR code à présenter à l\'entrée, disponible même sans connexion.',
    image: 'assets/images/queue.png',
    fit: BoxFit.contain,
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  OnboardingScreenState createState() => OnboardingScreenState();
}

class OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  bool _isLastPage = false;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final page = _pageController.page;
      if (page == null) return;
      final isLast = page.round() == _slides.length - 1;
      if (isLast != _isLastPage) setState(() => _isLastPage = isLast);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingCompleted', true);
    if (mounted) context.go('/');
  }

  void _next() {
    if (_isLastPage) {
      _completeOnboarding();
    } else {
      _pageController.nextPage(duration: AppMotion.tRise, curve: AppMotion.elastic);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Scaffold(
      backgroundColor: c.bg,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _slides.length,
            itemBuilder: (context, index) => _SlidePage(slide: _slides[index]),
          ),
          if (!_isLastPage)
            Positioned(
              top: 52,
              right: 20,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.pill),
                child: Container(
                  decoration: BoxDecoration(color: const Color(0x6B000000), borderRadius: BorderRadius.circular(AppRadii.pill)),
                  child: TextButton(
                    onPressed: _completeOnboarding,
                    child: const Text('Passer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 40,
            left: 40,
            right: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InterpolatedPageIndicator(controller: _pageController, count: _slides.length),
                GestureDetector(
                  onTap: _next,
                  child: Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(color: c.acc, shape: BoxShape.circle, boxShadow: context.tokens.shadows.shm),
                    child: _isLastPage
                        ? Center(child: Text('Go', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: c.onAcc)))
                        : Icon(PhosphorIconsRegular.arrowRight, size: 25, color: c.onAcc),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SlidePage extends StatelessWidget {
  final _Slide slide;
  const _SlidePage({required this.slide});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 428,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(slide.image, fit: slide.fit),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [c.bg.withValues(alpha: 0), c.bg],
                    stops: const [0.40, 0.99],
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenForm, 0, AppSpacing.screenForm, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(slide.kicker.toUpperCase(),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 2, color: c.acc)),
              const SizedBox(height: 10),
              Text(slide.title, style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 12),
              Text(slide.body, style: TextStyle(fontSize: 16, color: c.ink2, height: 1.5)),
            ],
          ),
        ),
      ],
    );
  }
}
