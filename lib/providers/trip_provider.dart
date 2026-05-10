import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:traveloop/models/trip.dart';
import 'package:traveloop/providers/auth_provider.dart';
import 'package:traveloop/services/trip_service.dart';

final tripServiceProvider = Provider<TripService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return TripService(supabase);
});

// Stream of the current user's trips
final userTripsProvider = FutureProvider<List<Trip>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final tripService = ref.watch(tripServiceProvider);
  return tripService.getUserTrips(user.id);
});

final tripByIdProvider = FutureProvider.family<Trip, String>((
  ref,
  tripId,
) async {
  final tripService = ref.watch(tripServiceProvider);
  return tripService.getTripById(tripId);
});

class TripNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> createTrip(Trip trip) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final tripService = ref.read(tripServiceProvider);
      await tripService.createTrip(trip);
      ref.invalidate(userTripsProvider);
    });
  }

  Future<void> updateTrip(Trip trip) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final tripService = ref.read(tripServiceProvider);
      await tripService.updateTrip(trip);
      ref.invalidate(userTripsProvider);
      ref.invalidate(tripByIdProvider(trip.id));
    });
  }

  Future<void> deleteTrip(String tripId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final tripService = ref.read(tripServiceProvider);
      await tripService.deleteTrip(tripId);
      ref.invalidate(userTripsProvider);
    });
  }

  Future<void> cloneTrip(String sourceTripId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(currentUserProvider);
      if (user == null) throw Exception('Must be logged in to clone a trip');

      final tripService = ref.read(tripServiceProvider);
      await tripService.cloneTrip(sourceTripId, user.id);
      ref.invalidate(userTripsProvider);
    });
  }
}

final tripNotifierProvider = AsyncNotifierProvider<TripNotifier, void>(() {
  return TripNotifier();
});
