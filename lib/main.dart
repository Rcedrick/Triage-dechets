import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tri_dechets/pages/auth/AccountInfo_page.dart';
import 'package:tri_dechets/pages/history_page.dart';
import 'package:tri_dechets/pages/home_page.dart';
import 'package:tri_dechets/pages/map_page.dart';
import 'package:tri_dechets/pages/product_page.dart';
import 'package:tri_dechets/pages/profile_page.dart';
import 'package:tri_dechets/pages/scan_page.dart';
import 'package:tri_dechets/services/auth_service.dart';
import 'package:tri_dechets/splashes/splash_app.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:tri_dechets/utils/theme_util.dart';

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
      title: 'DécheTri',
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
  String? codePostal;
  String? commune;

  void setCurrentIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  final List<String> _titles = const [
    "Accueil",
    "Déchets",
    "Carte",
    "Historique",
  ];

  @override
  void initState() {
    super.initState();
    getUserData().then((userData) {
      if (userData != null) {
        setState(() {
          codePostal = userData['code_postal'];
          commune = userData['commune'];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      HomePage(onMenuTap: setCurrentIndex),
      ProductPage(onMenuTap: setCurrentIndex),
      MapPage(
        codePostal: codePostal ?? '',
        commune: commune ?? '',
      ),
      HistoryPage(onMenuTap: setCurrentIndex),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: _currentIndex == 0
            ? null
            : IconButton(
          icon: const Icon(Icons.arrow_back, color: cardColor),
          onPressed: () {
            setState(() {
              _currentIndex = 0;
            });
          },
        ),
        title: _currentIndex == 0
            ? GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ProfileScreen()),
            );
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: (Supabase.instance.client.auth.currentUser?.userMetadata?["avatar_url"]) != null
                    ? NetworkImage(Supabase.instance.client.auth.currentUser!.userMetadata!["avatar_url"])
                    : null,
                backgroundColor: primaryColor,
                child: (Supabase.instance.client.auth.currentUser?.userMetadata?["avatar_url"]) == null
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
            ],
          ),
        )
            : Text(
          _titles[_currentIndex],
          style: titleTextStyle.copyWith(fontSize: 22, fontWeight: FontWeight.bold, color: cardColor),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primaryColor.withOpacity(0.9),
                primaryColor.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      body: _pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        backgroundColor: cardColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Accueil",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.delete),
            label: "Déchets",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: "Carte",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "Historique",
          ),
        ],
      ),
    );
  }
}



