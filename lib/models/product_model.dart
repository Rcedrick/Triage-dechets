class ProductModel {
  String? id;
  String name;
  String barcode;
  String brand;
  List<String> packaging;
  List<String> packaging_material;
  String image_url;
  DateTime date_scan;
  bool to_throw;
  String user_id;

  ProductModel({
    this.id,
    required this.name,
    required this.barcode,
    required this.brand,
    required this.packaging,
    required this.packaging_material,
    required this.image_url,
    required this.date_scan,
    required this.to_throw,
    required this.user_id,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "barcode": barcode,
      "brand": brand,
      "packaging": packaging,
      "packaging_material": packaging_material,
      "image_url": image_url,
      "date_scan": date_scan.toIso8601String(),
      "to_throw": to_throw,
      "user_id": user_id,
    };
  }

  factory ProductModel.fromJson(Map<String, dynamic> json, String id) {
    return ProductModel(
      id: id,
      name: json["name"] ?? "",
      barcode: json["barcode"] ?? "",
      brand: json["brand"] ?? "",
      packaging: List<String>.from(json["packaging"] ?? []),
      packaging_material: List<String>.from(json["packaging_material"] ?? []),
      image_url: json["image_url"] ?? "",
      date_scan: DateTime.tryParse(json["date_scan"] ?? "") ?? DateTime.now(),
      to_throw: json["to_throw"] ?? false,
      user_id: json["user_id"] ?? "",
    );
  }
}
