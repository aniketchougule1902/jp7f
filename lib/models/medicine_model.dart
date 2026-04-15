class MedicineModel {
  final String id;
  final String? category;
  final String productName;
  final String? composition;
  final String? description;
  final String? sideEffects;
  final List<String> drugInteractions;
  final String? addedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MedicineModel({
    required this.id,
    this.category,
    required this.productName,
    this.composition,
    this.description,
    this.sideEffects,
    this.drugInteractions = const [],
    this.addedBy,
    this.createdAt,
    this.updatedAt,
  });

  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    return MedicineModel(
      id: json['id'] as String,
      category: json['category'] as String?,
      productName: json['product_name'] as String,
      composition: json['composition'] as String?,
      description: json['description'] as String?,
      sideEffects: json['side_effects'] as String?,
      drugInteractions: _parseStringList(json['drug_interactions']),
      addedBy: json['added_by'] as String?,
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
      'category': category,
      'product_name': productName,
      'composition': composition,
      'description': description,
      'side_effects': sideEffects,
      'drug_interactions': drugInteractions,
      'added_by': addedBy,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  MedicineModel copyWith({
    String? id,
    String? category,
    String? productName,
    String? composition,
    String? description,
    String? sideEffects,
    List<String>? drugInteractions,
    String? addedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MedicineModel(
      id: id ?? this.id,
      category: category ?? this.category,
      productName: productName ?? this.productName,
      composition: composition ?? this.composition,
      description: description ?? this.description,
      sideEffects: sideEffects ?? this.sideEffects,
      drugInteractions: drugInteractions ?? this.drugInteractions,
      addedBy: addedBy ?? this.addedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
