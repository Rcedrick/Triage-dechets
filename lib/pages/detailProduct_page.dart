import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';
import '../API/product/offProduct.dart';
import '../services/product_service.dart';
import '../utils/theme_util.dart';

class DetailProductPage extends StatefulWidget {
  final String barcode;

  const DetailProductPage({
    super.key,
    required this.barcode,
  });

  @override
  State<DetailProductPage> createState() => _DetailProductPageState();
}

class _DetailProductPageState extends State<DetailProductPage> {
  late Future<Map<String, dynamic>> _futureData;

  @override
  void initState() {
    super.initState();
    _futureData = _loadData();
  }

  Future<Map<String, dynamic>> _loadData() async {
    final product = await ProductService().getOrFetchProduct(widget.barcode);
    final offProduct = await ProductService().fetchProductFromApi(widget.barcode);
    return {
      "db": product,
      "off": offProduct,
    };
  }

  Barcode _getBarcodeType(String code) {
    if (code.length == 13 || code.length == 12) {
      return Barcode.ean13();
    } else if (code.length == 8 || code.length == 7) {
      return Barcode.ean8();
    } else {
      return Barcode.code128();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _futureData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
              body: Center(child: Text("Produit introuvable")));
        }

        final product = snapshot.data!["db"] as ProductModel?;
        final offProduct = snapshot.data!["off"] as OffProduct?;

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: buildCustomAppBar("Détail sur le produit"),
            backgroundColor: backgroundColor,
            body: Column(
              children: [
                buildFancyHeader(product?.name ?? offProduct?.name ?? "Produit"),
                const TabBar(
                  tabs: [
                    Tab(text: 'Aperçu'),
                    Tab(text: 'Emballage'),
                  ],
                  indicatorColor: primaryColor,
                  labelColor: primaryColor,
                  unselectedLabelColor: Colors.grey,
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildApercuTab(product, offProduct),
                      _buildPackagingTab(product?.id.toString() ?? ""),

                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildApercuTab(ProductModel? product, OffProduct? offProduct) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (product?.image_url.isNotEmpty == true ||
              (offProduct?.imageUrl?.isNotEmpty ?? false))
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  product?.image_url.isNotEmpty == true
                      ? product!.image_url
                      : offProduct?.imageUrl ?? "",
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.image,
                      size: 100, color: Colors.grey),
                ),
              ),
            ),
          const SizedBox(height: 20),

          _buildSectionTitle("Nom commercial"),
          Text(
            product?.name ?? offProduct?.name ?? "-",
            style: const TextStyle(color: textColor),
          ),
          const SizedBox(height: 10),

          _buildSectionTitle("Poids/ Quantité"),
          Row(
            children: [
              Text(
                offProduct?.quantity?.toString() ?? "-",
                style: const TextStyle(color: textColor),
              ),
              const SizedBox(width: 4),
              Text(
                offProduct?.unity ?? "-",
                style: const TextStyle(color: textColor),
              ),
            ],
          ),

          const SizedBox(height: 10),

          _buildSectionTitle("Marque(s)"),
          Text(
            product?.brand ?? offProduct?.brands ?? "-",
            style: const TextStyle(color: textColor),
          ),
          const SizedBox(height: 10),

          _buildSectionTitle("Code-barre"),
          BarcodeWidget(
            barcode: _getBarcodeType(product?.barcode ?? offProduct?.code ?? ""),
            data: product?.barcode ?? offProduct?.code ?? "",
            width: 300,
            height: 100,
            drawText: true,
            backgroundColor: cardColor,
          ),

          const SizedBox(height: 20),

          _buildSectionTitle("Pays"),
          Text(offProduct?.countries ?? "-", style: const TextStyle(color: textColor)),

          const SizedBox(height: 20),

          _buildSectionTitle("Catégories"),
          Text(offProduct?.categoriesOld ?? "-", style: const TextStyle(color: textColor)),

          const SizedBox(height: 20),

          _buildSectionTitle("Labels"),
          Text(offProduct?.labels ?? "-", style: const TextStyle(color: textColor)),
        ],
      ),
    );
  }

  Widget _buildPackagingTab(String productId) {
    final supabase = Supabase.instance.client;

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: supabase
          .from('packagings')
          .select('id, name, quantity_per_unit, number_of_units, to_throw, materials(type)')
          .eq('product_id', productId)
          .then((res) => (res as List).cast<Map<String, dynamic>>()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text("Aucun emballage renseigné",
                style: TextStyle(color: textColor)),
          );
        }

        final packagings = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: packagings.length,
          itemBuilder: (context, index) {
            final p = packagings[index];
            final materialType = (p['materials']?['type']) ?? "-";
            final bool toThrow = p['to_throw'] ?? false;

            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.inventory_2, color: primaryColor),
                title: Text(p['name'] ?? "Sans nom"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Matériau : $materialType"),
                    Text("Quantité par unité : ${p['quantity_per_unit'] ?? "-"}"),
                    Text("Nombre d’unités : ${p['number_of_units'] ?? "-"}"),
                  ],
                ),

                trailing: StatefulBuilder(
                  builder: (context, setState) {
                    return Switch(
                      value: p['to_throw'] ?? false,
                      activeColor: primaryColor,
                      onChanged: (newValue) async {
                        setState(() {
                          p['to_throw'] = newValue;
                        });
                        final updated = await ProductService().updateToThrow(p['id'].toString(), newValue);
                        if (updated == null) {
                          setState(() {
                            p['to_throw'] = !newValue;
                          });
                        }
                      },
                    );
                  },
                ),

              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
    );
  }
}
