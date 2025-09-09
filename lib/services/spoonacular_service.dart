// lib/services/spoonacular_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';
import '../models/recipe_detail.dart';

class SpoonacularService {
  static const String _baseUrl = 'https://api.spoonacular.com';
  final String _apiKey = '9959e7fc5e464f4ea3e43c2dfd4279a0';
  Future<List<Recipe>> searchRecipes(
    String query, {
    String? diet, // Optionaler Diät-Parameter
    String? intolerances, // Optionaler Unverträglichkeits-Parameter
  }) async {
    // Grund-URI für die Suche
    String uriString =
        '$_baseUrl/recipes/complexSearch?query=$query&apiKey=$_apiKey&number=10';

    // Diät-Parameter hinzufügen, falls vorhanden
    if (diet != null && diet.isNotEmpty) {
      uriString += '&diet=$diet';
    }
    // Unverträglichkeits-Parameter hinzufügen, falls vorhanden
    if (intolerances != null && intolerances.isNotEmpty) {
      uriString += '&intolerances=$intolerances';
    }

    final uri = Uri.parse(uriString);

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

  // Rezeptdetails abrufen (hier keine Filter nötig, da Details schon spezifisch sind)
  Future<RecipeDetail> getRecipeDetails(int id) async {
    final uri = Uri.parse(
      '$_baseUrl/recipes/$id/information?apiKey=$_apiKey&includeNutrition=false',
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return RecipeDetail.fromJson(data);
      } else {
        throw Exception(
          'Fehler beim Laden der Rezeptdetails: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Netzwerkfehler beim Abrufen der Details: $e');
    }
  }

  // Rezepte nach Zutaten finden
  Future<List<Recipe>> findRecipesByIngredients(
    List<String> ingredients, {
    String? diet, // Optionaler Diät-Parameter
    String? intolerances, // Optionaler Unverträglichkeits-Parameter
  }) async {
    if (ingredients.isEmpty) {
      return [];
    }
    final ingredientsString = ingredients.join(',');

    // Grund-URI für die Zutatensuche
    String uriString =
        '$_baseUrl/recipes/findByIngredients?ingredients=$ingredientsString&apiKey=$_apiKey&number=20&ranking=1&ignorePantry=true';

    // Diät-Parameter hinzufügen, falls vorhanden
    if (diet != null && diet.isNotEmpty) {
      uriString += '&diet=$diet';
    }
    // Unverträglichkeits-Parameter hinzufügen, falls vorhanden
    if (intolerances != null && intolerances.isNotEmpty) {
      uriString += '&intolerances=$intolerances';
    }

    final uri = Uri.parse(uriString);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Recipe.fromJson(json)).toList();
      } else {
        throw Exception(
          'Fehler beim Laden der Rezepte nach Zutaten: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Netzwerkfehler beim Abrufen der Zutatenrezepte: $e');
    }
  }
}
