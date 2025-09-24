import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tri_dechets/pages/auth/information_page.dart';
import '../../utils/snackBar_util.dart';
import '../../utils/theme_util.dart';
import 'login_page.dart';

class AccountInfoPage extends StatefulWidget {
  const AccountInfoPage({super.key});

  @override
  State<AccountInfoPage> createState() => _AccountInfoPageState();
}

class _AccountInfoPageState extends State<AccountInfoPage> {
  final supabase = Supabase.instance.client;
  String? codePostal;
  String? commune;
  String? name;
  String? avatar;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('users')
        .select('code_postal, commune, name, avatar')
        .eq('id', user.id)
        .maybeSingle();

    if (mounted && response != null) {
      setState(() {
        codePostal = response['code_postal'];
        commune = response['commune'];
        name = response['name'];
        avatar = response['avatar'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    final avatarUrl = avatar;
    final displayName = name ?? "Utilisateur";
    final email = user?.email ?? "Non défini";

    return Scaffold(
      appBar: buildCustomAppBar(context,"A-propos"),
      body: Stack(
        children: [
          buildFancyHeader("Mes infos"),
          Positioned(
            top: 130,
            left: 0,
            right: 0,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundImage: (avatarUrl) != null
                      ? NetworkImage(avatarUrl)
                      : null,
                  backgroundColor: Colors.deepPurple,
                  child: (avatarUrl) == null
                      ? const Icon(Icons.person, size: 45, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  displayName,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(email, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),


          Positioned(
            top: 290,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow(Icons.location_on_outlined, "Code postal :", codePostal),
                  const SizedBox(height: 20),
                  _infoRow(Icons.home_work_outlined, "Commune :", commune),
                  const SizedBox(height: 20),
                  _infoRow(Icons.flag_outlined, "Pays :", "France"),
                  const SizedBox(height: 20),
                  Positioned(
                    top: 470,
                    right: 200,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const InformationPage()),
                        ).then((_) => _loadUserData());
                      },
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text("Modifier"),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),


          Padding(
            padding: const EdgeInsets.only(top: 550),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.black),
                  title: const Text("Déconnexion"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () async {
                    await supabase.auth.signOut();
                    if (!context.mounted) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => LoginPage()),
                    );
                  },
                ),
                const Spacer(),
                const Text(
                  "Version 1.0",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String? value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.deepPurple),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            "$label ${value ?? ''}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
