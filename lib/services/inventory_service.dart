import 'package:jeevanpatra/config/supabase_config.dart';
import 'package:jeevanpatra/models/dispensal_model.dart';
import 'package:jeevanpatra/models/inventory_model.dart';

class InventoryService {
  final _client = SupabaseConfig.client;

  /// Returns all inventory items for a pharmacist.
  Future<({List<InventoryModel> items, String? error})> getInventory(
      String pharmacistId) async {
    try {
      final data = await _client
          .from('pharmacy_inventory')
          .select()
          .eq('pharmacist_id', pharmacistId)
          .order('medicine_name');
      final items =
          (data as List).map((e) => InventoryModel.fromJson(e)).toList();
      return (items: items, error: null);
    } catch (e) {
      return (items: <InventoryModel>[], error: e.toString());
    }
  }

  /// Adds a new inventory item.
  Future<({InventoryModel? item, String? error})> addInventoryItem(
      Map<String, dynamic> item) async {
    try {
      final response = await _client
          .from('pharmacy_inventory')
          .insert(item)
          .select()
          .single();
      return (item: InventoryModel.fromJson(response), error: null);
    } catch (e) {
      return (item: null, error: e.toString());
    }
  }

  /// Updates an existing inventory item.
  Future<({InventoryModel? item, String? error})> updateInventoryItem(
    String itemId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client
          .from('pharmacy_inventory')
          .update(data)
          .eq('id', itemId)
          .select()
          .single();
      return (item: InventoryModel.fromJson(response), error: null);
    } catch (e) {
      return (item: null, error: e.toString());
    }
  }

  /// Deletes an inventory item.
  Future<String?> deleteInventoryItem(String itemId) async {
    try {
      await _client.from('pharmacy_inventory').delete().eq('id', itemId);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Returns items flagged as low stock.
  Future<({List<InventoryModel> items, String? error})> getLowStockItems(
      String pharmacistId) async {
    try {
      final data = await _client
          .from('pharmacy_inventory')
          .select()
          .eq('pharmacist_id', pharmacistId)
          .eq('is_low_stock', true)
          .order('medicine_name');
      final items =
          (data as List).map((e) => InventoryModel.fromJson(e)).toList();
      return (items: items, error: null);
    } catch (e) {
      return (items: <InventoryModel>[], error: e.toString());
    }
  }

  /// Returns items expiring within 30 days.
  Future<({List<InventoryModel> items, String? error})> getExpiringItems(
      String pharmacistId) async {
    try {
      final now = DateTime.now();
      final threshold = now.add(const Duration(days: 30)).toIso8601String();
      final data = await _client
          .from('pharmacy_inventory')
          .select()
          .eq('pharmacist_id', pharmacistId)
          .lte('expiry_date', threshold)
          .gte('expiry_date', now.toIso8601String())
          .order('expiry_date');
      final items =
          (data as List).map((e) => InventoryModel.fromJson(e)).toList();
      return (items: items, error: null);
    } catch (e) {
      return (items: <InventoryModel>[], error: e.toString());
    }
  }

  /// Dispenses a medicine, creating a dispensal record and decrementing stock.
  Future<({DispensalModel? dispensal, String? error})> dispenseMedicine({
    required String pharmacistId,
    required String patientId,
    required String prescriptionId,
    String? medicineId,
    String? medicineName,
    required int quantity,
    required double pricePerUnit,
    String? batchNumber,
  }) async {
    try {
      final dispensalData = {
        'pharmacist_id': pharmacistId,
        'patient_id': patientId,
        'prescription_id': prescriptionId,
        'medicine_id': medicineId,
        'medicine_name': medicineName,
        'quantity': quantity,
        'price_per_unit': pricePerUnit,
        'total_price': quantity * pricePerUnit,
        'batch_number': batchNumber,
        'dispensed_at': DateTime.now().toIso8601String(),
      };

      final response = await _client
          .from('medicine_dispensals')
          .insert(dispensalData)
          .select()
          .single();

      // Decrement inventory
      if (medicineId != null) {
        final inventory = await _client
            .from('pharmacy_inventory')
            .select('quantity')
            .eq('pharmacist_id', pharmacistId)
            .eq('medicine_id', medicineId)
            .maybeSingle();

        if (inventory != null) {
          final currentQty = inventory['quantity'] as int;
          await _client
              .from('pharmacy_inventory')
              .update({'quantity': currentQty - quantity})
              .eq('pharmacist_id', pharmacistId)
              .eq('medicine_id', medicineId);
        }
      }

      return (dispensal: DispensalModel.fromJson(response), error: null);
    } catch (e) {
      return (dispensal: null, error: e.toString());
    }
  }

  /// Marks a dispensal as returned and restores inventory stock.
  Future<String?> returnMedicine(String dispensalId) async {
    try {
      final dispensal = await _client
          .from('medicine_dispensals')
          .select()
          .eq('id', dispensalId)
          .single();

      await _client.from('medicine_dispensals').update({
        'is_returned': true,
        'returned_at': DateTime.now().toIso8601String(),
      }).eq('id', dispensalId);

      // Restore inventory stock
      final medicineId = dispensal['medicine_id'];
      if (medicineId != null) {
        final pharmacistId = dispensal['pharmacist_id'] as String;
        final returnedQty = dispensal['quantity'] as int;

        final inventory = await _client
            .from('pharmacy_inventory')
            .select('quantity')
            .eq('pharmacist_id', pharmacistId)
            .eq('medicine_id', medicineId)
            .maybeSingle();

        if (inventory != null) {
          final currentQty = inventory['quantity'] as int;
          await _client
              .from('pharmacy_inventory')
              .update({'quantity': currentQty + returnedQty})
              .eq('pharmacist_id', pharmacistId)
              .eq('medicine_id', medicineId);
        }
      }

      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
