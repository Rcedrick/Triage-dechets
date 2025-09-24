import 'package:translator/translator.dart';

class TranslationService {
  static final GoogleTranslator _translator = GoogleTranslator();

  // Ajouter un timeout
  static const Duration _timeoutDuration = Duration(seconds: 10);

  /// Traduit un texte de l'anglais vers le français avec gestion des erreurs
  static Future<String> translateEnglishToFrench(String text) async {
    if (text.isEmpty || text.trim().isEmpty) {
      return text;
    }

    // Vérification française améliorée
    if (_isLikelyFrench(text)) {
      print('✅ Texte déjà en français: "$text"');
      return text;
    }

    try {
      print('🔄 Traduction de: "$text"');

      final Translation translation = await _translator.translate(
        text,
        from: 'en',
        to: 'fr',
      ).timeout(_timeoutDuration);

      print('✅ Traduction réussie: "$text" → "${translation.text}"');
      return translation.text;
    } catch (e) {
      print('❌ Erreur traduction "$text": $e');
      return text;
    }
  }

  /// Vérification française améliorée
  static bool _isLikelyFrench(String text) {
    if (text.isEmpty) return true;

    final frenchWords = [
      'le', 'la', 'les', 'un', 'une', 'des', 'et', 'est', 'dans', 'pour',
      'sur', 'avec', 'aux', 'du', 'de', 'à', 'au', 'en', 'son', 'sa', 'ses'
    ];

    final frenchPattern = RegExp(r'[àâäéèêëîïôöùûüç]', caseSensitive: false);

    final lowerText = text.toLowerCase();

    // Vérifier les caractères français
    bool hasFrenchChars = frenchPattern.hasMatch(text);

    // Vérifier les mots français communs
    int frenchWordCount = frenchWords.where((word) => lowerText.contains(word)).length;

    // Si le texte contient des caractères français OU plusieurs mots français
    return hasFrenchChars || frenchWordCount >= 2;
  }

  /// Traduit un texte en ignorant les erreurs (pour les boucles)
  static Future<String> translateSafe(String text) async {
    try {
      return await translateEnglishToFrench(text);
    } catch (e) {
      print('⚠️ Traduction safe échouée pour "$text": $e');
      return text;
    }
  }
}