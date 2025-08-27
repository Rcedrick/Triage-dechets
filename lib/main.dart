import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tri_dechets/pages/home_page.dart';
import 'package:tri_dechets/pages/product_page.dart';
import 'package:tri_dechets/splashes/splash_app.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://udgltnxkkcdopaupbxgd.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVkZ2x0bnhra2Nkb3BhdXBieGdkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3ODcyMjgsImV4cCI6MjA3MTM2MzIyOH0.BvCHGNaWJExkRbfGNdh2LzR0iW_k-JOt38HkKr8S6I8',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenNutri',
      debugShowCheckedModeBanner: false,
      home: const SplashApp(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  void setCurrentIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  final List<String> _titles = const [
    "Acceuil",
    "Map",
    "Déchet",
  ];

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      HomePage(onMenuTap: setCurrentIndex),
      ProductPage()
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _titles[_currentIndex],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple, Colors.deepPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          Row(
            children: [
              ClipOval(
                child: Image.asset(
                  'assets/images/logo.png', // Assure-toi que ton chemin est correct
                  height: 30,
                  width: 30,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                "Open Nutri",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ],

      ),

      body: _pages[_currentIndex],
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _currentIndex,
        onTap: setCurrentIndex,
        items: [
          SalomonBottomBarItem(
            icon: const Icon(Icons.home),
            title: const Text("Accueil"),
            selectedColor: Colors.purple.shade700,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.favorite),
            title: const Text("Favoris"),
            selectedColor: Colors.purple.shade700,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.qr_code_scanner),
            title: const Text("Scan"),
            selectedColor: Colors.purple.shade700,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.history),
            title: const Text("Historique"),
            selectedColor: Colors.purple.shade700,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.person),
            title: const Text("Profile"),
            selectedColor: Colors.purple.shade700,
          ),
        ],
      ),
    );
  }
}


