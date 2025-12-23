
import 'package:flutter/material.dart';
import 'package:myapp/starting_screen.dart'; // Changement de l'import
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  bool _isLastPage = false;

  final List<OnboardingPage> _pages = [
    const OnboardingPage(
      image: 'assets/images/queue.png',
      title: "Dites adieu aux files d'attente",
      subtitle: "Achetez vos billets en quelques clics et profitez de vos événements sans stress.",
    ),
    const OnboardingPage(
      image: 'assets/images/party.png',
      title: "Explorez les événements autour de vous",
      subtitle: "Trouvez des concerts, des matchs, des spectacles et bien plus encore.",
    ),
    const OnboardingPage(
      image: 'assets/images/ticketHome.png',
      title: "Vos billets, toujours à portée de main",
      subtitle: "Accédez à vos billets électroniques à tout moment, même sans connexion.",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _isLastPage = _pageController.page!.round() == _pages.length - 1;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            children: _pages,
          ),
          Positioned(
            bottom: 40,
            left: 40,
            right: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SmoothPageIndicator(
                  controller: _pageController,
                  count: _pages.length,
                  effect: const ExpandingDotsEffect(
                    activeDotColor: Color(0xFF1E90FF),
                    dotColor: Colors.grey,
                    dotHeight: 10,
                    dotWidth: 10,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_isLastPage) {
                      Navigator.pushReplacement(
                        context,
                        // Redirection vers la page de démarrage
                        MaterialPageRoute(builder: (context) => const StartingScreen()),
                      );
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(15),
                    backgroundColor: const Color(0xFF1E90FF),
                    foregroundColor: Colors.white,
                  ),
                  child: const Icon(Icons.arrow_forward_ios, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;

  const OnboardingPage({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                image,
                height: 350,
              ),
            ),
            const SizedBox(height: 50),
            Text(
              title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
