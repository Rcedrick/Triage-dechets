import 'package:flutter/material.dart';
import '../services/product_service.dart';
import '../utils/material_categories.dart';
import '../utils/snackBar_util.dart';
import '../utils/theme_util.dart';
import '../widgets/SearchField_widget.dart';
import '../widgets/loading_widget.dart';
import 'detailProduct_page.dart';
import 'scan_page.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final ProductService _productService = ProductService();
  late Future<List<Map<String, dynamic>>> _futureProducts;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _futureProducts = _productService.fetchProductsWithAllPackagings();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Chaque fois qu’on revient sur la page → refresh
    setState(() {
      _futureProducts = _productService.fetchProductsWithAllPackagings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildCustomAppBar(context, "Déchets"),
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          buildFancyHeader("Mes Déchets"),
          Padding(
            padding: const EdgeInsets.only(top: 130, left: 8, right: 8),
            child: Column(
              children: [
                buildSearchBar(
                  hintText: "Rechercher un produit...",
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
                  },
                ),
                const SizedBox(height: 10),

                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _futureProducts,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const LoadingScreen();
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text(
                            "Aucun produit trouvé",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        );
                      }

                      final products = snapshot.data!;
                      final filteredProducts = products.where((prod) {
                        final name = (prod["name"] ?? "").toString().toLowerCase();
                        final brand = (prod["brand"] ?? "").toString().toLowerCase();
                        return name.contains(searchQuery) || brand.contains(searchQuery);
                      }).toList();

                      if (filteredProducts.isEmpty) {
                        return const Center(
                          child: Text(
                            "Aucun produit ne correspond à votre recherche",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        itemCount: filteredProducts.length,
                        itemBuilder: (_, index) {
                          final prod = filteredProducts[index];
                          final packagings = prod["packagings"] as List;

                          return Dismissible(
                            key: ValueKey(prod["id"] ?? prod["barcode"]),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              color: primaryColor,
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            confirmDismiss: (direction) async {
                              return await showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text("Confirmer"),
                                  content: const Text("Voulez-vous supprimer ce produit ?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(false),
                                      child: const Text("Annuler", style: TextStyle(color: primaryColor)),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(true),
                                      child: const Text("Supprimer", style: TextStyle(color: primaryColor)),
                                    ),
                                  ],
                                ),
                              );
                            },
                            onDismissed: (direction) async {
                              final success = await _productService.deleteProduct(prod["id"]);
                              if (success) {
                                setState(() {
                                  filteredProducts.removeAt(index);
                                  _futureProducts = _productService.fetchProductsWithAllPackagings();
                                });
                                showCustomSnackBar(context, "Produit supprimé");
                              } else {
                                showCustomSnackBar(context, "Erreur lors de la suppression");
                              }
                            },
                            child: Card(
                              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 3,
                              color: cardColor,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(15),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DetailProductPage(barcode: prod["barcode"]),
                                    ),
                                  ).then((_) {
                                    setState(() {
                                      _futureProducts = _productService.fetchProductsWithAllPackagings();
                                    });
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: (prod["image_url"] != null &&
                                            prod["image_url"].toString().isNotEmpty)
                                            ? Image.network(
                                          prod["image_url"],
                                          width: 90,
                                          height: 90,
                                          fit: BoxFit.cover,
                                        )
                                            : Container(
                                          width: 90,
                                          height: 90,
                                          color: Colors.grey.shade200,
                                          child: const Icon(
                                            Icons.image_not_supported,
                                            size: 40,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              prod["name"] ?? "Sans nom",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              prod["brand"] ?? "Marque inconnue",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            SizedBox(
                                              height: 40,
                                              child: ListView.builder(
                                                scrollDirection: Axis.horizontal,
                                                itemCount: packagings.length,
                                                itemBuilder: (_, i) {
                                                  final p = packagings[i];
                                                  final type = p["material"]?["type"] as String?;
                                                  final color = MaterialCategories.getCategoryColor(type ?? "other");
                                                  return Container(
                                                    margin: const EdgeInsets.only(right: 12),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        CircleAvatar(
                                                          radius: 8,
                                                          backgroundColor: color,
                                                        ),
                                                        const SizedBox(width: 6),
                                                        Text(
                                                          p["name"] ?? type ?? "Inconnu",
                                                          style: const TextStyle(fontSize: 14),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                backgroundColor: primaryColor,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ScanPage()),
                  ).then((_) {
                    setState(() {
                      _futureProducts = _productService.fetchProductsWithAllPackagings();
                    });
                  });
                },
                child: const Icon(
                  Icons.qr_code_scanner,
                  size: 32,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
