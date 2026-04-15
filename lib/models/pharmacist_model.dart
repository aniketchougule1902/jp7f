import 'doctor_model.dart';

class PharmacistModel {
  final String id;
  final String userId;
  final String? gender;
  final int? age;
  final String? drugLicenseNumber;
  final String? drugLicenseDocUrl;
  final String? qualification;
  final String? qualificationDocUrl;
  final String? pharmacyName;
  final String? pharmacyAddress;
  final String? pharmacyCity;
  final String? pharmacyState;
  final String? pharmacyPincode;
  final VerificationStatus verificationStatus;
  final String? verificationReason;
  final String? verifiedBy;
  final DateTime? verifiedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PharmacistModel({
    required this.id,
    required this.userId,
    this.gender,
    this.age,
    this.drugLicenseNumber,
    this.drugLicenseDocUrl,
    this.qualification,
    this.qualificationDocUrl,
    this.pharmacyName,
    this.pharmacyAddress,
    this.pharmacyCity,
    this.pharmacyState,
    this.pharmacyPincode,
    this.verificationStatus = VerificationStatus.pending,
    this.verificationReason,
    this.verifiedBy,
    this.verifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory PharmacistModel.fromJson(Map<String, dynamic> json) {
    return PharmacistModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      gender: json['gender'] as String?,
      age: json['age'] as int?,
      drugLicenseNumber: json['drug_license_number'] as String?,
      drugLicenseDocUrl: json['drug_license_doc_url'] as String?,
      qualification: json['qualification'] as String?,
      qualificationDocUrl: json['qualification_doc_url'] as String?,
      pharmacyName: json['pharmacy_name'] as String?,
      pharmacyAddress: json['pharmacy_address'] as String?,
      pharmacyCity: json['pharmacy_city'] as String?,
      pharmacyState: json['pharmacy_state'] as String?,
      pharmacyPincode: json['pharmacy_pincode'] as String?,
      verificationStatus: json['verification_status'] != null
          ? VerificationStatus.fromString(
              json['verification_status'] as String)
          : VerificationStatus.pending,
      verificationReason: json['verification_reason'] as String?,
      verifiedBy: json['verified_by'] as String?,
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'] as String)
          : null,
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
      'drug_license_number': drugLicenseNumber,
      'drug_license_doc_url': drugLicenseDocUrl,
      'qualification': qualification,
      'qualification_doc_url': qualificationDocUrl,
      'pharmacy_name': pharmacyName,
      'pharmacy_address': pharmacyAddress,
      'pharmacy_city': pharmacyCity,
      'pharmacy_state': pharmacyState,
      'pharmacy_pincode': pharmacyPincode,
      'verification_status': verificationStatus.toString(),
      'verification_reason': verificationReason,
      'verified_by': verifiedBy,
      'verified_at': verifiedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  PharmacistModel copyWith({
    String? id,
    String? userId,
    String? gender,
    int? age,
    String? drugLicenseNumber,
    String? drugLicenseDocUrl,
    String? qualification,
    String? qualificationDocUrl,
    String? pharmacyName,
    String? pharmacyAddress,
    String? pharmacyCity,
    String? pharmacyState,
    String? pharmacyPincode,
    VerificationStatus? verificationStatus,
    String? verificationReason,
    String? verifiedBy,
    DateTime? verifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PharmacistModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      drugLicenseNumber: drugLicenseNumber ?? this.drugLicenseNumber,
      drugLicenseDocUrl: drugLicenseDocUrl ?? this.drugLicenseDocUrl,
      qualification: qualification ?? this.qualification,
      qualificationDocUrl: qualificationDocUrl ?? this.qualificationDocUrl,
      pharmacyName: pharmacyName ?? this.pharmacyName,
      pharmacyAddress: pharmacyAddress ?? this.pharmacyAddress,
      pharmacyCity: pharmacyCity ?? this.pharmacyCity,
      pharmacyState: pharmacyState ?? this.pharmacyState,
      pharmacyPincode: pharmacyPincode ?? this.pharmacyPincode,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verificationReason: verificationReason ?? this.verificationReason,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
