class InventoryModel {
  final String id;
  final String pharmacistId;
  final String medicineId;
  final String? medicineName;
  final String? batchNumber;
  final int quantity;
  final double? pricePerUnit;
  final DateTime? manufacturingDate;
  final DateTime? expiryDate;
  final String? supplierName;
  final bool isLowStock;
  final int lowStockThreshold;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const InventoryModel({
    required this.id,
    required this.pharmacistId,
    required this.medicineId,
    this.medicineName,
    this.batchNumber,
    this.quantity = 0,
    this.pricePerUnit,
    this.manufacturingDate,
    this.expiryDate,
    this.supplierName,
    this.isLowStock = false,
    this.lowStockThreshold = 10,
    this.createdAt,
    this.updatedAt,
  });

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryModel(
      id: json['id'] as String,
      pharmacistId: json['pharmacist_id'] as String,
      medicineId: json['medicine_id'] as String,
      medicineName: json['medicine_name'] as String?,
      batchNumber: json['batch_number'] as String?,
      quantity: json['quantity'] as int? ?? 0,
      pricePerUnit: (json['price_per_unit'] as num?)?.toDouble(),
      manufacturingDate: json['manufacturing_date'] != null
          ? DateTime.parse(json['manufacturing_date'] as String)
          : null,
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'] as String)
          : null,
      supplierName: json['supplier_name'] as String?,
      isLowStock: json['is_low_stock'] as bool? ?? false,
      lowStockThreshold: json['low_stock_threshold'] as int? ?? 10,
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
      'pharmacist_id': pharmacistId,
      'medicine_id': medicineId,
      'medicine_name': medicineName,
      'batch_number': batchNumber,
      'quantity': quantity,
      'price_per_unit': pricePerUnit,
      'manufacturing_date':
          manufacturingDate?.toIso8601String().split('T').first,
      'expiry_date': expiryDate?.toIso8601String().split('T').first,
      'supplier_name': supplierName,
      'is_low_stock': isLowStock,
      'low_stock_threshold': lowStockThreshold,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  InventoryModel copyWith({
    String? id,
    String? pharmacistId,
    String? medicineId,
    String? medicineName,
    String? batchNumber,
    int? quantity,
    double? pricePerUnit,
    DateTime? manufacturingDate,
    DateTime? expiryDate,
    String? supplierName,
    bool? isLowStock,
    int? lowStockThreshold,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InventoryModel(
      id: id ?? this.id,
      pharmacistId: pharmacistId ?? this.pharmacistId,
      medicineId: medicineId ?? this.medicineId,
      medicineName: medicineName ?? this.medicineName,
      batchNumber: batchNumber ?? this.batchNumber,
      quantity: quantity ?? this.quantity,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      manufacturingDate: manufacturingDate ?? this.manufacturingDate,
      expiryDate: expiryDate ?? this.expiryDate,
      supplierName: supplierName ?? this.supplierName,
      isLowStock: isLowStock ?? this.isLowStock,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
