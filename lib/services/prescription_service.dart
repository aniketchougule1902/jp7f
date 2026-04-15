import 'package:jeevanpatra/config/supabase_config.dart';
import 'package:jeevanpatra/models/prescription_model.dart';

class PrescriptionService {
  final _client = SupabaseConfig.client;

  /// Creates a new prescription.
  Future<({PrescriptionModel? prescription, String? error})>
      createPrescription({
    required String doctorId,
    required String patientId,
    String? diagnosis,
    required List<Map<String, dynamic>> medicines,
    String? notes,
    String? appointmentId,
  }) async {
    try {
      final data = {
        'doctor_id': doctorId,
        'patient_id': patientId,
        'diagnosis': diagnosis,
        'medicines': medicines,
        'notes': notes,
        'appointment_id': appointmentId,
        'is_active': true,
        'editable_until':
            DateTime.now().add(const Duration(minutes: 15)).toIso8601String(),
      };

      final response = await _client
          .from('prescriptions')
          .insert(data)
          .select()
          .single();
      return (
        prescription: PrescriptionModel.fromJson(response),
        error: null,
      );
    } catch (e) {
      return (prescription: null, error: e.toString());
    }
  }

  /// Returns all prescriptions for a patient, newest first.
  Future<({List<PrescriptionModel> prescriptions, String? error})>
      getPrescriptionsForPatient(String patientId) async {
    try {
      final data = await _client
          .from('prescriptions')
          .select()
          .eq('patient_id', patientId)
          .order('created_at', ascending: false);
      final prescriptions = (data as List)
          .map((e) => PrescriptionModel.fromJson(e))
          .toList();
      return (prescriptions: prescriptions, error: null);
    } catch (e) {
      return (prescriptions: <PrescriptionModel>[], error: e.toString());
    }
  }

  /// Returns all prescriptions written by a doctor, newest first.
  Future<({List<PrescriptionModel> prescriptions, String? error})>
      getPrescriptionsForDoctor(String doctorId) async {
    try {
      final data = await _client
          .from('prescriptions')
          .select()
          .eq('doctor_id', doctorId)
          .order('created_at', ascending: false);
      final prescriptions = (data as List)
          .map((e) => PrescriptionModel.fromJson(e))
          .toList();
      return (prescriptions: prescriptions, error: null);
    } catch (e) {
      return (prescriptions: <PrescriptionModel>[], error: e.toString());
    }
  }

  /// Returns only active prescriptions for a patient.
  Future<({List<PrescriptionModel> prescriptions, String? error})>
      getActivePrescriptions(String patientId) async {
    try {
      final data = await _client
          .from('prescriptions')
          .select()
          .eq('patient_id', patientId)
          .eq('is_active', true)
          .order('created_at', ascending: false);
      final prescriptions = (data as List)
          .map((e) => PrescriptionModel.fromJson(e))
          .toList();
      return (prescriptions: prescriptions, error: null);
    } catch (e) {
      return (prescriptions: <PrescriptionModel>[], error: e.toString());
    }
  }

  /// Updates a prescription only if within the 15-minute edit window.
  Future<({PrescriptionModel? prescription, String? error})>
      updatePrescription(
    String prescriptionId,
    Map<String, dynamic> data,
  ) async {
    try {
      final existing = await _client
          .from('prescriptions')
          .select('editable_until')
          .eq('id', prescriptionId)
          .single();

      final editableUntil = DateTime.parse(existing['editable_until'] as String);
      if (DateTime.now().isAfter(editableUntil)) {
        return (
          prescription: null,
          error: 'Edit window has expired (15 minutes).',
        );
      }

      final response = await _client
          .from('prescriptions')
          .update(data)
          .eq('id', prescriptionId)
          .select()
          .single();
      return (
        prescription: PrescriptionModel.fromJson(response),
        error: null,
      );
    } catch (e) {
      return (prescription: null, error: e.toString());
    }
  }

  /// Deletes a prescription only if within the 15-minute edit window.
  Future<String?> deletePrescription(String prescriptionId) async {
    try {
      final existing = await _client
          .from('prescriptions')
          .select('editable_until')
          .eq('id', prescriptionId)
          .single();

      final editableUntil = DateTime.parse(existing['editable_until'] as String);
      if (DateTime.now().isAfter(editableUntil)) {
        return 'Delete window has expired (15 minutes).';
      }

      await _client
          .from('prescriptions')
          .delete()
          .eq('id', prescriptionId);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Checks patient allergies against the provided medicine names.
  /// Returns a list of warnings for matching allergies.
  Future<({List<String> warnings, String? error})> checkAllergyWarnings(
    String patientId,
    List<String> medicineNames,
  ) async {
    try {
      final data = await _client
          .from('patient_profiles')
          .select('allergies, medicine_allergies')
          .eq('user_id', patientId)
          .maybeSingle();

      if (data == null) return (warnings: <String>[], error: null);

      final allergies = <String>[
        ..._parseList(data['allergies']),
        ..._parseList(data['medicine_allergies']),
      ];

      final lowerAllergies =
          allergies.map((a) => a.toLowerCase()).toSet();

      final warnings = <String>[];
      for (final medicine in medicineNames) {
        for (final allergy in lowerAllergies) {
          if (medicine.toLowerCase().contains(allergy) ||
              allergy.contains(medicine.toLowerCase())) {
            warnings.add(
                'Warning: "$medicine" may conflict with allergy "$allergy".');
          }
        }
      }

      return (warnings: warnings, error: null);
    } catch (e) {
      return (warnings: <String>[], error: e.toString());
    }
  }

  List<String> _parseList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }
}
