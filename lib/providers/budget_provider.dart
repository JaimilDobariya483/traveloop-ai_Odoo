import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:traveloop/models/expense.dart';
import 'package:traveloop/providers/auth_provider.dart';

class BudgetService {
  final SupabaseClient _supabase;

  BudgetService(this._supabase);

  Future<List<Expense>> getExpensesForTrip(String tripId) async {
    final response = await _supabase
        .from('expenses')
        .select()
        .eq('trip_id', tripId)
        .order('date', ascending: false);

    return (response as List).map((json) => Expense.fromJson(json)).toList();
  }

  Future<Expense> createExpense(Expense expense) async {
    final response = await _supabase
        .from('expenses')
        .insert(expense.toJson())
        .select()
        .single();
    return Expense.fromJson(response);
  }

  Future<void> deleteExpense(String expenseId) async {
    await _supabase.from('expenses').delete().eq('id', expenseId);
  }
}

final budgetServiceProvider = Provider<BudgetService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return BudgetService(supabase);
});

final tripExpensesProvider = FutureProvider.family<List<Expense>, String>((
  ref,
  tripId,
) async {
  final service = ref.watch(budgetServiceProvider);
  return service.getExpensesForTrip(tripId);
});

class BudgetNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> addExpense(Expense expense) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(budgetServiceProvider);
      await service.createExpense(expense);
      ref.invalidate(tripExpensesProvider(expense.tripId));
    });
  }

  Future<void> deleteExpense(String expenseId, String tripId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(budgetServiceProvider);
      await service.deleteExpense(expenseId);
      ref.invalidate(tripExpensesProvider(tripId));
    });
  }
}

final budgetNotifierProvider = AsyncNotifierProvider<BudgetNotifier, void>(() {
  return BudgetNotifier();
});
