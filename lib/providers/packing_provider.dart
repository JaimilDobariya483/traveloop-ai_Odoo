import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:traveloop/models/packing_item.dart';
import 'package:traveloop/providers/auth_provider.dart';

class PackingService {
  final SupabaseClient _supabase;

  PackingService(this._supabase);

  Future<List<PackingItem>> getPackingItems(String tripId) async {
    final response = await _supabase
        .from('packing_items')
        .select()
        .eq('trip_id', tripId)
        .order('category', ascending: true);

    return (response as List)
        .map((json) => PackingItem.fromJson(json))
        .toList();
  }

  Future<PackingItem> createPackingItem(PackingItem item) async {
    final response = await _supabase
        .from('packing_items')
        .insert(item.toJson())
        .select()
        .single();
    return PackingItem.fromJson(response);
  }

  Future<void> updatePackingItem(PackingItem item) async {
    await _supabase
        .from('packing_items')
        .update(item.toJson())
        .eq('id', item.id);
  }

  Future<void> deletePackingItem(String itemId) async {
    await _supabase.from('packing_items').delete().eq('id', itemId);
  }

  Future<void> resetChecklist(String tripId) async {
    await _supabase
        .from('packing_items')
        .update({'is_packed': false})
        .eq('trip_id', tripId);
  }
}

final packingServiceProvider = Provider<PackingService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return PackingService(supabase);
});

final tripPackingItemsProvider =
    FutureProvider.family<List<PackingItem>, String>((ref, tripId) async {
      final service = ref.watch(packingServiceProvider);
      return service.getPackingItems(tripId);
    });

class PackingNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> addItem(PackingItem item) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(packingServiceProvider);
      await service.createPackingItem(item);
      ref.invalidate(tripPackingItemsProvider(item.tripId));
    });
  }

  Future<void> toggleItem(PackingItem item) async {
    final updatedItem = item.copyWith(isPacked: !item.isPacked);
    final service = ref.read(packingServiceProvider);
    await service.updatePackingItem(updatedItem);
    ref.invalidate(tripPackingItemsProvider(item.tripId));
  }

  Future<void> deleteItem(String itemId, String tripId) async {
    final service = ref.read(packingServiceProvider);
    await service.deletePackingItem(itemId);
    ref.invalidate(tripPackingItemsProvider(tripId));
  }

  Future<void> resetAll(String tripId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(packingServiceProvider);
      await service.resetChecklist(tripId);
      ref.invalidate(tripPackingItemsProvider(tripId));
    });
  }
}

final packingNotifierProvider = AsyncNotifierProvider<PackingNotifier, void>(
  () {
    return PackingNotifier();
  },
);
