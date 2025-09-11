class PackagingModel {
  final String? id; // id en base supabase
  final String? productId; // lien vers products
  final String? material;
  final String? shape;
  final String? recycling;
  final int? numberOfUnits;
  final double? quantityPerUnitValue;
  final String? quantityPerUnit;
  final String? quantityPerUnitUnit;
  final double? weightMeasured;
  bool to_throw;


  PackagingModel({
    this.id,
    this.productId,
    this.material,
    this.shape,
    this.recycling,
    this.numberOfUnits,
    this.quantityPerUnitValue,
    this.quantityPerUnit,
    this.quantityPerUnitUnit,
    this.weightMeasured,
    required this.to_throw,
  });

  /// 🔹 Depuis Supabase (DB → PackagingModel)
  factory PackagingModel.fromJson(Map<String, dynamic> json) {
    return PackagingModel(
      id: json['id']?.toString(),
      productId: json['product_id']?.toString(),
      material: json['material'],
      shape: json['name'] ?? json['shape'],
      recycling: json['recycling'],
      numberOfUnits: json['number_of_units'],
      quantityPerUnitValue:
      (json['quantity_per_unit_value'] ?? 0).toDouble(),
      quantityPerUnit: json['quantity_per_unit'],
      quantityPerUnitUnit: json['quantity_per_unit_unit'],
      weightMeasured: (json['weight_measured'] ?? 0).toDouble(),
      to_throw: json["to_throw"] ?? false,
    );
  }

  /// 🔹 Depuis OFF API brut
  factory PackagingModel.fromOffJson(Map<String, dynamic> json) {
    return PackagingModel(
      material: json['material'],
      shape: json['shape'],
      recycling: json['recycling'],
      numberOfUnits: json['number_of_units'],
      quantityPerUnitValue:
      (json['quantity_per_unit_value'] ?? 0).toDouble(),
      quantityPerUnit: json['quantity_per_unit'],
      quantityPerUnitUnit: json['quantity_per_unit_unit'],
      weightMeasured: (json['weight_measured'] ?? 0).toDouble(),
      to_throw: json["to_throw"] ?? false,
    );
  }

  /// 🔹 Vers Supabase (PackagingModel → DB)
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "product_id": productId,
      "material": material,
      "name": shape, // je mappe shape → name
      "recycling": recycling,
      "number_of_units": numberOfUnits,
      "quantity_per_unit_value": quantityPerUnitValue,
      "quantity_per_unit": quantityPerUnit,
      "quantity_per_unit_unit": quantityPerUnitUnit,
      "weight_measured": weightMeasured,
      "to_throw": to_throw,
    };
  }
}
