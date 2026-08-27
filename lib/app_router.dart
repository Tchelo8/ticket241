import 'package:go_router/go_router.dart';
import 'package:myapp/forgot_password_screen.dart';
import 'package:myapp/main_screen.dart';
import 'package:myapp/models/ticket_model.dart';
import 'package:myapp/otp_verification_screen.dart';
import 'package:myapp/starting_screen.dart';
import 'package:myapp/login_screen.dart';
import 'package:myapp/signup_screen.dart';
import 'package:myapp/profile_screen.dart';
import 'package:myapp/notifications_screen.dart';
import 'package:myapp/event_details_screen.dart';
import 'package:myapp/onboarding_screen.dart';
import 'package:myapp/splash_screen.dart';
import 'package:myapp/checkout_screen.dart';
import 'package:myapp/success_screen.dart';
import 'package:myapp/ussd_waiting_screen.dart';
import 'package:myapp/ticket_qr_screen.dart';
import 'package:myapp/pdf_viewer_screen.dart';
import 'package:myapp/edit_profile_screen.dart';
import 'package:myapp/providers/auth_provider.dart';
import 'package:myapp/models/event_model.dart';

class AppRouter {
  final bool onboardingCompleted;
  final AuthProvider authProvider;
  late final GoRouter router;

  AppRouter({required this.onboardingCompleted, required this.authProvider}) {
    router = GoRouter(
      initialLocation: '/splash',
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
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignUpScreen(),
        ),
        GoRoute(
          path: '/otp-verification', // Updated route
          builder: (context, state) {
            // Extract phone number from extra
            final extra = state.extra as Map<String, dynamic>?;
            final phone = extra?['phone'] as String?;
            return OtpVerificationScreen(phone: phone);
          },
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
          path: '/checkout',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            final event = extra['event'] as Event;
            final tickets = extra['tickets'] as List<EventTicket>;
            return CheckoutScreen(event: event, tickets: tickets);
          },
        ),
        GoRoute(
          path: '/ussd-waiting',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            return UssdWaitingScreen(
              event: extra['event'] as Event,
              amount: extra['amount'] as double,
              method: extra['method'] as PaymentMethod,
              phone: extra['phone'] as String,
              tickets: extra['tickets'] as List<EventTicket>,
            );
          },
        ),
        GoRoute(
          path: '/success',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return SuccessScreen(
              event: extra?['event'] as Event?,
              amount: extra?['amount'] as double?,
              method: extra?['method'] as PaymentMethod?,
              tickets: extra?['tickets'] as List<EventTicket>?,
            );
          },
        ),
        GoRoute(
          path: '/ticket-qr',
          builder: (context, state) {
            final ticket = state.extra as EventTicket;
            return TicketQrScreen(ticket: ticket);
          },
        ),
        GoRoute(
          path: '/pdf-viewer',
          builder: (context, state) => const PdfViewerScreen(),
        ),
      ],
      redirect: (context, state) {
        final isAuthenticated = authProvider.isAuthenticated;
        final location = state.matchedLocation;

        final onOnboarding = location == '/onboarding';
        if (!onboardingCompleted) {
          return onOnboarding ? null : '/onboarding';
        }
        if (onboardingCompleted && onOnboarding) {
          return '/';
        }

        if (location == '/splash') {
          return null;
        }

        final isAuthenticating = [
          '/', '/login', '/signup', '/forgot-password', '/otp-verification'
        ].contains(location);

        final privateRoutes = [
          '/app', '/profile', '/edit-profile', '/notifications',
          '/details', '/checkout', '/ussd-waiting', '/success',
          '/ticket-qr', '/pdf-viewer',
        ];

        if (!isAuthenticated && privateRoutes.contains(location)) {
          return '/';
        }

        if (isAuthenticated && isAuthenticating) {
          return '/app';
        }

        return null;
      },
    );
  }
}
