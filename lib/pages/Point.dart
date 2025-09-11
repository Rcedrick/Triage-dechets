import 'package:flutter/material.dart';

class LoginTestPage extends StatelessWidget {
  const LoginTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFB2FFCB), // vert clair
              Color(0xFF00C896), // vert plus foncé
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🔹 Logo
            Image.asset(
              "assets/images/logo.png", // Mets ton logo ici
              height: 120,
            ),
            const SizedBox(height: 20),

            // 🔹 Nom de l’app
            const Text(
              "ÉcoTri",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),

            // 🔹 Slogan
            const Text(
              "Recyclez intelligemment",
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 80),

            // 🔹 Bouton Se connecter
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
              ),
              onPressed: () {
                // 👉 Action connexion
              },
              child: const Text(
                "Se connecter",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 50),

            // 🔹 Footer version
            const Text(
              "© 2025 ÉcoTri v1.0",
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
