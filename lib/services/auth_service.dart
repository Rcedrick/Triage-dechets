import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

/// 🔹 Récupérer les infos utilisateur depuis auth + table users
Future<Map<String, dynamic>?> getCurrentUserData() async {
  final user = supabase.auth.currentUser;

  if (user == null) return null;

  final response = await supabase
      .from('users')
      .select('code_postal, commune, name, avatar')
      .eq('id', user.id)
      .maybeSingle();

  return {
    "id": user.id,
    "email": user.email,
    "displayName": response?["name"] ?? user.userMetadata?["full_name"] ?? "Utilisateur",
    "avatarUrl": response?["avatar"] ?? user.userMetadata?["avatar_url"],
    "codePostal": response?["code_postal"],
    "commune": response?["commune"],
    "name": response?["name"],
    "avatar": response?["avatar"],
  };
}

/// 🔹 Vérifier et créer/mettre à jour l'utilisateur
Future<void> createOrUpdateUser(User user) async {
  final userData = {
    'id': user.id,
    'email': user.email ?? '',
    'name': user.userMetadata?['full_name'],
    'avatar': user.userMetadata?['avatar_url'],
  };

  await supabase.from('users').upsert(userData);
}

Future<User?> signInWithGoogle() async {
  final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  await googleSignIn.disconnect().catchError((_) {});
  await googleSignIn.signOut();

  final googleUser = await googleSignIn.signIn();
  if (googleUser == null) return null;

  final googleAuth = await googleUser.authentication;

  final response = await supabase.auth.signInWithIdToken(
    provider: OAuthProvider.google,
    idToken: googleAuth.idToken!,
    accessToken: googleAuth.accessToken,
  );

  if (response.user != null) {
    await createOrUpdateUser(response.user!);
  }

  return response.user;
}

/// 🔹 Login par email (OTP magic link)
Future<void> signInWithEmail(String email) async {
  await supabase.auth.signInWithOtp(
    email: email,
    emailRedirectTo: 'io.supabase.flutter://login-callback/',
  );
}

/// 🔹 Vérifier si l'utilisateur existe dans la table users
Future<bool> userExists(String userId) async {
  final existingUser = await supabase
      .from('users')
      .select()
      .eq('id', userId)
      .maybeSingle();

  return existingUser != null;
}

/// 🔹 Déconnexion
Future<void> signOut() async {
  await supabase.auth.signOut();
}
