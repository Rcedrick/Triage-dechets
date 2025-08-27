import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import 'scan_page.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final ProductService _productService = ProductService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mes Produits")),
      body: FutureBuilder<List<ProductModel>>(
        future: _productService.fetchProducts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final products = snapshot.data!;
          if (products.isEmpty) {
            return const Center(child: Text("Aucun produit"));
          }
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final p = products[index];
              return ListTile(
                leading: p.image_url.isNotEmpty
                    ? Image.network(p.image_url,
                    width: 50,
                    height: 50,
                    errorBuilder: (_, __, ___) =>
                    const Icon(Icons.image_not_supported))
                    : const Icon(Icons.image),
                title: Text(p.name),
                subtitle: Text("Marque: ${p.brand}"),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const ScanPage()));
        },
        child: const Icon(Icons.qr_code_scanner),
      ),
    );
  }
}
