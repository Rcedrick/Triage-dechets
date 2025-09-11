import 'package:supabase_flutter/supabase_flutter.dart';

Future<Map<String, dynamic>?> getUserData() async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  if (user == null) {
    print("Aucun utilisateur connecté");
    return null;
  }

  // Requête pour récupérer les infos du user
  final response = await supabase
      .from('users')
      .select('code_postal, commune')
      .eq('id', user.id) // si la PK de ta table users correspond à l'id Auth
      .maybeSingle();

  if (response == null) {
    print("Utilisateur non trouvé dans la table users");
    return null;
  }

  print("Code Postal: ${response['code_postal']}, Commune: ${response['commune']}");
  return response;
}
