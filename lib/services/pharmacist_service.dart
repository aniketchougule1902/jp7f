import 'package:jeevanpatra/config/supabase_config.dart';
import 'package:jeevanpatra/models/pharmacist_model.dart';

class PharmacistService {
  final _client = SupabaseConfig.client;

  /// Fetches the pharmacist profile by auth [userId].
  Future<({PharmacistModel? pharmacist, String? error})>
      getPharmacistProfile(String userId) async {
    try {
      final data = await _client
          .from('pharmacist_profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      if (data == null) {
        return (pharmacist: null, error: 'Profile not found.');
      }
      return (pharmacist: PharmacistModel.fromJson(data), error: null);
    } catch (e) {
      return (pharmacist: null, error: e.toString());
    }
  }

  /// Creates or updates the pharmacist profile for [userId].
  Future<({PharmacistModel? pharmacist, String? error})>
      updatePharmacistProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client
          .from('pharmacist_profiles')
          .upsert({'user_id': userId, ...data})
          .select()
          .single();
      return (pharmacist: PharmacistModel.fromJson(response), error: null);
    } catch (e) {
      return (pharmacist: null, error: e.toString());
    }
  }

  /// Returns dashboard stats for a pharmacist.
  Future<({Map<String, dynamic>? stats, String? error})> getPharmacistStats(
      String userId) async {
    try {
      final now = DateTime.now();
      final todayStart =
          DateTime(now.year, now.month, now.day).toIso8601String();

      // Today's dispensals
      final todayDispensals = await _client
          .from('medicine_dispensals')
          .select('total_price')
          .eq('pharmacist_id', userId)
          .gte('dispensed_at', todayStart)
          .eq('is_returned', false);

      // All-time dispensals
      final allDispensals = await _client
          .from('medicine_dispensals')
          .select('total_price')
          .eq('pharmacist_id', userId)
          .eq('is_returned', false);

      double todayRevenue = 0;
      for (final row in todayDispensals as List) {
        todayRevenue += (row['total_price'] as num?)?.toDouble() ?? 0;
      }

      double totalRevenue = 0;
      for (final row in allDispensals as List) {
        totalRevenue += (row['total_price'] as num?)?.toDouble() ?? 0;
      }

      final ordersFulfilled = (allDispensals).length;

      // Low-stock count
      final lowStock = await _client
          .from('pharmacy_inventory')
          .select('id')
          .eq('pharmacist_id', userId)
          .eq('is_low_stock', true);

      // Items expiring within 30 days
      final expiryThreshold =
          now.add(const Duration(days: 30)).toIso8601String();
      final expiring = await _client
          .from('pharmacy_inventory')
          .select('id')
          .eq('pharmacist_id', userId)
          .lte('expiry_date', expiryThreshold)
          .gte('expiry_date', now.toIso8601String());

      return (
        stats: {
          'today_revenue': todayRevenue,
          'total_revenue': totalRevenue,
          'orders_fulfilled': ordersFulfilled,
          'low_stock_count': (lowStock as List).length,
          'expiring_count': (expiring as List).length,
        },
        error: null,
      );
    } catch (e) {
      return (stats: null, error: e.toString());
    }
  }
}
