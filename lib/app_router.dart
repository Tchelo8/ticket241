
import 'package:go_router/go_router.dart';
import 'package:myapp/main_screen.dart';
import 'package:myapp/otp_verification_screen.dart';
import 'package:myapp/starting_screen.dart';
import 'package:myapp/login_screen.dart';
import 'package:myapp/signup_screen.dart';
import 'package:myapp/profile_screen.dart'; // Corrected import
import 'package:myapp/notifications_screen.dart';
import 'package:myapp/event_details_screen.dart';
import 'package:myapp/location_screen.dart';
import 'package:myapp/onboarding_screen.dart';
import 'package:myapp/splash_screen.dart';
import 'package:myapp/checkout_screen.dart';
import 'package:myapp/success_screen.dart';
import 'package:myapp/edit_profile_screen.dart';

// GoRouter configuration
final router = GoRouter(
  initialLocation: '/splash', // Start at the splash screen
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
      path: '/app', // This will be the MainScreen with the bottom nav
      builder: (context, state) => const MainScreen(),
    ),
     GoRoute(
      path: '/profile', // Corrected path
      builder: (context, state) => const ProfileScreen(), // Corrected Widget
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
);
