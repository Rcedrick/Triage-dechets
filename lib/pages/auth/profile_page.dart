import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tri_dechets/main.dart';
import '../home_page.dart';
import '../../models/user_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  final _codePostalController = TextEditingController();
  List<Map<String, dynamic>> communes = [];
  String? selectedCommune;
  String? selectedCodePostal;

  bool loadingCommunes = false;

  Future<void> fetchCommunes(String codePostal) async {
    setState(() => loadingCommunes = true);

    try {
      final response = await http.get(
        Uri.parse(
            'https://geo.api.gouv.fr/communes?codePostal=$codePostal&fields=nom,codesPostaux&format=json'),
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          communes = data.map((e) => e as Map<String, dynamic>).toList();
          selectedCommune = null; // reset sélection
        });
      } else {
        setState(() {
          communes = [];
        });
        throw Exception('Erreur lors du chargement des communes');
      }
    } catch (e) {
      setState(() {
        communes = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      setState(() => loadingCommunes = false);
    }
  }

  Future<void> _saveProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    if (_formKey.currentState!.validate()) {
      final newUser = UserModel(
        id: user.id,
        email: user.email ?? '',
        codePostal: selectedCodePostal ?? _codePostalController.text,
        commune: selectedCommune,
      );

      await supabase.from('users').insert(newUser.toMap());

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainNavigation()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Compléter vos infos")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Code postal
              TextFormField(
                controller: _codePostalController,
                decoration: const InputDecoration(labelText: "Code postal"),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value == null || value.isEmpty ? "Entrez un code postal" : null,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  if (_codePostalController.text.isNotEmpty) {
                    fetchCommunes(_codePostalController.text);
                  }
                },
                child: const Text("Rechercher communes"),
              ),
              const SizedBox(height: 16),

              // Dropdown des communes
              loadingCommunes
                  ? const CircularProgressIndicator()
                  : communes.isEmpty
                  ? const SizedBox()
                  : DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Commune"),
                value: selectedCommune,
                items: communes
                    .where((c) => c.containsKey('nom'))
                    .map<DropdownMenuItem<String>>(
                      (c) => DropdownMenuItem<String>(
                    value: c['nom'] as String,
                    child: Text(c['nom'] as String),
                  ),
                )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCommune = value;
                    if (value != null && communes.isNotEmpty) {
                      final communeData = communes.firstWhere(
                              (c) => c['nom'] == value,
                          orElse: () => {});
                      if (communeData.isNotEmpty &&
                          communeData.containsKey('codesPostaux')) {
                        selectedCodePostal =
                            (communeData['codesPostaux'] as List).first;
                      }
                    }
                  });
                },
                validator: (value) =>
                value == null ? "Sélectionnez une commune" : null,
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _saveProfile,
                child: const Text("Enregistrer"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
