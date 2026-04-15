enum UserType {
  patient,
  doctor,
  pharmacist,
  superuser,
  verifier,
  dataEntryAdmin;

  static UserType fromString(String value) {
    switch (value) {
      case 'patient':
        return UserType.patient;
      case 'doctor':
        return UserType.doctor;
      case 'pharmacist':
        return UserType.pharmacist;
      case 'superuser':
        return UserType.superuser;
      case 'verifier':
        return UserType.verifier;
      case 'data_entry_admin':
        return UserType.dataEntryAdmin;
      default:
        return UserType.patient;
    }
  }

  @override
  String toString() {
    switch (this) {
      case UserType.patient:
        return 'patient';
      case UserType.doctor:
        return 'doctor';
      case UserType.pharmacist:
        return 'pharmacist';
      case UserType.superuser:
        return 'superuser';
      case UserType.verifier:
        return 'verifier';
      case UserType.dataEntryAdmin:
        return 'data_entry_admin';
    }
  }
}

class UserModel {
  final String id;
  final String? userId;
  final String? fullName;
  final String? mobileNumber;
  final String? email;
  final UserType userType;
  final String? encryptedAadhar;
  final bool twoFaEnabled;
  final String? twoFaMethod;
  final bool profileCompleted;
  final bool isVerified;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    this.userId,
    this.fullName,
    this.mobileNumber,
    this.email,
    this.userType = UserType.patient,
    this.encryptedAadhar,
    this.twoFaEnabled = false,
    this.twoFaMethod,
    this.profileCompleted = false,
    this.isVerified = false,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      fullName: json['full_name'] as String?,
      mobileNumber: json['mobile_number'] as String?,
      email: json['email'] as String?,
      userType: json['user_type'] != null
          ? UserType.fromString(json['user_type'] as String)
          : UserType.patient,
      encryptedAadhar: json['encrypted_aadhar'] as String?,
      twoFaEnabled: json['two_fa_enabled'] as bool? ?? false,
      twoFaMethod: json['two_fa_method'] as String?,
      profileCompleted: json['profile_completed'] as bool? ?? false,
      isVerified: json['is_verified'] as bool? ?? false,
      avatarUrl: json['avatar_url'] as String?,
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
      'full_name': fullName,
      'mobile_number': mobileNumber,
      'email': email,
      'user_type': userType.toString(),
      'encrypted_aadhar': encryptedAadhar,
      'two_fa_enabled': twoFaEnabled,
      'two_fa_method': twoFaMethod,
      'profile_completed': profileCompleted,
      'is_verified': isVerified,
      'avatar_url': avatarUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? mobileNumber,
    String? email,
    UserType? userType,
    String? encryptedAadhar,
    bool? twoFaEnabled,
    String? twoFaMethod,
    bool? profileCompleted,
    bool? isVerified,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      email: email ?? this.email,
      userType: userType ?? this.userType,
      encryptedAadhar: encryptedAadhar ?? this.encryptedAadhar,
      twoFaEnabled: twoFaEnabled ?? this.twoFaEnabled,
      twoFaMethod: twoFaMethod ?? this.twoFaMethod,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      isVerified: isVerified ?? this.isVerified,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
