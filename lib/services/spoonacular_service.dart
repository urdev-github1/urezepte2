// lib/services/spoonacular_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

class SpoonacularService {
  static const String _baseUrl = 'https://api.spoonacular.com';
  // ERSETZE 'YOUR_API_KEY' DURCH DEINEN TATSÄCHLICHEN API-SCHLÜSSEL
  final String _apiKey = 'YOUR_API_KEY';

  Future<List<Recipe>> searchRecipes(String query) async {
    final uri = Uri.parse(
      '$_baseUrl/recipes/complexSearch?query=$query&apiKey=$_apiKey&number=10',
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> results = data['results'];
        return results.map((json) => Recipe.fromJson(json)).toList();
      } else {
        throw Exception(
          'Fehler beim Laden der Rezepte: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Netzwerkfehler: $e');
    }
  }

  // Hier könnten weitere Methoden für spezifische Rezeptdetails,
  // Zutaten etc. hinzugefügt werden.
}
