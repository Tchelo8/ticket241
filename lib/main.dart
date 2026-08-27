import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:myapp/app_router.dart';
import 'package:myapp/providers/auth_provider.dart';
import 'package:myapp/providers/favorites_provider.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  await dotenv.load(fileName: ".env");
  final prefs = await SharedPreferences.getInstance();
  final bool onboardingCompleted = prefs.getBool('onboardingCompleted') ?? false;
  
  // 1. Create the AuthProvider instance BEFORE the app starts.
  final authProvider = AuthProvider();

  runApp(MyApp(onboardingCompleted: onboardingCompleted, authProvider: authProvider));
}

class MyApp extends StatelessWidget {
  final bool onboardingCompleted;
  final AuthProvider authProvider;

  const MyApp({super.key, required this.onboardingCompleted, required this.authProvider});

  @override
  Widget build(BuildContext context) {
    // 2. Create AppRouter with the AuthProvider instance.
    final appRouter = AppRouter(onboardingCompleted: onboardingCompleted, authProvider: authProvider);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (context) => FavoritesProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp.router(
            title: 'Ticket241',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.build(themeProvider.variant),
            routerConfig: appRouter.router,
          );
        },
      ),
    );
  }
}
