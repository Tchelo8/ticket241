import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:myapp/app_router.dart';
import 'package:myapp/providers/favorites_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  final prefs = await SharedPreferences.getInstance();
  final bool onboardingCompleted = prefs.getBool('onboardingCompleted') ?? false;
  runApp(MyApp(onboardingCompleted: onboardingCompleted));
}

class MyApp extends StatelessWidget {
  final bool onboardingCompleted;

  const MyApp({super.key, required this.onboardingCompleted});

  @override
  Widget build(BuildContext context) {
    final appRouter = AppRouter(onboardingCompleted: onboardingCompleted);

    return ChangeNotifierProvider(
      create: (context) => FavoritesProvider(),
      child: MaterialApp.router(
        title: 'Ticket241',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E90FF)),
        ),
        routerConfig: appRouter.router,
      ),
    );
  }
}
