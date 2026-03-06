import 'package:go_router/go_router.dart';
import 'package:myapp/main_screen.dart';
import 'package:myapp/otp_verification_screen.dart';
import 'package:myapp/starting_screen.dart';
import 'package:myapp/login_screen.dart';
import 'package:myapp/signup_screen.dart';
import 'package:myapp/profile_screen.dart';
import 'package:myapp/notifications_screen.dart';
import 'package:myapp/event_details_screen.dart';
import 'package:myapp/location_screen.dart';
import 'package:myapp/onboarding_screen.dart';
import 'package:myapp/splash_screen.dart';
import 'package:myapp/checkout_screen.dart';
import 'package:myapp/success_screen.dart';
import 'package:myapp/edit_profile_screen.dart';
import 'package:myapp/providers/auth_provider.dart';
import 'package:myapp/models/event_model.dart';

class AppRouter {
  final bool onboardingCompleted;
  final AuthProvider authProvider; // 1. Accept the AuthProvider
  late final GoRouter router;

  AppRouter({required this.onboardingCompleted, required this.authProvider}) {
    router = GoRouter(
      initialLocation: '/splash',
      // 2. Pass the authProvider directly as the refreshListenable
      refreshListenable: authProvider,
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) => const StartingScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignUpScreen(),
        ),
        GoRoute(
          path: '/otp',
          builder: (context, state) => const OtpVerificationScreen(),
        ),
        GoRoute(
          path: '/app',
          builder: (context, state) => const MainScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/edit-profile',
          builder: (context, state) => const EditProfileScreen(),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),
        GoRoute(
          path: '/details',
          builder: (context, state) {
            final event = state.extra as Event;
            return EventDetailsScreen(event: event);
          },
        ),
        GoRoute(
          path: '/location',
          builder: (context, state) => const LocationScreen(),
        ),
        GoRoute(
          path: '/checkout',
          builder: (context, state) => const CheckoutScreen(),
        ),
        GoRoute(
          path: '/success',
          builder: (context, state) => const SuccessScreen(),
        ),
      ],
      redirect: (context, state) {
        // 3. Use the authProvider field directly for redirection logic
        final isAuthenticated = authProvider.isAuthenticated;
        final location = state.matchedLocation;

        // Handle Onboarding (Highest Priority)
        final onOnboarding = location == '/onboarding';
        if (!onboardingCompleted) {
          return onOnboarding ? null : '/onboarding'; // Force to onboarding
        }
        if (onboardingCompleted && onOnboarding) {
          return '/'; // Already onboarded, send to starting page
        }

        // Splash screen is handled implicitly.
        if (location == '/splash') {
          return null;
        }

        // Handle Authentication
        final isAuthenticating = location == '/login' || location == '/signup' || location == '/';
        final privateRoutes = [
          '/app', '/profile', '/edit-profile', '/notifications', 
          '/details', '/location', '/checkout', '/success'
        ];

        if (!isAuthenticated && privateRoutes.contains(location)) {
          return '/'; // Redirect to starting page to let them login/signup
        }

        if (isAuthenticated && isAuthenticating) {
          return '/app'; // If user IS authenticated and tries to access public-only pages, redirect into app.
        }

        // No redirect needed
        return null;
      },
    );
  }
}