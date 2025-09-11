import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../API/product/offProduct.dart';
import '../models/packaging_model.dart';
import '../models/product_model.dart';

class ProductService {
  final supabase = Supabase.instance.client;
  /// Vérifie si un produit est déjà en base
  Future<ProductModel?> getProductFromDb(String barcode) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw Exception("Aucun utilisateur connecté");
    }

    final res = await supabase
        .from('products')
        .select()
        .eq('barcode', barcode)
        .eq('user_id', user.id)
        .maybeSingle();

    if (res == null) return null;
    return ProductModel.fromJson(res, res["id"].toString());
  }


  /// Récupère un produit depuis Open Food Facts
  Future<OffProduct?> fetchProductFromApi(String barcode) async {
    final url = Uri.parse("https://world.openfoodfacts.org/api/v2/product/$barcode.json");

    final res = await http.get(url);
    print("📡 Status: ${res.statusCode}");
    print("📦 Body: ${res.body}");
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data['status'] == 1) {
        return OffProduct.fromJson(data['product']);
      }
    }
    return null;
  }

  /// Sauvegarde le produit OFF + ses packagings dans Supabase
  Future<ProductModel> saveProductFromApi(OffProduct offProduct) async {
    final inserted = await supabase.from("products").insert({
      "name": offProduct.name,
      "barcode": offProduct.code,
      "brand": offProduct.brands ?? "Inconnu",
      "image_url": offProduct.imageUrl ?? "",
      "date_scan": DateTime.now().toIso8601String(),
      "to_throw": false,
      "user_id": supabase.auth.currentUser?.id ?? "",
    }).select().single();

    final productId = inserted["id"].toString();

    // Charger les matériaux existants
    final materialsRes = await supabase.from('materials').select('id,type');
    final materialsMap = {
      for (var m in materialsRes) (m['type'] as String).toLowerCase(): m['id']
    };

    // Gérer les packagings
    if (offProduct.packagings != null) {
      // APRÈS (✅ on itère directement sur les PackagingModel)
      for (final packaging in offProduct.packagings) {
        final rawMaterial = (packaging.material ?? "unknown")
            .replaceFirst(RegExp(r'^(en:|fr:)'), "");
        final recycling = packaging.recycling;
        final category = categorizeMaterial(rawMaterial, recycling);
        final materialId = materialsMap[category];

        await supabase.from("packagings").insert({
          "product_id": productId,
          "material": rawMaterial,
          "material_id": materialId,
          "name": (packaging.shape ?? "").replaceFirst(RegExp(r'^(en:|fr:)'), ""),
          "number_of_units": packaging.numberOfUnits ?? 1,
          "quantity_per_unit_value": packaging.quantityPerUnitValue ?? 0,
          "quantity_per_unit": packaging.quantityPerUnit ?? "",
          "quantity_per_unit_unit": packaging.quantityPerUnitUnit ?? "",
          "weight_measured": packaging.weightMeasured ?? 0,
          "recycling": recycling ?? "",
        });
      }
    }

    return ProductModel.fromJson(inserted, productId);
  }

  /// Vérifie en DB → sinon API → insère → retourne ProductModel
  Future<ProductModel?> getOrFetchProduct(String barcode) async {
    final dbProduct = await getProductFromDb(barcode);
    if (dbProduct != null) return dbProduct;

    final apiProduct = await fetchProductFromApi(barcode);
    if (apiProduct == null) return null;

    return await saveProductFromApi(apiProduct);
  }

  /// Liste les produits de l’utilisateur
  Future<List<ProductModel>> fetchProducts() async {
    final response = await supabase.from("products").select();
    return (response as List).map((json) {
      return ProductModel.fromJson(json, json["id"].toString());
    }).toList();
  }

  /// Récupère les packagings par type de matériaux
  Future<List<Map<String, dynamic>>> fetchPackagingsByTypes(
      List<String> types) async {
    try {
      final response = await supabase
          .from("packagings")
          .select("""
            id,
            name,
            material,
            number_of_units,
            quantity_per_unit,
            quantity_per_unit_value,
            quantity_per_unit_unit,
            weight_measured,
            products:products(id, name, brand, image_url),
            materials:materials!inner(id, type, description)
          """)
          .eq("to_throw", "FALSE")
          .inFilter("materials.type", types);

      if (response == null) return [];

      return (response as List)
          .where((p) => p != null)
          .map((p) => p as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print("❌ Erreur fetchPackagingsByTypes: $e");
      return [];
    }
  }

  /// Catégorisation matériau
  String categorizeMaterial(String? rawMaterial, String? recycling) {
    if (rawMaterial == null) return "other";
    final mat = rawMaterial.toLowerCase();

    if (recycling != null && recycling.toLowerCase().contains("discard")) {
      return "non-recyclable";
    }
    if (mat.contains("pp") || mat.contains("pet") || mat.contains("plastic") || mat.contains("poly")) {
      return "plastic";
    }
    if (mat.contains("aluminium") || mat.contains("steel") || mat.contains("metal")) {
      return "metal";
    }
    if (mat.contains("paper") || mat.contains("cardboard")) {
      return "paper-or-cardboard";
    }
    if (mat.contains("glass")) {
      return "glass";
    }
    if (mat.contains("non_recyclable") || mat.contains("non-biodegradable")) {
      return "non-recyclable";
    }
    return "other";
  }

  Future<bool?> updateToThrow(String packagingId, bool toThrow) async {
    try {
      final res = await supabase
          .from('packagings')
          .update({"to_throw": toThrow})
          .eq('id', packagingId)
          .select('to_throw')
          .maybeSingle();

      if (res != null) {
        return res["to_throw"] as bool;
      }
    } catch (e) {
      print("❌ Erreur update to_throw: $e");
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> fetchProductsWithThrownPackagings() async {
    try {
      final response = await supabase
          .from("products")
          .select("""
            id,
            name,
            barcode,
            brand,
            image_url,
            date_scan,
            packagings (
              id,
              name,
              number_of_units,
              quantity_per_unit,
              quantity_per_unit_value,
              quantity_per_unit_unit,
              weight_measured,
              to_throw,
              material:materials ( type )
            )
          """)
          .order("date_scan", ascending: false);

      if (response == null || response is! List) {
        return [];
      }

      final List data = response;

      return data.map<Map<String, dynamic>>((prod) {
        final packagings = (prod["packagings"] as List?)
            ?.where((p) => p["to_throw"] == true)
            .toList() ??
            [];

        return {
          ...prod as Map<String, dynamic>,
          "packagings": packagings,
        };
      }).where((prod) => (prod["packagings"] as List).isNotEmpty).toList();
    } catch (e) {
      print("❌ Erreur fetchProductsWithThrownPackagings: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchProductsWithAllPackagings() async {
    try {
      final response = await supabase
          .from("products")
          .select("""
          id,
          name,
          barcode,
          brand,
          image_url,
          date_scan,
          packagings (
            id,
            name,
            number_of_units,
            quantity_per_unit,
            quantity_per_unit_value,
            quantity_per_unit_unit,
            weight_measured,
            to_throw,
            material:materials ( type )
          )
        """)
          .order("date_scan", ascending: false);

      if (response == null || response is! List) {
        return [];
      }

      final List data = response;

      return data.map<Map<String, dynamic>>((prod) {
        final packagings = (prod["packagings"] as List?) ?? [];
        return {
          ...prod as Map<String, dynamic>,
          "packagings": packagings, // pas de filtre
        };
      }).toList();
    } catch (e) {
      print("❌ Erreur fetchProductsWithAllPackagings: $e");
      return [];
    }
  }





}
