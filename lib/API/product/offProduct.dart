import '../../models/packaging_model.dart';

class OffProduct {
  final String code;
  final String name;
  final String quantity;
  final String unity;
  final String? brands;
  final String? imageUrl;
  final String? nutriscore;
  final double? energy;
  final double? fat;
  final double? carbohydrates;
  final double? proteins;
  final double? sugars;
  final String? categoriesOld;
  final String? labels;
  final String? countries;
  final List<PackagingModel> packagings;

  OffProduct({
    required this.code,
    required this.name,
    required this.labels,
    required this.countries,
    required this.quantity,
    required this.unity,
    this.brands,
    this.imageUrl,
    this.nutriscore,
    this.energy,
    this.fat,
    this.carbohydrates,
    this.proteins,
    this.sugars,
    this.categoriesOld,
    this.packagings = const [],
  });

  factory OffProduct.fromJson(Map<String, dynamic> json) {
      final nutriments = json["nutriments"] ?? {};

      // Gestion multiple pour énergie
      final energy = (nutriments["energy-kcal_100g"] ??
          nutriments["energy_100g"] ??
          nutriments["energy-kj_100g"] ??
          nutriments["energy"] ??
          nutriments["energy-kcal_value"]) as num?;

      return OffProduct(
        code: json["code"] ?? "",
        name: json["product_name"] ?? "Sans nom",
        quantity: json['product_quantity']?.toString() ?? '',
        unity: json['product_quantity_unit']?.toString() ?? '',
        brands: json["brands"],
        imageUrl: json["image_url"],
        nutriscore: json["nutriscore_grade"],
        energy: energy?.toDouble(),
        fat: (nutriments["fat_100g"] ??
            nutriments["fat_value"])?.toDouble(),
        carbohydrates: (nutriments["carbohydrates_100g"] ??
            nutriments["carbohydrates_value"])?.toDouble(),
        proteins: (nutriments["proteins_100g"] ??
            nutriments["proteins_value"])?.toDouble(),
        sugars: (nutriments["sugars_100g"] ??
            nutriments["sugars_value"])?.toDouble(),
        packagings: (json["packagings"] as List<dynamic>?)
            ?.map((p) => PackagingModel.fromJson(p))
            .toList() ??
            [],
        categoriesOld: json["categories_old"],
        labels: json['labels'],
        countries: json['countries'],
      );
    }
}
