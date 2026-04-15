import 'package:jeevanpatra/config/supabase_config.dart';
import 'package:jeevanpatra/models/health_record_model.dart';
import 'package:jeevanpatra/models/patient_model.dart';

class PatientService {
  final _client = SupabaseConfig.client;

  /// Fetches the patient profile by auth [userId].
  Future<({PatientModel? patient, String? error})> getPatientProfile(
      String userId) async {
    try {
      final data = await _client
          .from('patient_profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      if (data == null) return (patient: null, error: 'Profile not found.');
      return (patient: PatientModel.fromJson(data), error: null);
    } catch (e) {
      return (patient: null, error: e.toString());
    }
  }

  /// Creates or updates the patient profile for [userId].
  Future<({PatientModel? patient, String? error})> updatePatientProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client
          .from('patient_profiles')
          .upsert({'user_id': userId, ...data})
          .select()
          .single();
      return (patient: PatientModel.fromJson(response), error: null);
    } catch (e) {
      return (patient: null, error: e.toString());
    }
  }

  /// Calculates a health score (0–100) based on profile completeness and vitals.
  int calculateHealthScore(PatientModel patient) {
    int score = 0;

    // Profile completeness contributes 40 points
    score += (calculateProfileCompletion(patient) * 0.4).round();

    // Vitals contribute up to 60 points
    if (patient.bpSystolic != null && patient.bpDiastolic != null) {
      final sys = patient.bpSystolic!;
      final dia = patient.bpDiastolic!;
      if (sys >= 90 && sys <= 120 && dia >= 60 && dia <= 80) {
        score += 20;
      } else if (sys >= 80 && sys <= 140 && dia >= 50 && dia <= 90) {
        score += 10;
      }
    }

    if (patient.heartRate != null) {
      final hr = patient.heartRate!;
      if (hr >= 60 && hr <= 100) {
        score += 20;
      } else if (hr >= 50 && hr <= 110) {
        score += 10;
      }
    }

    if (patient.heightCm != null && patient.weightKg != null) {
      final heightM = patient.heightCm! / 100;
      final bmi = patient.weightKg! / (heightM * heightM);
      if (bmi >= 18.5 && bmi <= 24.9) {
        score += 20;
      } else if (bmi >= 16 && bmi <= 30) {
        score += 10;
      }
    }

    return score.clamp(0, 100);
  }

  /// Returns profile-completion percentage (0–100).
  int calculateProfileCompletion(PatientModel patient) {
    int filled = 0;
    const total = 12;

    if (patient.gender != null) filled++;
    if (patient.age != null) filled++;
    if (patient.dateOfBirth != null) filled++;
    if (patient.bloodGroup != null) filled++;
    if (patient.heightCm != null) filled++;
    if (patient.weightKg != null) filled++;
    if (patient.bpSystolic != null) filled++;
    if (patient.heartRate != null) filled++;
    if (patient.currentHealthStatus != null) filled++;
    if (patient.allergies.isNotEmpty) filled++;
    if (patient.chronicDiseases != null) filled++;
    if (patient.longTermMedications.isNotEmpty) filled++;

    return ((filled / total) * 100).round();
  }

  /// Fetches all health records for a patient.
  Future<({List<HealthRecordModel> records, String? error})>
      getPatientHealthRecords(String userId) async {
    try {
      final data = await _client
          .from('health_records')
          .select()
          .eq('patient_id', userId)
          .order('created_at', ascending: false);
      final records = (data as List)
          .map((e) => HealthRecordModel.fromJson(e))
          .toList();
      return (records: records, error: null);
    } catch (e) {
      return (records: <HealthRecordModel>[], error: e.toString());
    }
  }

  /// Inserts a new health record.
  Future<({HealthRecordModel? record, String? error})> uploadHealthRecord(
    Map<String, dynamic> record,
  ) async {
    try {
      final response = await _client
          .from('health_records')
          .insert(record)
          .select()
          .single();
      return (record: HealthRecordModel.fromJson(response), error: null);
    } catch (e) {
      return (record: null, error: e.toString());
    }
  }
}
