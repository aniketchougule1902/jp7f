import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jeevanpatra/models/medicine_model.dart';
import 'package:jeevanpatra/models/user_model.dart';
import 'package:jeevanpatra/services/admin_service.dart';

// ── Service singleton ──────────────────────────────────────────────────
final adminServiceProvider = Provider<AdminService>((_) => AdminService());

// ── Platform stats ─────────────────────────────────────────────────────
final platformStatsProvider =
    FutureProvider<Map<String, dynamic>?>((ref) async {
  final result = await ref.read(adminServiceProvider).getPlatformStats();
  return result.stats;
});

// ── Pending verifications ──────────────────────────────────────────────
final pendingVerificationsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final result =
      await ref.read(adminServiceProvider).getPendingVerifications();
  return result.verifications;
});

// ── Medicine catalog ───────────────────────────────────────────────────
final medicineCatalogProvider =
    FutureProvider<List<MedicineModel>>((ref) async {
  final result = await ref.read(adminServiceProvider).getMedicineCatalog();
  return result.medicines;
});

// ── All users (admin view) ─────────────────────────────────────────────
final allUsersProvider = FutureProvider<List<UserModel>>((ref) async {
  final result = await ref.read(adminServiceProvider).getAllUsersAdmin();
  return result.users;
});

// ── System logs ────────────────────────────────────────────────────────
final systemLogsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final result = await ref.read(adminServiceProvider).getSystemLogs();
  return result.logs;
});
