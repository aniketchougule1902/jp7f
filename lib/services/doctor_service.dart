import 'package:jeevanpatra/config/supabase_config.dart';
import 'package:jeevanpatra/models/doctor_model.dart';

class DoctorService {
  final _client = SupabaseConfig.client;

  /// Fetches the doctor profile by auth [userId].
  Future<({DoctorModel? doctor, String? error})> getDoctorProfile(
      String userId) async {
    try {
      final data = await _client
          .from('doctor_profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      if (data == null) return (doctor: null, error: 'Profile not found.');
      return (doctor: DoctorModel.fromJson(data), error: null);
    } catch (e) {
      return (doctor: null, error: e.toString());
    }
  }

  /// Creates or updates the doctor profile for [userId].
  Future<({DoctorModel? doctor, String? error})> updateDoctorProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client
          .from('doctor_profiles')
          .upsert({'user_id': userId, ...data})
          .select()
          .single();
      return (doctor: DoctorModel.fromJson(response), error: null);
    } catch (e) {
      return (doctor: null, error: e.toString());
    }
  }

  /// Searches doctors by name, specialization, or city.
  Future<({List<DoctorModel> doctors, String? error})> searchDoctors(
    String query, {
    String? city,
    String? specialization,
  }) async {
    try {
      var q = _client
          .from('doctor_profiles')
          .select('*, users!inner(full_name)')
          .or('specialization.ilike.%$query%,clinic_name.ilike.%$query%');

      if (city != null) q = q.eq('clinic_city', city);
      if (specialization != null) {
        q = q.ilike('specialization', '%$specialization%');
      }

      final data = await q;
      final doctors =
          (data as List).map((e) => DoctorModel.fromJson(e)).toList();
      return (doctors: doctors, error: null);
    } catch (e) {
      return (doctors: <DoctorModel>[], error: e.toString());
    }
  }

  /// Returns the schedule map for a doctor.
  Future<({Map<String, dynamic>? schedule, String? error})> getDoctorSchedule(
      String userId) async {
    try {
      final data = await _client
          .from('doctor_profiles')
          .select('schedule')
          .eq('user_id', userId)
          .single();
      return (
        schedule: data['schedule'] as Map<String, dynamic>?,
        error: null,
      );
    } catch (e) {
      return (schedule: null, error: e.toString());
    }
  }

  /// Updates the doctor's schedule.
  Future<String?> updateDoctorSchedule(
    String userId,
    Map<String, dynamic> schedule,
  ) async {
    try {
      await _client
          .from('doctor_profiles')
          .update({'schedule': schedule}).eq('user_id', userId);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Aggregated stats for the doctor dashboard.
  Future<({Map<String, dynamic>? stats, String? error})> getDoctorStats(
      String userId) async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day).toIso8601String();
      final oneWeekAgo = now.subtract(const Duration(days: 7)).toIso8601String();
      final oneMonthAgo =
          DateTime(now.year, now.month - 1, now.day).toIso8601String();
      final oneYearAgo =
          DateTime(now.year - 1, now.month, now.day).toIso8601String();

      final todayAppointments = await _client
          .from('appointments')
          .select('id')
          .eq('doctor_id', userId)
          .gte('appointment_date', todayStart);

      final weekPatients = await _client
          .from('appointments')
          .select('patient_id')
          .eq('doctor_id', userId)
          .gte('appointment_date', oneWeekAgo);

      final monthPatients = await _client
          .from('appointments')
          .select('patient_id')
          .eq('doctor_id', userId)
          .gte('appointment_date', oneMonthAgo);

      final yearPatients = await _client
          .from('appointments')
          .select('patient_id')
          .eq('doctor_id', userId)
          .gte('appointment_date', oneYearAgo);

      final allPatients = await _client
          .from('appointments')
          .select('patient_id')
          .eq('doctor_id', userId);

      final prescriptions = await _client
          .from('prescriptions')
          .select('id')
          .eq('doctor_id', userId);

      return (
        stats: {
          'today_consultations': (todayAppointments as List).length,
          'patients_1w': _uniqueCount(weekPatients, 'patient_id'),
          'patients_1m': _uniqueCount(monthPatients, 'patient_id'),
          'patients_1y': _uniqueCount(yearPatients, 'patient_id'),
          'patients_lifetime': _uniqueCount(allPatients, 'patient_id'),
          'prescriptions_issued': (prescriptions as List).length,
        },
        error: null,
      );
    } catch (e) {
      return (stats: null, error: e.toString());
    }
  }

  /// Returns the doctor's average rating and total rating count.
  Future<({double rating, int totalRatings, String? error})> getDoctorRating(
      String userId) async {
    try {
      final data = await _client
          .from('doctor_profiles')
          .select('rating, total_ratings')
          .eq('user_id', userId)
          .single();
      return (
        rating: (data['rating'] as num?)?.toDouble() ?? 0,
        totalRatings: (data['total_ratings'] as num?)?.toInt() ?? 0,
        error: null,
      );
    } catch (e) {
      return (rating: 0, totalRatings: 0, error: e.toString());
    }
  }

  int _uniqueCount(List<dynamic> rows, String field) {
    return rows.map((r) => r[field]).toSet().length;
  }
}
