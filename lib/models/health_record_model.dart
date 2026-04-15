enum RecordType {
  report,
  prescription,
  labReport,
  imaging,
  other;

  static RecordType fromString(String value) {
    switch (value) {
      case 'report':
        return RecordType.report;
      case 'prescription':
        return RecordType.prescription;
      case 'lab_report':
        return RecordType.labReport;
      case 'imaging':
        return RecordType.imaging;
      case 'other':
        return RecordType.other;
      default:
        return RecordType.other;
    }
  }

  @override
  String toString() {
    switch (this) {
      case RecordType.report:
        return 'report';
      case RecordType.prescription:
        return 'prescription';
      case RecordType.labReport:
        return 'lab_report';
      case RecordType.imaging:
        return 'imaging';
      case RecordType.other:
        return 'other';
    }
  }
}

class HealthRecordModel {
  final String id;
  final String patientId;
  final String uploadedBy;
  final RecordType recordType;
  final String? title;
  final String? description;
  final String? fileUrl;
  final String? aiCategory;
  final DateTime? createdAt;

  const HealthRecordModel({
    required this.id,
    required this.patientId,
    required this.uploadedBy,
    this.recordType = RecordType.other,
    this.title,
    this.description,
    this.fileUrl,
    this.aiCategory,
    this.createdAt,
  });

  factory HealthRecordModel.fromJson(Map<String, dynamic> json) {
    return HealthRecordModel(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      uploadedBy: json['uploaded_by'] as String,
      recordType: json['record_type'] != null
          ? RecordType.fromString(json['record_type'] as String)
          : RecordType.other,
      title: json['title'] as String?,
      description: json['description'] as String?,
      fileUrl: json['file_url'] as String?,
      aiCategory: json['ai_category'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'uploaded_by': uploadedBy,
      'record_type': recordType.toString(),
      'title': title,
      'description': description,
      'file_url': fileUrl,
      'ai_category': aiCategory,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  HealthRecordModel copyWith({
    String? id,
    String? patientId,
    String? uploadedBy,
    RecordType? recordType,
    String? title,
    String? description,
    String? fileUrl,
    String? aiCategory,
    DateTime? createdAt,
  }) {
    return HealthRecordModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      recordType: recordType ?? this.recordType,
      title: title ?? this.title,
      description: description ?? this.description,
      fileUrl: fileUrl ?? this.fileUrl,
      aiCategory: aiCategory ?? this.aiCategory,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
