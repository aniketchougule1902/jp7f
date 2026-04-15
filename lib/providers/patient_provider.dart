import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jeevanpatra/models/appointment_model.dart';
import 'package:jeevanpatra/models/health_record_model.dart';
import 'package:jeevanpatra/models/notification_model.dart';
import 'package:jeevanpatra/models/patient_model.dart';
import 'package:jeevanpatra/models/prescription_model.dart';
import 'package:jeevanpatra/providers/auth_provider.dart';
import 'package:jeevanpatra/services/appointment_service.dart';
import 'package:jeevanpatra/services/notification_service.dart';
import 'package:jeevanpatra/services/patient_service.dart';
import 'package:jeevanpatra/services/prescription_service.dart';

// ── Service singletons ─────────────────────────────────────────────────
final patientServiceProvider =
    Provider<PatientService>((_) => PatientService());
final appointmentServiceProvider =
    Provider<AppointmentService>((_) => AppointmentService());
final prescriptionServiceProvider =
    Provider<PrescriptionService>((_) => PrescriptionService());
final notificationServiceProvider =
    Provider<NotificationService>((_) => NotificationService());

// ── Patient profile ────────────────────────────────────────────────────
final patientProfileProvider = FutureProvider<PatientModel?>((ref) async {
  final user = ref.watch(authNotifierProvider);
  if (user == null) return null;
  final result =
      await ref.read(patientServiceProvider).getPatientProfile(user.id);
  return result.patient;
});

// ── Health records ─────────────────────────────────────────────────────
final healthRecordsProvider =
    FutureProvider<List<HealthRecordModel>>((ref) async {
  final user = ref.watch(authNotifierProvider);
  if (user == null) return [];
  final result = await ref
      .read(patientServiceProvider)
      .getPatientHealthRecords(user.id);
  return result.records;
});

// ── Upcoming appointments ──────────────────────────────────────────────
final upcomingAppointmentsProvider =
    FutureProvider<List<AppointmentModel>>((ref) async {
  final user = ref.watch(authNotifierProvider);
  if (user == null) return [];
  final result = await ref
      .read(appointmentServiceProvider)
      .getUpcomingAppointments(user.id);
  return result.appointments;
});

// ── Active prescriptions ───────────────────────────────────────────────
final activePrescriptionsProvider =
    FutureProvider<List<PrescriptionModel>>((ref) async {
  final user = ref.watch(authNotifierProvider);
  if (user == null) return [];
  final result = await ref
      .read(prescriptionServiceProvider)
      .getActivePrescriptions(user.id);
  return result.prescriptions;
});

// ── Patient notifications ──────────────────────────────────────────────
final patientNotificationsProvider =
    FutureProvider<List<NotificationModel>>((ref) async {
  final user = ref.watch(authNotifierProvider);
  if (user == null) return [];
  final result =
      await ref.read(notificationServiceProvider).getNotifications(user.id);
  return result.notifications;
});
