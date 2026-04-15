import 'package:jeevanpatra/config/supabase_config.dart';
import 'package:jeevanpatra/models/appointment_model.dart';

class AppointmentService {
  final _client = SupabaseConfig.client;

  /// Books a new appointment.
  Future<({AppointmentModel? appointment, String? error})> bookAppointment({
    required String patientId,
    required String doctorId,
    required DateTime date,
    required String time,
    String? notes,
  }) async {
    try {
      final data = {
        'patient_id': patientId,
        'doctor_id': doctorId,
        'appointment_date': date.toIso8601String(),
        'appointment_time': time,
        'notes': notes,
        'status': AppointmentStatus.scheduled.name,
      };

      final response = await _client
          .from('appointments')
          .insert(data)
          .select()
          .single();
      return (
        appointment: AppointmentModel.fromJson(response),
        error: null,
      );
    } catch (e) {
      return (appointment: null, error: e.toString());
    }
  }

  /// Returns upcoming (scheduled) appointments for a user.
  /// Set [isDoctor] to true to query by doctor_id instead of patient_id.
  Future<({List<AppointmentModel> appointments, String? error})>
      getUpcomingAppointments(
    String userId, {
    bool isDoctor = false,
  }) async {
    try {
      final column = isDoctor ? 'doctor_id' : 'patient_id';
      final data = await _client
          .from('appointments')
          .select()
          .eq(column, userId)
          .eq('status', AppointmentStatus.scheduled.name)
          .gte('appointment_date', DateTime.now().toIso8601String())
          .order('appointment_date');
      final appointments = (data as List)
          .map((e) => AppointmentModel.fromJson(e))
          .toList();
      return (appointments: appointments, error: null);
    } catch (e) {
      return (appointments: <AppointmentModel>[], error: e.toString());
    }
  }

  /// Returns completed appointments.
  Future<({List<AppointmentModel> appointments, String? error})>
      getCompletedAppointments(
    String userId, {
    bool isDoctor = false,
  }) async {
    try {
      final column = isDoctor ? 'doctor_id' : 'patient_id';
      final data = await _client
          .from('appointments')
          .select()
          .eq(column, userId)
          .eq('status', AppointmentStatus.completed.name)
          .order('appointment_date', ascending: false);
      final appointments = (data as List)
          .map((e) => AppointmentModel.fromJson(e))
          .toList();
      return (appointments: appointments, error: null);
    } catch (e) {
      return (appointments: <AppointmentModel>[], error: e.toString());
    }
  }

  /// Reschedules an appointment by marking the old one as rescheduled
  /// and creating a new appointment with the updated date/time.
  Future<({AppointmentModel? appointment, String? error})>
      rescheduleAppointment(
    String appointmentId,
    DateTime newDate,
    String newTime,
  ) async {
    try {
      // Fetch the original appointment to copy its details.
      final original = await _client
          .from('appointments')
          .select()
          .eq('id', appointmentId)
          .single();

      // Mark the original as rescheduled.
      await _client
          .from('appointments')
          .update({'status': AppointmentStatus.rescheduled.name})
          .eq('id', appointmentId);

      // Create a new appointment referencing the original.
      final newData = {
        'patient_id': original['patient_id'],
        'doctor_id': original['doctor_id'],
        'appointment_date': newDate.toIso8601String(),
        'appointment_time': newTime,
        'notes': original['notes'],
        'status': AppointmentStatus.scheduled.name,
        'rescheduled_from': appointmentId,
      };

      final response = await _client
          .from('appointments')
          .insert(newData)
          .select()
          .single();
      return (
        appointment: AppointmentModel.fromJson(response),
        error: null,
      );
    } catch (e) {
      return (appointment: null, error: e.toString());
    }
  }

  /// Cancels an appointment.
  Future<String?> cancelAppointment(String appointmentId) async {
    try {
      await _client.from('appointments').update(
          {'status': AppointmentStatus.cancelled.name}).eq('id', appointmentId);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Marks an appointment as completed.
  Future<String?> completeAppointment(String appointmentId) async {
    try {
      await _client.from('appointments').update(
          {'status': AppointmentStatus.completed.name}).eq('id', appointmentId);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Rates a completed appointment and updates the doctor's aggregate rating.
  Future<String?> rateAppointment(
    String appointmentId,
    double rating,
    String? comment,
  ) async {
    try {
      await _client.from('appointments').update({
        'rating': rating,
        'rating_comment': comment,
      }).eq('id', appointmentId);

      // Update doctor aggregate rating
      final appointment = await _client
          .from('appointments')
          .select('doctor_id')
          .eq('id', appointmentId)
          .single();

      final doctorId = appointment['doctor_id'] as String;
      final allRated = await _client
          .from('appointments')
          .select('rating')
          .eq('doctor_id', doctorId)
          .not('rating', 'is', null);

      if ((allRated as List).isNotEmpty) {
        double sum = 0;
        for (final row in allRated) {
          sum += (row['rating'] as num).toDouble();
        }
        final avg = sum / allRated.length;

        await _client.from('doctor_profiles').update({
          'rating': double.parse(avg.toStringAsFixed(2)),
          'total_ratings': allRated.length,
        }).eq('user_id', doctorId);
      }

      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
