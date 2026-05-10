import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:traveloop/models/activity.dart';
import 'package:traveloop/models/stop.dart';
import 'package:traveloop/providers/auth_provider.dart';
import 'package:traveloop/services/itinerary_service.dart';

final itineraryServiceProvider = Provider<ItineraryService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return ItineraryService(supabase);
});

// Stream of Stops for a specific trip
final tripStopsProvider = FutureProvider.family<List<Stop>, String>((
  ref,
  tripId,
) async {
  final service = ref.watch(itineraryServiceProvider);
  return service.getStopsForTrip(tripId);
});

// Stream of Activities for a specific stop
final stopActivitiesProvider =
    FutureProvider.family<List<TripActivity>, String>((ref, stopId) async {
      final service = ref.watch(itineraryServiceProvider);
      return service.getActivitiesForStop(stopId);
    });
