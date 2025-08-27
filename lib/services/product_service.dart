import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';

class ProductService {
  final supabase = Supabase.instance.client;

  Future<String> insertProduct(ProductModel product) async {
    try {
      final response = await supabase
          .from("products")
          .insert(product.toJson())
          .select("id")
          .single();

      final productId = response["id"].toString();
      print("✅ Produit inséré avec id: $productId");
      return productId;
    } catch (e) {
      print("❌ Erreur insertion: $e");
      rethrow;
    }
  }


  Future<List<ProductModel>> fetchProducts() async {
    final response = await supabase.from("products").select();
    return (response as List).map((json) {
      return ProductModel.fromJson(json, json["id"].toString());
    }).toList();
  }
}
