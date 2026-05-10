import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:traveloop/providers/auth_provider.dart';

import 'package:traveloop/models/trip.dart';
import 'package:traveloop/screens/auth/login_screen.dart';
import 'package:traveloop/screens/auth/register_screen.dart';
import 'package:traveloop/screens/auth/forgot_password_screen.dart';
import 'package:traveloop/screens/home/dashboard_screen.dart';
import 'package:traveloop/screens/trip/create_trip_screen.dart';
import 'package:traveloop/screens/trip/my_trips_screen.dart';
import 'package:traveloop/screens/trip/itinerary_builder_screen.dart';
import 'package:traveloop/screens/trip/public_itinerary_screen.dart';
import 'package:traveloop/screens/tools/budgeting_screen.dart';
import 'package:traveloop/screens/tools/packing_screen.dart';
import 'package:traveloop/screens/tools/notes_screen.dart';
import 'package:traveloop/screens/discovery/city_detail_screen.dart';
import 'package:traveloop/screens/admin/admin_dashboard.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuth = authState.value?.session != null;
      final isLoggingIn =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password';

      final isPublicRoute = state.matchedLocation.startsWith(
        '/public-itinerary/',
      );

      if (!isAuth && !isLoggingIn && !isPublicRoute) {
        return '/login';
      }

      if (isAuth && isLoggingIn) {
        return '/';
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) =>
            const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (BuildContext context, GoRouterState state) =>
            const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (BuildContext context, GoRouterState state) =>
            const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) =>
            const DashboardScreen(),
      ),
      GoRoute(
        path: '/create-trip',
        builder: (BuildContext context, GoRouterState state) {
          final trip = state.extra as Trip?;
          final initialTitle = state.uri.queryParameters['title'];
          return CreateTripScreen(trip: trip, initialTitle: initialTitle);
        },
      ),
      GoRoute(
        path: '/my-trips',
        builder: (BuildContext context, GoRouterState state) =>
            const MyTripsScreen(),
      ),
      GoRoute(
        path: '/itinerary/:id',
        builder: (BuildContext context, GoRouterState state) {
          final tripId = state.pathParameters['id']!;
          return ItineraryBuilderScreen(tripId: tripId);
        },
      ),
      GoRoute(
        path: '/public-itinerary/:id',
        builder: (BuildContext context, GoRouterState state) {
          final tripId = state.pathParameters['id']!;
          return PublicItineraryScreen(tripId: tripId);
        },
      ),
      GoRoute(
        path: '/budget/:id',
        builder: (BuildContext context, GoRouterState state) {
          final tripId = state.pathParameters['id']!;
          return BudgetingScreen(tripId: tripId);
        },
      ),
      GoRoute(
        path: '/packing/:id',
        builder: (BuildContext context, GoRouterState state) {
          final tripId = state.pathParameters['id']!;
          return PackingScreen(tripId: tripId);
        },
      ),
      GoRoute(
        path: '/notes/:id',
        builder: (BuildContext context, GoRouterState state) {
          final tripId = state.pathParameters['id']!;
          return NotesScreen(tripId: tripId);
        },
      ),
      GoRoute(
        path: '/city-detail/:name/:country',
        builder: (BuildContext context, GoRouterState state) {
          final name = state.pathParameters['name']!;
          final country = state.pathParameters['country']!;
          return CityDetailScreen(cityName: name, countryName: country);
        },
      ),
      GoRoute(
        path: '/admin',
        builder: (BuildContext context, GoRouterState state) =>
            const AdminDashboardScreen(),
      ),
    ],
  );
});
