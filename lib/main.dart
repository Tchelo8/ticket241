import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:myapp/app_router.dart';
import 'package:myapp/providers/auth_provider.dart';
import 'package:myapp/providers/favorites_provider.dart';
import 'package:myapp/providers/tickets_provider.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/onboarding_provider.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  await dotenv.load(fileName: ".env");
  final onboarding = OnboardingProvider(completed: await OnboardingProvider.load());

  // 1. Create the AuthProvider instance BEFORE the app starts.
  final authProvider = AuthProvider();
  // Billets et favoris rechargés à chaque connexion / déconnexion (ceux du compte apparaissent ou disparaissent)
  final ticketsProvider = TicketsProvider();
  final favoritesProvider = FavoritesProvider();
  var wasAuthenticated = authProvider.isAuthenticated;
  authProvider.addListener(() {
    if (authProvider.isLoading || authProvider.isAuthenticated == wasAuthenticated) return;
    wasAuthenticated = authProvider.isAuthenticated;
    ticketsProvider.refresh();
    favoritesProvider.refresh();
  });

  // Routeur créé une seule fois (recréé à chaque build, il perdait sa pile d'écrans)
  final appRouter = AppRouter(onboarding: onboarding, authProvider: authProvider);

  runApp(MyApp(
    onboarding: onboarding,
    authProvider: authProvider,
    ticketsProvider: ticketsProvider,
    favoritesProvider: favoritesProvider,
    appRouter: appRouter,
  ));
}

class MyApp extends StatelessWidget {
  final OnboardingProvider onboarding;
  final AuthProvider authProvider;
  final TicketsProvider ticketsProvider;
  final FavoritesProvider favoritesProvider;
  final AppRouter appRouter;

  const MyApp({
    super.key,
    required this.onboarding,
    required this.authProvider,
    required this.ticketsProvider,
    required this.favoritesProvider,
    required this.appRouter,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: onboarding),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: favoritesProvider),
        ChangeNotifierProvider.value(value: ticketsProvider),
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
