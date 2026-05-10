import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:traveloop/models/activity.dart';
import 'package:traveloop/models/stop.dart';

class ItineraryService {
  final SupabaseClient _supabase;

  ItineraryService(this._supabase);

  // Stops
  Future<List<Stop>> getStopsForTrip(String tripId) async {
    final response = await _supabase
        .from('stops')
        .select()
        .eq('trip_id', tripId)
        .order('order_index', ascending: true);

    return (response as List).map((json) => Stop.fromJson(json)).toList();
  }

  Future<Stop> createStop(Stop stop) async {
    final response = await _supabase
        .from('stops')
        .insert(stop.toJson())
        .select()
        .single();
    return Stop.fromJson(response);
  }

  Future<void> updateStopOrder(String stopId, int newOrderIndex) async {
    await _supabase
        .from('stops')
        .update({'order_index': newOrderIndex})
        .eq('id', stopId);
  }

  Future<void> deleteStop(String stopId) async {
    await _supabase.from('stops').delete().eq('id', stopId);
  }

  // Activities
  Future<List<TripActivity>> getActivitiesForStop(String stopId) async {
    final response = await _supabase
        .from('activities')
        .select()
        .eq('stop_id', stopId)
        .order('activity_date', ascending: true, nullsFirst: false)
        .order('start_time', ascending: true, nullsFirst: false);

    return (response as List)
        .map((json) => TripActivity.fromJson(json))
        .toList();
  }

  Future<TripActivity> createActivity(TripActivity activity) async {
    final response = await _supabase
        .from('activities')
        .insert(activity.toJson())
        .select()
        .single();
    return TripActivity.fromJson(response);
  }

  Future<void> deleteActivity(String activityId) async {
    await _supabase.from('activities').delete().eq('id', activityId);
  }
}
