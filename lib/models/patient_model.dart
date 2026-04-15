class PatientModel {
  final String id;
  final String userId;
  final String? gender;
  final int? age;
  final DateTime? dateOfBirth;
  final String? bloodGroup;
  final double? heightCm;
  final double? weightKg;
  final int? bpSystolic;
  final int? bpDiastolic;
  final int? heartRate;
  final String? currentHealthStatus;
  final String? chronicDiseases;
  final String? recentSurgeries;
  final List<String> allergies;
  final bool? familyHistoryDiabetes;
  final bool? familyHistoryHypertension;
  final String? familyHistoryOther;
  final List<String> foodAllergies;
  final List<String> medicineAllergies;
  final List<String> environmentAllergies;
  final List<String> longTermMedications;
  final int healthScore;
  final int profileCompletionPercentage;
  final String? abhaId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PatientModel({
    required this.id,
    required this.userId,
    this.gender,
    this.age,
    this.dateOfBirth,
    this.bloodGroup,
    this.heightCm,
    this.weightKg,
    this.bpSystolic,
    this.bpDiastolic,
    this.heartRate,
    this.currentHealthStatus,
    this.chronicDiseases,
    this.recentSurgeries,
    this.allergies = const [],
    this.familyHistoryDiabetes,
    this.familyHistoryHypertension,
    this.familyHistoryOther,
    this.foodAllergies = const [],
    this.medicineAllergies = const [],
    this.environmentAllergies = const [],
    this.longTermMedications = const [],
    this.healthScore = 0,
    this.profileCompletionPercentage = 0,
    this.abhaId,
    this.createdAt,
    this.updatedAt,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      gender: json['gender'] as String?,
      age: json['age'] as int?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      bloodGroup: json['blood_group'] as String?,
      heightCm: (json['height_cm'] as num?)?.toDouble(),
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
      bpSystolic: json['bp_systolic'] as int?,
      bpDiastolic: json['bp_diastolic'] as int?,
      heartRate: json['heart_rate'] as int?,
      currentHealthStatus: json['current_health_status'] as String?,
      chronicDiseases: json['chronic_diseases'] as String?,
      recentSurgeries: json['recent_surgeries'] as String?,
      allergies: _parseStringList(json['allergies']),
      familyHistoryDiabetes: json['family_history_diabetes'] as bool?,
      familyHistoryHypertension: json['family_history_hypertension'] as bool?,
      familyHistoryOther: json['family_history_other'] as String?,
      foodAllergies: _parseStringList(json['food_allergies']),
      medicineAllergies: _parseStringList(json['medicine_allergies']),
      environmentAllergies: _parseStringList(json['environment_allergies']),
      longTermMedications: _parseStringList(json['long_term_medications']),
      healthScore: json['health_score'] as int? ?? 0,
      profileCompletionPercentage:
          json['profile_completion_percentage'] as int? ?? 0,
      abhaId: json['abha_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.cast<String>();
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'gender': gender,
      'age': age,
      'date_of_birth': dateOfBirth?.toIso8601String().split('T').first,
      'blood_group': bloodGroup,
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'bp_systolic': bpSystolic,
      'bp_diastolic': bpDiastolic,
      'heart_rate': heartRate,
      'current_health_status': currentHealthStatus,
      'chronic_diseases': chronicDiseases,
      'recent_surgeries': recentSurgeries,
      'allergies': allergies,
      'family_history_diabetes': familyHistoryDiabetes,
      'family_history_hypertension': familyHistoryHypertension,
      'family_history_other': familyHistoryOther,
      'food_allergies': foodAllergies,
      'medicine_allergies': medicineAllergies,
      'environment_allergies': environmentAllergies,
      'long_term_medications': longTermMedications,
      'health_score': healthScore,
      'profile_completion_percentage': profileCompletionPercentage,
      'abha_id': abhaId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  PatientModel copyWith({
    String? id,
    String? userId,
    String? gender,
    int? age,
    DateTime? dateOfBirth,
    String? bloodGroup,
    double? heightCm,
    double? weightKg,
    int? bpSystolic,
    int? bpDiastolic,
    int? heartRate,
    String? currentHealthStatus,
    String? chronicDiseases,
    String? recentSurgeries,
    List<String>? allergies,
    bool? familyHistoryDiabetes,
    bool? familyHistoryHypertension,
    String? familyHistoryOther,
    List<String>? foodAllergies,
    List<String>? medicineAllergies,
    List<String>? environmentAllergies,
    List<String>? longTermMedications,
    int? healthScore,
    int? profileCompletionPercentage,
    String? abhaId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PatientModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      bpSystolic: bpSystolic ?? this.bpSystolic,
      bpDiastolic: bpDiastolic ?? this.bpDiastolic,
      heartRate: heartRate ?? this.heartRate,
      currentHealthStatus: currentHealthStatus ?? this.currentHealthStatus,
      chronicDiseases: chronicDiseases ?? this.chronicDiseases,
      recentSurgeries: recentSurgeries ?? this.recentSurgeries,
      allergies: allergies ?? this.allergies,
      familyHistoryDiabetes:
          familyHistoryDiabetes ?? this.familyHistoryDiabetes,
      familyHistoryHypertension:
          familyHistoryHypertension ?? this.familyHistoryHypertension,
      familyHistoryOther: familyHistoryOther ?? this.familyHistoryOther,
      foodAllergies: foodAllergies ?? this.foodAllergies,
      medicineAllergies: medicineAllergies ?? this.medicineAllergies,
      environmentAllergies: environmentAllergies ?? this.environmentAllergies,
      longTermMedications: longTermMedications ?? this.longTermMedications,
      healthScore: healthScore ?? this.healthScore,
      profileCompletionPercentage:
          profileCompletionPercentage ?? this.profileCompletionPercentage,
      abhaId: abhaId ?? this.abhaId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
