// lib/services/spoonacular_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';
import '../models/recipe_detail.dart'; // Importiere das neue Detail-Modell

class SpoonacularService {
  static const String _baseUrl = 'https://api.spoonacular.com';
  final String _apiKey =
      '9959e7fc5e464f4ea3e43c2dfd4279a0'; // ERSETZE DIES DURCH DEINEN TATSÄCHLICHEN API-SCHLÜSSEL

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

  // NEUE METHODE: Rezeptdetails abrufen
  Future<RecipeDetail> getRecipeDetails(int id) async {
    final uri = Uri.parse(
      '$_baseUrl/recipes/$id/information?apiKey=$_apiKey&includeNutrition=false', // includeNutrition ist optional
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
}
