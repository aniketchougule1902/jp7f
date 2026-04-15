class DispensalModel {
  final String id;
  final String pharmacistId;
  final String patientId;
  final String prescriptionId;
  final String? medicineId;
  final String? medicineName;
  final int quantity;
  final double? pricePerUnit;
  final double? totalPrice;
  final String? batchNumber;
  final bool isReturned;
  final DateTime? returnedAt;
  final DateTime dispensedAt;
  final DateTime? createdAt;

  const DispensalModel({
    required this.id,
    required this.pharmacistId,
    required this.patientId,
    required this.prescriptionId,
    this.medicineId,
    this.medicineName,
    this.quantity = 0,
    this.pricePerUnit,
    this.totalPrice,
    this.batchNumber,
    this.isReturned = false,
    this.returnedAt,
    required this.dispensedAt,
    this.createdAt,
  });

  factory DispensalModel.fromJson(Map<String, dynamic> json) {
    return DispensalModel(
      id: json['id'] as String,
      pharmacistId: json['pharmacist_id'] as String,
      patientId: json['patient_id'] as String,
      prescriptionId: json['prescription_id'] as String,
      medicineId: json['medicine_id'] as String?,
      medicineName: json['medicine_name'] as String?,
      quantity: json['quantity'] as int? ?? 0,
      pricePerUnit: (json['price_per_unit'] as num?)?.toDouble(),
      totalPrice: (json['total_price'] as num?)?.toDouble(),
      batchNumber: json['batch_number'] as String?,
      isReturned: json['is_returned'] as bool? ?? false,
      returnedAt: json['returned_at'] != null
          ? DateTime.parse(json['returned_at'] as String)
          : null,
      dispensedAt: DateTime.parse(json['dispensed_at'] as String),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pharmacist_id': pharmacistId,
      'patient_id': patientId,
      'prescription_id': prescriptionId,
      'medicine_id': medicineId,
      'medicine_name': medicineName,
      'quantity': quantity,
      'price_per_unit': pricePerUnit,
      'total_price': totalPrice,
      'batch_number': batchNumber,
      'is_returned': isReturned,
      'returned_at': returnedAt?.toIso8601String(),
      'dispensed_at': dispensedAt.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  DispensalModel copyWith({
    String? id,
    String? pharmacistId,
    String? patientId,
    String? prescriptionId,
    String? medicineId,
    String? medicineName,
    int? quantity,
    double? pricePerUnit,
    double? totalPrice,
    String? batchNumber,
    bool? isReturned,
    DateTime? returnedAt,
    DateTime? dispensedAt,
    DateTime? createdAt,
  }) {
    return DispensalModel(
      id: id ?? this.id,
      pharmacistId: pharmacistId ?? this.pharmacistId,
      patientId: patientId ?? this.patientId,
      prescriptionId: prescriptionId ?? this.prescriptionId,
      medicineId: medicineId ?? this.medicineId,
      medicineName: medicineName ?? this.medicineName,
      quantity: quantity ?? this.quantity,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      totalPrice: totalPrice ?? this.totalPrice,
      batchNumber: batchNumber ?? this.batchNumber,
      isReturned: isReturned ?? this.isReturned,
      returnedAt: returnedAt ?? this.returnedAt,
      dispensedAt: dispensedAt ?? this.dispensedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
