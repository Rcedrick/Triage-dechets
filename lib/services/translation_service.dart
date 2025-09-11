import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslationService {
  static const String _baseUrl = "https://libretranslate.com/translate";

  static Future<String> translateToFrench(String text) async {
    if (text.trim().isEmpty) return text;

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "q": text,
        "source": "en",
        "target": "fr",
        "format": "text"
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["translatedText"] ?? text;
    } else {
      print("❌ Erreur traduction: ${response.body}");
      return text; // fallback si erreur
    }
  }
}
