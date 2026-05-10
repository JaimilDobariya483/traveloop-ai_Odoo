import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:traveloop/models/note.dart';
import 'package:traveloop/providers/auth_provider.dart';

class NoteService {
  final SupabaseClient _supabase;

  NoteService(this._supabase);

  Future<List<TripNote>> getNotesForTrip(String tripId) async {
    final response = await _supabase
        .from('notes')
        .select()
        .eq('trip_id', tripId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => TripNote.fromJson(json)).toList();
  }

  Future<TripNote> createNote(TripNote note) async {
    final response = await _supabase
        .from('notes')
        .insert(note.toJson())
        .select()
        .single();
    return TripNote.fromJson(response);
  }

  Future<void> deleteNote(String noteId) async {
    await _supabase.from('notes').delete().eq('id', noteId);
  }
}

final noteServiceProvider = Provider<NoteService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return NoteService(supabase);
});

final tripNotesProvider = FutureProvider.family<List<TripNote>, String>((
  ref,
  tripId,
) async {
  final service = ref.watch(noteServiceProvider);
  return service.getNotesForTrip(tripId);
});

class NoteNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> createNote(TripNote note) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(noteServiceProvider);
      await service.createNote(note);
      ref.invalidate(tripNotesProvider(note.tripId));
    });
  }

  Future<void> deleteNote(String noteId, String tripId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(noteServiceProvider);
      await service.deleteNote(noteId);
      ref.invalidate(tripNotesProvider(tripId));
    });
  }
}

final noteNotifierProvider = AsyncNotifierProvider<NoteNotifier, void>(() {
  return NoteNotifier();
});
