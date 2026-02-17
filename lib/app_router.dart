
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

class AppRouter {
  final bool onboardingCompleted;
  late final GoRouter router;

  AppRouter({required this.onboardingCompleted}) {
    router = GoRouter(
      initialLocation: '/splash',
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
          builder: (context, state) => const EventDetailsScreen(),
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
        // If the app is still initializing (showing splash), don't redirect.
        if (state.matchedLocation == '/splash') {
          return null;
        }

        // Check if the user is on the onboarding path.
        final onOnboarding = state.matchedLocation == '/onboarding';

        // If onboarding is complete, but the user is trying to access the onboarding screen,
        // redirect them to the starting screen.
        if (onboardingCompleted && onOnboarding) {
          return '/';
        }

        // If onboarding is NOT complete, and the user is NOT on the onboarding screen,
        // redirect them to the onboarding screen.
        if (!onboardingCompleted && !onOnboarding) {
          return '/onboarding';
        }

        // Otherwise, no redirection is needed.
        return null;
      },
    );
  }
}
