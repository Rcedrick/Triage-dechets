import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

import '../models/product_model.dart';
import '../services/product_service.dart';

class DetailProductPage extends StatefulWidget {
  final String barcode;
  const DetailProductPage({super.key, required this.barcode});

  @override
  State<DetailProductPage> createState() => _DetailProductPageState();
}

class _DetailProductPageState extends State<DetailProductPage> {
  Map<String, dynamic>? product;
  final ProductService _productService = ProductService();

  @override
  void initState() {
    super.initState();
    _fetchProduct();
  }

  Future<void> _fetchProduct() async {
    final url = Uri.parse("https://world.openfoodfacts.org/api/v0/product/${widget.barcode}.json");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        product = data['product'];
      });
    }
  }

  List<String> extractPackagingMaterials(Map<String, dynamic> json) {
    if (json["packagings_materials"] == null) return [];

    final materials = json["packagings_materials"] as Map<String, dynamic>;

    return materials.keys
        .where((k) => k != "all" && !k.contains("unknown"))
        .map((k) => k.replaceFirst("en:", "").replaceFirst("fr:", ""))
        .toList();
  }

  Future<void> _saveProduct() async {
    if (product == null) return;

    final prod = ProductModel(
      name: product!["product_name"] ?? "Sans nom",
      barcode: widget.barcode,
      brand: product!["brands"] ?? "Inconnu",
      packaging: (product!["packaging_shapes_tags"] as List<dynamic>?)
          ?.map((e) => e.toString().replaceAll(RegExp(r'^(en:|fr:)'), ''))
          .toList()
          ?? [],
      packaging_material: extractPackagingMaterials(product!),
      image_url: product!["image_url"] ?? "",
      date_scan: DateTime.now(),
      to_throw: false,
      user_id: Supabase.instance.client.auth.currentUser?.id ?? "",
    );
    final productId = await _productService.insertProduct(prod);
    final supabase = Supabase.instance.client;
    if (prod.packaging_material.isNotEmpty) {
      final materialsRes = await supabase.from('materials').select('id,type');
      final materialsMap = {
        for (var m in materialsRes)
          (m['type'] as String).toLowerCase(): m['id']
      };
      for (final mat in prod.packaging_material) {
        final normalizedMat = mat.toLowerCase().trim();
        final materialId = materialsMap[normalizedMat];
        if (materialId != null) {
          final response = await supabase.from("product_material").insert({
            "product_id": productId,
            "material_id": materialId,
          });
          print("✅ Insert product_material OK → $response");
        } else {
          print("❌ Pas trouvé: $normalizedMat dans materialsMap");
        }
      }
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (product == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final packagingMaterials = extractPackagingMaterials(product!);

    return Scaffold(
      appBar: AppBar(title: Text(product!["product_name"] ?? "Produit")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(product!["image_url"] ?? "",
                height: 150,
                errorBuilder: (_, __, ___) => const Icon(Icons.image)),
            const SizedBox(height: 10),
            Text("Nom: ${product!["product_name"] ?? "?"}"),
            Text("Marque: ${product!["brands"] ?? "?"}"),
            Text("Emballage brut: ${product!["packaging"] ?? "?"}"),
            Text("Formes: ${(product!["packaging_shapes_tags"] ?? []).toString()}"),
            Text("Matériaux détectés: ${packagingMaterials.join(", ")}"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProduct,
              child: const Text("Ajouter à mes produits"),
            )
          ],
        ),
      ),
    );
  }
}
