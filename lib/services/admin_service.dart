import 'package:jeevanpatra/config/supabase_config.dart';
import 'package:jeevanpatra/models/medicine_model.dart';
import 'package:jeevanpatra/models/user_model.dart';

class AdminService {
  final _client = SupabaseConfig.client;

  // ── Platform Stats ───────────────────────────────────────────────────

  /// Returns high-level platform statistics.
  Future<({Map<String, dynamic>? stats, String? error})>
      getPlatformStats() async {
    try {
      final patients = await _client
          .from('users')
          .select('id')
          .eq('user_type', 'patient');
      final doctors = await _client
          .from('users')
          .select('id')
          .eq('user_type', 'doctor');
      final pharmacists = await _client
          .from('users')
          .select('id')
          .eq('user_type', 'pharmacist');

      final now = DateTime.now();
      final thirtyDaysAgo =
          now.subtract(const Duration(days: 30)).toIso8601String();

      final newPatients = await _client
          .from('users')
          .select('id')
          .eq('user_type', 'patient')
          .gte('created_at', thirtyDaysAgo);
      final newDoctors = await _client
          .from('users')
          .select('id')
          .eq('user_type', 'doctor')
          .gte('created_at', thirtyDaysAgo);
      final newPharmacists = await _client
          .from('users')
          .select('id')
          .eq('user_type', 'pharmacist')
          .gte('created_at', thirtyDaysAgo);

      return (
        stats: {
          'total_patients': (patients as List).length,
          'total_doctors': (doctors as List).length,
          'total_pharmacists': (pharmacists as List).length,
          'new_patients_30d': (newPatients as List).length,
          'new_doctors_30d': (newDoctors as List).length,
          'new_pharmacists_30d': (newPharmacists as List).length,
        },
        error: null,
      );
    } catch (e) {
      return (stats: null, error: e.toString());
    }
  }

  // ── Verification ─────────────────────────────────────────────────────

  /// Returns pending verifications, optionally filtered by user type.
  Future<({List<Map<String, dynamic>> verifications, String? error})>
      getPendingVerifications({String? userType}) async {
    try {
      List<dynamic> results = [];

      if (userType == null || userType == 'doctor') {
        final doctors = await _client
            .from('doctor_profiles')
            .select('*, users!inner(full_name, email)')
            .eq('verification_status', 'pending');
        results.addAll(doctors as List);
      }

      if (userType == null || userType == 'pharmacist') {
        final pharmacists = await _client
            .from('pharmacist_profiles')
            .select('*, users!inner(full_name, email)')
            .eq('verification_status', 'pending');
        results.addAll(pharmacists as List);
      }

      return (
        verifications: results.cast<Map<String, dynamic>>(),
        error: null,
      );
    } catch (e) {
      return (verifications: <Map<String, dynamic>>[], error: e.toString());
    }
  }

