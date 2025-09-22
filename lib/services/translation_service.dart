import 'package:translator/translator.dart';

class TranslationService {
  static final GoogleTranslator _translator = GoogleTranslator();

  /// Traduit un texte de l'anglais vers le français avec gestion des erreurs
  static Future<String> translateEnglishToFrench(String text) async {
    if (text.isEmpty) {
      return '';
    }

    // Si le texte est déjà en français ou ne contient que des caractères spéciaux
    if (_isLikelyFrench(text) || text.trim().isEmpty) {
      return text;
    }

    try {
      final Translation translation = await _translator.translate(
        text,
        from: 'en',
        to: 'fr',
      );
      return translation.text;
    } catch (e) {
      // En cas d'erreur, retourner le texte original
      print('❌ Erreur traduction "$text": $e');
      return text;
    }
  }

  /// Vérifie si le texte est probablement déjà en français
  static bool _isLikelyFrench(String text) {
    final frenchWords = ['le', 'la', 'les', 'un', 'une', 'des', 'et', 'est'];
    final lowerText = text.toLowerCase();
    return frenchWords.any((word) => lowerText.contains(word));
  }

  /// Traduit un texte en ignorant les erreurs (pour les boucles)
  static Future<String> translateSafe(String text) async {
    try {
      return await translateEnglishToFrench(text);
    } catch (e) {
      return text;
    }
  }
}