import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jeevanpatra/models/appointment_model.dart';
import 'package:jeevanpatra/models/doctor_model.dart';
import 'package:jeevanpatra/models/prescription_model.dart';
import 'package:jeevanpatra/providers/auth_provider.dart';
import 'package:jeevanpatra/services/appointment_service.dart';
import 'package:jeevanpatra/services/doctor_service.dart';
import 'package:jeevanpatra/services/prescription_service.dart';

// ── Service singletons ─────────────────────────────────────────────────
final doctorServiceProvider =
    Provider<DoctorService>((_) => DoctorService());
final _appointmentServiceProvider =
    Provider<AppointmentService>((_) => AppointmentService());
final _prescriptionServiceProvider =
    Provider<PrescriptionService>((_) => PrescriptionService());

// ── Doctor profile ─────────────────────────────────────────────────────
final doctorProfileProvider = FutureProvider<DoctorModel?>((ref) async {
  final user = ref.watch(authNotifierProvider);
  if (user == null) return null;
  final result =
      await ref.read(doctorServiceProvider).getDoctorProfile(user.id);
  return result.doctor;
});

// ── Doctor stats ───────────────────────────────────────────────────────
final doctorStatsProvider =
    FutureProvider<Map<String, dynamic>?>((ref) async {
  final user = ref.watch(authNotifierProvider);
  if (user == null) return null;
  final result =
      await ref.read(doctorServiceProvider).getDoctorStats(user.id);
  return result.stats;
});

// ── Doctor's pending (upcoming) appointments ───────────────────────────
final doctorPendingAppointmentsProvider =
    FutureProvider<List<AppointmentModel>>((ref) async {
  final user = ref.watch(authNotifierProvider);
  if (user == null) return [];
  final result = await ref
      .read(_appointmentServiceProvider)
      .getUpcomingAppointments(user.id, isDoctor: true);
  return result.appointments;
});

// ── Doctor's completed appointments ────────────────────────────────────
final doctorCompletedAppointmentsProvider =
    FutureProvider<List<AppointmentModel>>((ref) async {
  final user = ref.watch(authNotifierProvider);
  if (user == null) return [];
  final result = await ref
      .read(_appointmentServiceProvider)
      .getCompletedAppointments(user.id, isDoctor: true);
  return result.appointments;
});

// ── Doctor's prescriptions ─────────────────────────────────────────────
final doctorPrescriptionsProvider =
    FutureProvider<List<PrescriptionModel>>((ref) async {
  final user = ref.watch(authNotifierProvider);
  if (user == null) return [];
  final result = await ref
      .read(_prescriptionServiceProvider)
      .getPrescriptionsForDoctor(user.id);
  return result.prescriptions;
});
