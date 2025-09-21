import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tri_dechets/pages/home_page.dart';
import 'package:tri_dechets/pages/auth/information_page.dart';
import 'package:tri_dechets/utils/snackBar_util.dart';
import 'package:tri_dechets/services/auth_service.dart';

import '../../utils/theme_util.dart';
import '../../widgets/icon_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  bool loading = false;

  /// 🔹 Google Login
  Future<void> _handleGoogleLogin() async {
    setState(() => loading = true);

    try {
      final user = await signInWithGoogle();
      if (user == null) {
        setState(() => loading = false);
        return;
      }

      final exists = await userExists(user.id);
      if (!exists) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const InformationPage()),
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
              (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      showCustomSnackBar(context, "Erreur : $e");
    } finally {
      setState(() => loading = false);
    }
  }

  /// 🔹 Email Login
  Future<void> _handleEmailLogin() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      showCustomSnackBar(context, "Veuillez entrer un email");
      return;
    }

    setState(() => loading = true);

    try {
      await signInWithEmail(email);
      showCustomSnackBar(context,
          "Un lien de connexion a été envoyé à votre email. Vérifiez votre boîte mail 📩");
    } catch (e) {
      showCustomSnackBar(context, "Erreur : $e");
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Stack(
        children: [
          Container(
            width: double.infinity,
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

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: buildEcoBadge("DécheTri", 32, 28),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Bienvenue 👋",
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 10),

                  const Text(
                    "Connectez-vous pour continuer",
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 40),

                  TextField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      hintText: "Entrez votre email",
                      hintStyle: const TextStyle(color: Colors.white70),
                      prefixIcon:
                      const Icon(Icons.email, color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: _handleEmailLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Continuer avec email",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: const [
                      Expanded(child: Divider(color: Colors.white70)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text("OU",
                            style: TextStyle(color: Colors.white)),
                      ),
                      Expanded(child: Divider(color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  /// 🔹 Bouton Google
                  ElevatedButton.icon(
                    onPressed: _handleGoogleLogin,
                    icon: Image.asset("assets/images/google.png", height: 24),
                    label: const Text("Continuer avec Google",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          if (loading)
            Container(
              color: Colors.black45,
              child: const Center(
                  child: CircularProgressIndicator(color: Colors.white)),
            ),
        ],
      ),
    );
  }
}
