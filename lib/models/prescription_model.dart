class PrescriptionMedicine {
  final String? medicineName;
  final String? dosage;
  final String? frequency;
  final String? duration;
  final String? instructions;
  final String? medicineId;

  const PrescriptionMedicine({
    this.medicineName,
    this.dosage,
    this.frequency,
    this.duration,
    this.instructions,
    this.medicineId,
  });

  factory PrescriptionMedicine.fromJson(Map<String, dynamic> json) {
    return PrescriptionMedicine(
      medicineName: json['medicine_name'] as String?,
      dosage: json['dosage'] as String?,
      frequency: json['frequency'] as String?,
      duration: json['duration'] as String?,
      instructions: json['instructions'] as String?,
      medicineId: json['medicine_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicine_name': medicineName,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
      'instructions': instructions,
      'medicine_id': medicineId,
    };
  }

  PrescriptionMedicine copyWith({
    String? medicineName,
    String? dosage,
    String? frequency,
    String? duration,
    String? instructions,
    String? medicineId,
  }) {
    return PrescriptionMedicine(
      medicineName: medicineName ?? this.medicineName,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      duration: duration ?? this.duration,
      instructions: instructions ?? this.instructions,
      medicineId: medicineId ?? this.medicineId,
    );
  }
}

class PrescriptionModel {
  final String id;
  final String? prescriptionId;
  final String doctorId;
  final String patientId;
  final String? appointmentId;
  final String? diagnosis;
  final String? notes;
  final List<PrescriptionMedicine> medicines;
  final bool isActive;
  final DateTime? editableUntil;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PrescriptionModel({
    required this.id,
    this.prescriptionId,
    required this.doctorId,
    required this.patientId,
    this.appointmentId,
    this.diagnosis,
    this.notes,
    this.medicines = const [],
    this.isActive = true,
    this.editableUntil,
    this.createdAt,
    this.updatedAt,
  });

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionModel(
      id: json['id'] as String,
      prescriptionId: json['prescription_id'] as String?,
      doctorId: json['doctor_id'] as String,
      patientId: json['patient_id'] as String,
      appointmentId: json['appointment_id'] as String?,
      diagnosis: json['diagnosis'] as String?,
      notes: json['notes'] as String?,
      medicines: _parseMedicines(json['medicines']),
      isActive: json['is_active'] as bool? ?? true,
      editableUntil: json['editable_until'] != null
          ? DateTime.parse(json['editable_until'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  static List<PrescriptionMedicine> _parseMedicines(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .map((e) =>
              PrescriptionMedicine.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prescription_id': prescriptionId,
      'doctor_id': doctorId,
      'patient_id': patientId,
      'appointment_id': appointmentId,
      'diagnosis': diagnosis,
      'notes': notes,
      'medicines': medicines.map((m) => m.toJson()).toList(),
      'is_active': isActive,
      'editable_until': editableUntil?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  PrescriptionModel copyWith({
    String? id,
    String? prescriptionId,
    String? doctorId,
    String? patientId,
    String? appointmentId,
    String? diagnosis,
    String? notes,
    List<PrescriptionMedicine>? medicines,
    bool? isActive,
    DateTime? editableUntil,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PrescriptionModel(
      id: id ?? this.id,
      prescriptionId: prescriptionId ?? this.prescriptionId,
      doctorId: doctorId ?? this.doctorId,
      patientId: patientId ?? this.patientId,
      appointmentId: appointmentId ?? this.appointmentId,
      diagnosis: diagnosis ?? this.diagnosis,
      notes: notes ?? this.notes,
      medicines: medicines ?? this.medicines,
      isActive: isActive ?? this.isActive,
      editableUntil: editableUntil ?? this.editableUntil,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
