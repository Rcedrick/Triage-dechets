import 'package:flutter/material.dart';
import '../services/product_service.dart';
import '../utils/material_categories.dart';
import '../utils/theme_util.dart';
import '../widgets/loading_widget.dart';
import 'detailProduct_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final ProductService _productService = ProductService();
  late Future<List<Map<String, dynamic>>> _futureHistory;

  @override
  void initState() {
    super.initState();
    _futureHistory = _productService.fetchProductsWithThrownPackagings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildCustomAppBar(context, "Historiques"),
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          buildFancyHeader("Mes emballages jetés"),
          Padding(
            padding: const EdgeInsets.only(top: 140, bottom: 80),
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _futureHistory,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingScreen();
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      "Aucun emballage jeté",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                final historyProducts = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  itemCount: historyProducts.length,
                  itemBuilder: (_, index) {
                    final prod = historyProducts[index];
                    final packagings = prod["packagings"] as List;
                    final total = prod["total_packagings"] ?? 0;
                    final thrown = prod["thrown_count"] ?? 0;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
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
                              _futureHistory = _productService.fetchProductsWithThrownPackagings();
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
                                      "${prod["thrown_count"]}/${prod["total_packagings"]} emballages jetés",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey,
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
                                          final type =
                                          p["material"]?["type"] as String?;
                                          final color = MaterialCategories.getCategoryColor(type ?? "other");


                                          return Container(
                                            margin: const EdgeInsets.only(
                                                right: 12),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                CircleAvatar(
                                                  radius: 8,
                                                  backgroundColor: color,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  p["name"] ??
                                                      type ??
                                                      "Inconnu",
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
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
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
