import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:traveloop/models/trip.dart';

class TripService {
  final SupabaseClient _supabase;

  TripService(this._supabase);

  Future<List<Trip>> getUserTrips(String userId) async {
    final response = await _supabase
        .from('trips')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => Trip.fromJson(json)).toList();
  }

  Future<Trip> getTripById(String tripId) async {
    final response = await _supabase
        .from('trips')
        .select()
        .eq('id', tripId)
        .single();

    return Trip.fromJson(response);
  }

  Future<Trip> createTrip(Trip trip) async {
    final response = await _supabase
        .from('trips')
        .insert(trip.toJson())
        .select()
        .single();

    return Trip.fromJson(response);
  }

  Future<Trip> updateTrip(Trip trip) async {
    final response = await _supabase
        .from('trips')
        .update(trip.toJson())
        .eq('id', trip.id)
        .select()
        .single();

    return Trip.fromJson(response);
  }

  Future<void> deleteTrip(String tripId) async {
    await _supabase.from('trips').delete().eq('id', tripId);
  }

  Future<void> cloneTrip(String sourceTripId, String targetUserId) async {
    // 1. Fetch source trip
    final sourceTrip = await getTripById(sourceTripId);

    // 2. Create new trip for target user
    final newTripJson = sourceTrip.toJson();
    newTripJson.remove('id');
    newTripJson['user_id'] = targetUserId;
    newTripJson['title'] = '${sourceTrip.title} (Clone)';
    newTripJson['is_public'] = false;

    final newTripResponse = await _supabase
        .from('trips')
        .insert(newTripJson)
        .select()
        .single();
    final String newTripId = newTripResponse['id'];

    // 3. Fetch source stops
    final stopsResponse = await _supabase
        .from('stops')
        .select()
        .eq('trip_id', sourceTripId);
    final List sourceStops = stopsResponse as List;

    for (var stopJson in sourceStops) {
      final String oldStopId = stopJson['id'];

      // 4. Create new stop
      final newStopJson = Map<String, dynamic>.from(stopJson);
      newStopJson.remove('id');
      newStopJson['trip_id'] = newTripId;

      final newStopResponse = await _supabase
          .from('stops')
          .insert(newStopJson)
          .select()
          .single();
      final String newStopId = newStopResponse['id'];

      // 5. Fetch and clone activities for this stop
      final activitiesResponse = await _supabase
          .from('activities')
          .select()
          .eq('stop_id', oldStopId);
      final List sourceActivities = activitiesResponse as List;

      if (sourceActivities.isNotEmpty) {
        final List<Map<String, dynamic>> newActivitiesJson = sourceActivities
            .map((act) {
              final a = Map<String, dynamic>.from(act);
              a.remove('id');
              a['stop_id'] = newStopId;
              return a;
            })
            .toList();

        await _supabase.from('activities').insert(newActivitiesJson);
      }
    }
  }
}
