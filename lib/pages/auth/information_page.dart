import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tri_dechets/main.dart';
import 'package:tri_dechets/pages/home_page.dart';
import '../../models/user_model.dart';
import '../../utils/snackBar_util.dart';
import '../../utils/theme_util.dart';
import '../../widgets/SearchField_widget.dart';

class InformationPage extends StatefulWidget {
  const InformationPage({super.key});

  @override
  State<InformationPage> createState() => _InformationPageState();
}

class _InformationPageState extends State<InformationPage> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  final _communeController = TextEditingController();
  List<Map<String, dynamic>> communes = [];

  String? selectedCommune;
  String? selectedCodePostal;

  bool loading = false;

  Future<void> fetchCommunes(String nom) async {
    if (nom.isEmpty) {
      setState(() => communes = []);
      return;
    }
    setState(() => loading = true);
    try {
      final response = await http.get(
        Uri.parse(
            'https://geo.api.gouv.fr/communes?nom=$nom&fields=nom,codesPostaux&format=json'),
      );
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          communes = data
              .map((e) => e as Map<String, dynamic>)
              .where((c) =>
          c['nom'].toString().toLowerCase() ==
              nom.toLowerCase())
              .toList();
        });
      }
    } catch (e) {
      debugPrint("Erreur: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _saveProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    if (selectedCommune == null || selectedCodePostal == null) return;

    final newUser = UserModel(
      id: user.id,
      email: user.email ?? '',
      codePostal: selectedCodePostal!,
      commune: selectedCommune!,
    );

    try {
      //await supabase.from('users').insert(newUser.toMap());
      await supabase.from('users').upsert(newUser.toMap());

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => HomePage()),
              (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      debugPrint("Erreur insertion: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur d'enregistrement: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildCustomAppBar(context,"Informations"),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Column(
          children: [
            buildFancyHeader("Commune et Code postal"),
            const SizedBox(height: 30),
            buildSearchBar(
              hintText: "Rechercher votre Commune...",
              onChanged: (value) => fetchCommunes(value),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator(color: primaryColor))
                  : communes.isEmpty
                  ? const Center(child: Text("Aucune commune trouvée"))
                  : ListView.builder(
                itemCount: communes.length,
                itemBuilder: (context, index) {
                  final commune = communes[index];
                  final nom = commune['nom'];
                  final codes =
                  (commune['codesPostaux'] as List).cast<String>();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: codes.map((cp) {
                      return ListTile(
                        title: Text("$nom $cp"),
                        onTap: () async {
                          setState(() {
                            selectedCommune = nom;
                            selectedCodePostal = cp;
                          });
                          await _saveProfile();
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
