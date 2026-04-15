class SessionModel {
  final String id;
  final String userId;
  final String? deviceName;
  final String? deviceType;
  final String? ipAddress;
  final bool isActive;
  final DateTime? lastActiveAt;
  final DateTime? createdAt;

  const SessionModel({
    required this.id,
    required this.userId,
    this.deviceName,
    this.deviceType,
    this.ipAddress,
    this.isActive = true,
    this.lastActiveAt,
    this.createdAt,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      deviceName: json['device_name'] as String?,
      deviceType: json['device_type'] as String?,
      ipAddress: json['ip_address'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      lastActiveAt: json['last_active_at'] != null
          ? DateTime.parse(json['last_active_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'device_name': deviceName,
      'device_type': deviceType,
      'ip_address': ipAddress,
      'is_active': isActive,
      'last_active_at': lastActiveAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  SessionModel copyWith({
    String? id,
    String? userId,
    String? deviceName,
    String? deviceType,
    String? ipAddress,
    bool? isActive,
    DateTime? lastActiveAt,
    DateTime? createdAt,
  }) {
    return SessionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      deviceName: deviceName ?? this.deviceName,
      deviceType: deviceType ?? this.deviceType,
      ipAddress: ipAddress ?? this.ipAddress,
      isActive: isActive ?? this.isActive,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
