import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/material_categories.dart';
import '../utils/theme_util.dart';
import '../widgets/icon_widget.dart';
import '../widgets/loading_widget.dart';
import 'scan_page.dart';
import 'profile_page.dart';
import 'product_page.dart';
import 'map_page.dart';
import 'history_page.dart';
import '../services/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<Map<String, dynamic>?> _futureUserData;

  @override
  void initState() {
    super.initState();
    _futureUserData = getCurrentUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Chaque fois qu’on revient sur cette page → refresh des données
    setState(() {
      _futureUserData = getCurrentUserData();
    });
  }

  AppBar buildCustomAppBar(BuildContext context) {
    return AppBar(
      leading: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfilePage()),
          ).then((_) {
            setState(() {
              _futureUserData = getCurrentUserData();
            });
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            radius: 18,
            backgroundImage: (Supabase.instance.client.auth.currentUser?.userMetadata?["avatar_url"]) != null
                ? NetworkImage(Supabase.instance.client.auth.currentUser!.userMetadata!["avatar_url"])
                : null,
            backgroundColor: primaryColor,
            child: (Supabase.instance.client.auth.currentUser?.userMetadata?["avatar_url"]) == null
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
        ),
      ),
      title: const Text(
        "Accueil",
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
      ),
      centerTitle: true,
      backgroundColor: backgroundColor,
      elevation: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildCustomAppBar(context),
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _futureUserData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingScreen();
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text("Impossible de charger vos informations."));
            }
            final userData = snapshot.data!;
            final codePostal = userData["codePostal"] ?? "";
            final commune = userData["commune"] ?? "";

            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  Row(
                    children: [
                      const SizedBox(width: 20),
                      buildEcoBadge("DécheTri", 28, 25),
                    ],
                  ),
                  const SizedBox(height: 50),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ScanPage()),
                      ).then((_) {
                        setState(() {
                          _futureUserData = getCurrentUserData();
                        });
                      });
                    },
                    child: Container(
                      height: 130,
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.camera_alt, color: Colors.white, size: 34),
                          SizedBox(width: 10),
                          Text(
                            "Scanner un produit",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                  const Text("Action à faire", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 40),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.5,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _buildMenuItem(
                        Image.asset("assets/images/dechet.png", height: 100),
                        "Mes Déchets",
                            () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ProductPage()),
                          ).then((_) {
                            setState(() {
                              _futureUserData = getCurrentUserData();
                            });
                          });
                        },
                      ),
                      _buildMenuItem(
                        Image.asset("assets/images/scanner.png", height: 60),
                        "Scanner",
                            () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ScanPage()),
                          ).then((_) {
                            setState(() {
                              _futureUserData = getCurrentUserData();
                            });
                          });
                        },
                      ),
                      _buildMenuItem(
                        Image.asset("assets/images/map.png", height: 60),
                        "Points de Collecte",
                            () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MapPage(
                                codePostal: codePostal,
                                commune: commune,
                              ),
                            ),
                          ).then((_) {
                            setState(() {
                              _futureUserData = getCurrentUserData();
                            });
                          });
                        },
                      ),
                      _buildMenuItem(
                        Image.asset("assets/images/history.png", height: 60),
                        "Historique",
                            () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const HistoryPage()),
                          ).then((_) {
                            setState(() {
                              _futureUserData = getCurrentUserData();
                            });
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                  const Text(
                    "Code couleur",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 40),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Wrap(
                      spacing: 20,
                      runSpacing: 8,
                      children: MaterialCategories.all.map((category) {
                        return _buildLegendItem(category);
                      }).toList(),
                    ),
                  ),


                  const SizedBox(height: 40),

                  const Text(
                    "Produits scannés récemment",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 16),

                  _buildRecentScans(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMenuItem(Widget iconWidget, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(12),
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 60, child: iconWidget),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentScans() {
    final supabase = Supabase.instance.client;
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw Exception("Aucun utilisateur connecté");
    }

    return SizedBox(
      height: 70,
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase
            .from('products')
            .stream(primaryKey: ['id'])
            .eq('user_id', user.id)
            .order('date_scan', ascending: false)
            .limit(6),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const LoadingScreen();
          }

          final products = snapshot.data!;
          if (products.isEmpty) {
            return const Center(child: Text("Aucun produit scanné récemment"));
          }

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final prod = products[index];
              return _buildProductItem(
                prod["name"] ?? "-",
                prod["image_url"] ?? "https://via.placeholder.com/100x100.png?text=No+Image",
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLegendItem(MaterialCategory category) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 8,
          backgroundColor: category.color,
        ),
        const SizedBox(width: 6),
        Text(
          category.name,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildProductItem(String name, String imageUrl) {
    return Container(
      height: 150,
      width: 300,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          Image.network(imageUrl, width: 80, height: 140, fit: BoxFit.cover),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios_sharp, size: 30, color: Colors.black),
        ],
      ),
    );
  }
}