  /// Approves a doctor or pharmacist verification.
  Future<String?> approveVerification(String userId, String adminId) async {
    try {
      final update = {
        'verification_status': 'approved',
        'verified_by': adminId,
        'verified_at': DateTime.now().toIso8601String(),
      };

      // Try doctor first, then pharmacist.
      final doctor = await _client
          .from('doctor_profiles')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();

      if (doctor != null) {
        await _client
            .from('doctor_profiles')
            .update(update)
            .eq('user_id', userId);
      } else {
        await _client
            .from('pharmacist_profiles')
            .update(update)
            .eq('user_id', userId);
      }

      await _client
          .from('users')
          .update({'is_verified': true}).eq('id', userId);

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Rejects a verification with a reason.
  Future<String?> rejectVerification(
    String userId,
    String adminId,
    String reason,
  ) async {
    try {
      final update = {
        'verification_status': 'rejected',
        'verification_reason': reason,
        'verified_by': adminId,
        'verified_at': DateTime.now().toIso8601String(),
      };

      final doctor = await _client
          .from('doctor_profiles')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();

      if (doctor != null) {
        await _client
            .from('doctor_profiles')
            .update(update)
            .eq('user_id', userId);
      } else {
        await _client
            .from('pharmacist_profiles')
            .update(update)
            .eq('user_id', userId);
      }

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Reverts a verification decision, sending it back to pending.
  Future<String?> revertVerification(String userId) async {
    try {
      final revert = {
        'verification_status': 'pending',
        'verification_reason': null,
        'verified_by': null,
        'verified_at': null,
      };

      final doctor = await _client
          .from('doctor_profiles')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();

      if (doctor != null) {
        await _client
            .from('doctor_profiles')
            .update(revert)
            .eq('user_id', userId);
      } else {
        await _client
            .from('pharmacist_profiles')
            .update(revert)
            .eq('user_id', userId);
      }

      await _client
          .from('users')
          .update({'is_verified': false}).eq('id', userId);

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Returns the verification history for an admin.
  Future<({List<Map<String, dynamic>> history, String? error})>
      getVerificationHistory(String adminId) async {
    try {
      final doctors = await _client
          .from('doctor_profiles')
          .select('*, users!inner(full_name, email)')
          .eq('verified_by', adminId)
          .not('verified_at', 'is', null)
          .order('verified_at', ascending: false);

      final pharmacists = await _client
          .from('pharmacist_profiles')
          .select('*, users!inner(full_name, email)')
          .eq('verified_by', adminId)
          .not('verified_at', 'is', null)
          .order('verified_at', ascending: false);

      final history = [
        ...(doctors as List).cast<Map<String, dynamic>>(),
        ...(pharmacists as List).cast<Map<String, dynamic>>(),
      ];

      history.sort((a, b) {
        final aDate = a['verified_at'] as String? ?? '';
        final bDate = b['verified_at'] as String? ?? '';
        return bDate.compareTo(aDate);
      });

      return (history: history, error: null);
    } catch (e) {
      return (history: <Map<String, dynamic>>[], error: e.toString());
    }
  }

  // ── System Logs ──────────────────────────────────────────────────────

  /// Fetches system logs with optional filters.
  Future<({List<Map<String, dynamic>> logs, String? error})> getSystemLogs({
    String? logLevel,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _client.from('system_logs').select();
      if (logLevel != null) query = query.eq('log_level', logLevel);
      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }
      final data = await query.order('created_at', ascending: false);
      return (
        logs: (data as List).cast<Map<String, dynamic>>(),
        error: null,
      );
    } catch (e) {
      return (logs: <Map<String, dynamic>>[], error: e.toString());
    }
  }

  // ── Medicine Catalog ─────────────────────────────────────────────────

  /// Returns the medicine catalog with optional search and category filter.
  Future<({List<MedicineModel> medicines, String? error})> getMedicineCatalog({
    String? search,
    String? category,
  }) async {
    try {
      var query = _client.from('medicines').select();
      if (search != null && search.isNotEmpty) {
        query = query.or(
            'product_name.ilike.%$search%,composition.ilike.%$search%');
      }
      if (category != null) query = query.eq('category', category);

      final data = await query.order('product_name');
      final medicines =
          (data as List).map((e) => MedicineModel.fromJson(e)).toList();
      return (medicines: medicines, error: null);
    } catch (e) {
      return (medicines: <MedicineModel>[], error: e.toString());
    }
  }

  /// Adds a new medicine to the catalog.
  Future<({MedicineModel? medicine, String? error})> addMedicine(
      Map<String, dynamic> medicine) async {
    try {
      final response =
          await _client.from('medicines').insert(medicine).select().single();
      return (medicine: MedicineModel.fromJson(response), error: null);
    } catch (e) {
      return (medicine: null, error: e.toString());
    }
  }

  /// Updates a medicine entry.
  Future<({MedicineModel? medicine, String? error})> updateMedicine(
    String medicineId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client
          .from('medicines')
          .update(data)
          .eq('id', medicineId)
          .select()
          .single();
      return (medicine: MedicineModel.fromJson(response), error: null);
    } catch (e) {
      return (medicine: null, error: e.toString());
    }
  }

  /// Deletes a medicine from the catalog.
  Future<String?> deleteMedicine(String medicineId) async {
    try {
      await _client.from('medicines').delete().eq('id', medicineId);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Inserts multiple medicines at once.
  Future<({int inserted, String? error})> bulkUploadMedicines(
      List<Map<String, dynamic>> medicines) async {
    try {
      await _client.from('medicines').insert(medicines);
      return (inserted: medicines.length, error: null);
    } catch (e) {
      return (inserted: 0, error: e.toString());
    }
  }

  // ── User Management ──────────────────────────────────────────────────

  /// Returns all users with optional filters and pagination.
  Future<({List<UserModel> users, int total, String? error})> getAllUsersAdmin({
    String? userType,
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      var query = _client.from('users').select();

      if (userType != null) query = query.eq('user_type', userType);
      if (search != null && search.isNotEmpty) {
        query = query.or(
            'full_name.ilike.%$search%,email.ilike.%$search%,user_id.ilike.%$search%');
      }

      final from = (page - 1) * pageSize;
      final to = from + pageSize - 1;
      final data = await query
          .order('created_at', ascending: false)
          .range(from, to);

      final users =
          (data as List).map((e) => UserModel.fromJson(e)).toList();

      return (users: users, total: users.length, error: null);
    } catch (e) {
      return (users: <UserModel>[], total: 0, error: e.toString());
    }
  }

  /// Sends a password-reset email for the given user's email.
  Future<String?> resetUserPassword(String userId) async {
    try {
      final user = await _client
          .from('users')
          .select('email')
          .eq('id', userId)
          .single();
      final email = user['email'] as String?;
      if (email == null) return 'User has no email on file.';

      await _client.auth.resetPasswordForEmail(email);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Changes a user's role.
  Future<String?> changeUserRole(String userId, String newRole) async {
    try {
      await _client
          .from('users')
          .update({'user_type': newRole}).eq('id', userId);
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
