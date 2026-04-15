enum AppointmentStatus {
  scheduled,
  completed,
  cancelled,
  rescheduled;

  static AppointmentStatus fromString(String value) {
    switch (value) {
      case 'scheduled':
        return AppointmentStatus.scheduled;
      case 'completed':
        return AppointmentStatus.completed;
      case 'cancelled':
        return AppointmentStatus.cancelled;
      case 'rescheduled':
        return AppointmentStatus.rescheduled;
      default:
        return AppointmentStatus.scheduled;
    }
  }

  @override
  String toString() {
    switch (this) {
      case AppointmentStatus.scheduled:
        return 'scheduled';
      case AppointmentStatus.completed:
        return 'completed';
      case AppointmentStatus.cancelled:
        return 'cancelled';
      case AppointmentStatus.rescheduled:
        return 'rescheduled';
    }
  }
}

class AppointmentModel {
  final String id;
  final String patientId;
  final String doctorId;
  final DateTime appointmentDate;
  final String appointmentTime;
  final AppointmentStatus status;
  final String? notes;
  final int? rating;
  final String? ratingComment;
  final String? rescheduledFrom;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Optional display fields (not stored in appointments table)
  final String? doctorName;
  final String? patientName;

  const AppointmentModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.appointmentDate,
    required this.appointmentTime,
    this.status = AppointmentStatus.scheduled,
    this.notes,
    this.rating,
    this.ratingComment,
    this.rescheduledFrom,
    this.createdAt,
    this.updatedAt,
    this.doctorName,
    this.patientName,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      doctorId: json['doctor_id'] as String,
      appointmentDate:
          DateTime.parse(json['appointment_date'] as String),
      appointmentTime: json['appointment_time'] as String,
      status: json['status'] != null
          ? AppointmentStatus.fromString(json['status'] as String)
          : AppointmentStatus.scheduled,
      notes: json['notes'] as String?,
      rating: json['rating'] as int?,
      ratingComment: json['rating_comment'] as String?,
      rescheduledFrom: json['rescheduled_from'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      doctorName: json['doctor_name'] as String?,
      patientName: json['patient_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'appointment_date':
          appointmentDate.toIso8601String().split('T').first,
      'appointment_time': appointmentTime,
      'status': status.toString(),
      'notes': notes,
      'rating': rating,
      'rating_comment': ratingComment,
      'rescheduled_from': rescheduledFrom,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  AppointmentModel copyWith({
    String? id,
    String? patientId,
    String? doctorId,
    DateTime? appointmentDate,
    String? appointmentTime,
    AppointmentStatus? status,
    String? notes,
    int? rating,
    String? ratingComment,
    String? rescheduledFrom,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? doctorName,
    String? patientName,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      appointmentTime: appointmentTime ?? this.appointmentTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      rating: rating ?? this.rating,
      ratingComment: ratingComment ?? this.ratingComment,
      rescheduledFrom: rescheduledFrom ?? this.rescheduledFrom,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      doctorName: doctorName ?? this.doctorName,
      patientName: patientName ?? this.patientName,
    );
  }
}
