import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jeevanpatra/config/supabase_config.dart';
import 'package:jeevanpatra/models/dispensal_model.dart';
import 'package:jeevanpatra/models/inventory_model.dart';
import 'package:jeevanpatra/models/pharmacist_model.dart';
import 'package:jeevanpatra/providers/auth_provider.dart';
import 'package:jeevanpatra/services/inventory_service.dart';
import 'package:jeevanpatra/services/pharmacist_service.dart';

// ── Service singletons ─────────────────────────────────────────────────
final pharmacistServiceProvider =
    Provider<PharmacistService>((_) => PharmacistService());
final inventoryServiceProvider =
    Provider<InventoryService>((_) => InventoryService());

// ── Pharmacist profile ─────────────────────────────────────────────────
final pharmacistProfileProvider =
    FutureProvider<PharmacistModel?>((ref) async {
  final user = ref.watch(authNotifierProvider);
  if (user == null) return null;
  final result = await ref
      .read(pharmacistServiceProvider)
      .getPharmacistProfile(user.id);
  return result.pharmacist;
});

// ── Pharmacist stats ───────────────────────────────────────────────────
final pharmacistStatsProvider =
    FutureProvider<Map<String, dynamic>?>((ref) async {
  final user = ref.watch(authNotifierProvider);
  if (user == null) return null;
  final result = await ref
      .read(pharmacistServiceProvider)
      .getPharmacistStats(user.id);
  return result.stats;
});

// ── Inventory ──────────────────────────────────────────────────────────
final inventoryProvider =
    FutureProvider<List<InventoryModel>>((ref) async {
  final user = ref.watch(authNotifierProvider);
  if (user == null) return [];
  final result =
      await ref.read(inventoryServiceProvider).getInventory(user.id);
  return result.items;
});

// ── Dispensals (recent) ────────────────────────────────────────────────
final dispensalsProvider =
    FutureProvider<List<DispensalModel>>((ref) async {
  final user = ref.watch(authNotifierProvider);
  if (user == null) return [];
  return _fetchDispensals(user.id);
});

/// Helper that queries dispensals directly from Supabase.
Future<List<DispensalModel>> _fetchDispensals(String pharmacistId) async {
  try {
    final data = await SupabaseConfig.client
        .from('medicine_dispensals')
        .select()
        .eq('pharmacist_id', pharmacistId)
        .order('dispensed_at', ascending: false);
    return (data as List).map((e) => DispensalModel.fromJson(e)).toList();
  } catch (_) {
    return [];
  }
}
