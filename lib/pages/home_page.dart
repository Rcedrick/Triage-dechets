import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tri_dechets/pages/scan_page.dart';
import '../utils/theme_util.dart';
import 'auth/login_page.dart';

class HomePage extends StatelessWidget {
  final Function(int) onMenuTap;
  const HomePage({super.key, required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBanner(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  _buildSectionTitle("Actions à faire"),
                  _buildActions(context),

                  const SizedBox(height: 20),
                  _buildSectionTitle("Produits scannés récemment"),
                  _buildRecentScans(),

                  const SizedBox(height: 20),
                  _buildSectionTitle("Astuces & Actus"),
                  _buildTips(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        buildFancyHeader(
          "DécheTri",
          logoPath: "assets/images/logo.png",
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color:textColor),
    );
  }

  Widget _buildActions(BuildContext context) {
    final actions = [
      {
        "label": "Déchets",
        "icon": Icons.delete,
        "onTap": () {
          onMenuTap(1);
        },
      },
      {
        "label": "Scan",
        "icon": Icons.qr_code,
        "onTap": () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ScanPage(),
            ),
          );
        },
      },
      {
        "label": "Map",
        "icon": Icons.map,
        "onTap": () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginPage(),
            ),
          );
        },
      },
      {
        "label": "Historique",
        "icon": Icons.history,
        "onTap": () {
          onMenuTap(3);
        },
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1,
        physics: const NeverScrollableScrollPhysics(),
        children: actions.map((action) {
          return GestureDetector(
            onTap: action["onTap"] as void Function()?,
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    action["icon"] as IconData,
                    size: 40,
                    color: primaryColor,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    action["label"] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecentScans() {
    final supabase = Supabase.instance.client;

    return SizedBox(
      height: 180,
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase
            .from('products')
            .stream(primaryKey: ['id'])
            .order('date_scan', ascending: false)
            .limit(6),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Aucun produit scanné récemment"));
          }

          final products = snapshot.data!;

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (context, index) {
              final prod = products[index];
              return Container(
                width: 140,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: prod["image_url"] != null && prod["image_url"].toString().isNotEmpty
                          ? Image.network(
                        prod["image_url"],
                        height: 100,
                        width: 140,
                        fit: BoxFit.cover,
                      )
                          : Container(
                        height: 100,
                        width: 140,
                        color: cardColor,
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            prod["name"] ?? "-",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            prod["barcode"] ?? "",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }


  Widget _buildTips() {
    final tips = [
      {
        "title": " Bien lire les étiquettes",
        "content": """
Prendre le temps de lire les étiquettes permet de mieux contrôler ce que l’on mange.
• Vérifiez la liste des ingrédients : le premier est celui présent en plus grande quantité.
• Surveillez les additifs, allergènes et sucres ajoutés.
• Comparez les valeurs nutritionnelles pour choisir le produit le plus sain.
"""
      },
      {
        "title": " Choisir Bio, pourquoi ?",
        "content": """
Les produits bio sont cultivés sans pesticides chimiques de synthèse ni OGM.
• Ils respectent l’environnement et la biodiversité.
• Ils soutiennent une agriculture plus durable.
• Ils contiennent souvent moins de résidus chimiques.
"""
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...tips.map((tip) {
          return Card(
            child: ExpansionTile(
              leading: const Icon(Icons.lightbulb, color: Colors.yellow),
              title: Text(
                tip['title']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    tip['content']!,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
              ],
            ),
          );
        }).toList(),

        const SizedBox(height: 30),

        const Text(
          "À propos de cette application",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "Cette application vous aide à scanner, comprendre et comparer vos produits alimentaires "
              "pour faire des choix plus sains et responsables au quotidien.\n"
              "Informations, conseils et astuces sont mis à votre disposition pour mieux consommer.",
          style: TextStyle(color: Colors.black87, height: 1.4),
        ),
      ],
    );
  }
}
