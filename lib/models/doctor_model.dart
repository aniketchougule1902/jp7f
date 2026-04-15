enum VerificationStatus {
  pending,
  approved,
  rejected;

  static VerificationStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return VerificationStatus.pending;
      case 'approved':
        return VerificationStatus.approved;
      case 'rejected':
        return VerificationStatus.rejected;
      default:
        return VerificationStatus.pending;
    }
  }

  @override
  String toString() {
    switch (this) {
      case VerificationStatus.pending:
        return 'pending';
      case VerificationStatus.approved:
        return 'approved';
      case VerificationStatus.rejected:
        return 'rejected';
    }
  }
}

class DoctorModel {
  final String id;
  final String userId;
  final String? gender;
  final int? age;
  final String? licenseNumber;
  final String? licenseDocUrl;
  final String? qualification;
  final String? qualificationDocUrl;
  final String? specialization;
  final String? clinicName;
  final String? clinicAddress;
  final String? clinicCity;
  final String? clinicState;
  final String? clinicPincode;
  final double? consultationFee;
  final VerificationStatus verificationStatus;
  final String? verificationReason;
  final String? verifiedBy;
  final DateTime? verifiedAt;
  final Map<String, dynamic>? schedule;
  final double rating;
  final int totalRatings;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DoctorModel({
    required this.id,
    required this.userId,
    this.gender,
    this.age,
    this.licenseNumber,
    this.licenseDocUrl,
    this.qualification,
    this.qualificationDocUrl,
    this.specialization,
    this.clinicName,
    this.clinicAddress,
    this.clinicCity,
    this.clinicState,
    this.clinicPincode,
    this.consultationFee,
    this.verificationStatus = VerificationStatus.pending,
    this.verificationReason,
    this.verifiedBy,
    this.verifiedAt,
    this.schedule,
    this.rating = 0,
    this.totalRatings = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      gender: json['gender'] as String?,
      age: json['age'] as int?,
      licenseNumber: json['license_number'] as String?,
      licenseDocUrl: json['license_doc_url'] as String?,
      qualification: json['qualification'] as String?,
      qualificationDocUrl: json['qualification_doc_url'] as String?,
      specialization: json['specialization'] as String?,
      clinicName: json['clinic_name'] as String?,
      clinicAddress: json['clinic_address'] as String?,
      clinicCity: json['clinic_city'] as String?,
      clinicState: json['clinic_state'] as String?,
      clinicPincode: json['clinic_pincode'] as String?,
      consultationFee: (json['consultation_fee'] as num?)?.toDouble(),
      verificationStatus: json['verification_status'] != null
          ? VerificationStatus.fromString(
              json['verification_status'] as String)
          : VerificationStatus.pending,
      verificationReason: json['verification_reason'] as String?,
      verifiedBy: json['verified_by'] as String?,
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'] as String)
          : null,
      schedule: json['schedule'] != null
          ? Map<String, dynamic>.from(json['schedule'] as Map)
          : null,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      totalRatings: json['total_ratings'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'gender': gender,
      'age': age,
      'license_number': licenseNumber,
      'license_doc_url': licenseDocUrl,
      'qualification': qualification,
      'qualification_doc_url': qualificationDocUrl,
      'specialization': specialization,
      'clinic_name': clinicName,
      'clinic_address': clinicAddress,
      'clinic_city': clinicCity,
      'clinic_state': clinicState,
      'clinic_pincode': clinicPincode,
      'consultation_fee': consultationFee,
      'verification_status': verificationStatus.toString(),
      'verification_reason': verificationReason,
      'verified_by': verifiedBy,
      'verified_at': verifiedAt?.toIso8601String(),
      'schedule': schedule,
      'rating': rating,
      'total_ratings': totalRatings,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  DoctorModel copyWith({
    String? id,
    String? userId,
    String? gender,
    int? age,
    String? licenseNumber,
    String? licenseDocUrl,
    String? qualification,
    String? qualificationDocUrl,
    String? specialization,
    String? clinicName,
    String? clinicAddress,
    String? clinicCity,
    String? clinicState,
    String? clinicPincode,
    double? consultationFee,
    VerificationStatus? verificationStatus,
    String? verificationReason,
    String? verifiedBy,
    DateTime? verifiedAt,
    Map<String, dynamic>? schedule,
    double? rating,
    int? totalRatings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DoctorModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      licenseDocUrl: licenseDocUrl ?? this.licenseDocUrl,
      qualification: qualification ?? this.qualification,
      qualificationDocUrl: qualificationDocUrl ?? this.qualificationDocUrl,
      specialization: specialization ?? this.specialization,
      clinicName: clinicName ?? this.clinicName,
      clinicAddress: clinicAddress ?? this.clinicAddress,
      clinicCity: clinicCity ?? this.clinicCity,
      clinicState: clinicState ?? this.clinicState,
      clinicPincode: clinicPincode ?? this.clinicPincode,
      consultationFee: consultationFee ?? this.consultationFee,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verificationReason: verificationReason ?? this.verificationReason,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      schedule: schedule ?? this.schedule,
      rating: rating ?? this.rating,
      totalRatings: totalRatings ?? this.totalRatings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
