// lib/services/spoonacular_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';
import '../models/recipe_detail.dart';

class SpoonacularService {
  static const String _baseUrl = 'https://api.spoonacular.com';
  final String _apiKey =
      '9959e7fc5e464f4ea3e43c2dfd4279a0'; // ERSETZE DIES DURCH DEINEN TATSÄCHLICHEN API-SCHLÜSSEL

  Future<List<Recipe>> searchRecipes(
    String query, {
    String? diet,
    String? intolerances,
    String? sort, // NEU: Optionaler Sortier-Parameter
    String? sortDirection, // NEU: Optionaler Sortierrichtung-Parameter
  }) async {
    String uriString =
        '$_baseUrl/recipes/complexSearch?query=$query&apiKey=$_apiKey&number=10';

    if (diet != null && diet.isNotEmpty) {
      uriString += '&diet=$diet';
    }
    if (intolerances != null && intolerances.isNotEmpty) {
      uriString += '&intolerances=$intolerances';
    }
    // NEU: Sortier-Parameter hinzufügen, falls vorhanden
    if (sort != null && sort.isNotEmpty) {
      uriString += '&sort=$sort';
      if (sortDirection != null && sortDirection.isNotEmpty) {
        uriString += '&sortDirection=$sortDirection';
      }
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

  Future<List<Recipe>> findRecipesByIngredients(
    List<String> ingredients, {
    String? diet,
    String? intolerances,
    String? sort, // NEU: Optionaler Sortier-Parameter
    String? sortDirection, // NEU: Optionaler Sortierrichtung-Parameter
  }) async {
    if (ingredients.isEmpty) {
      return [];
    }
    final ingredientsString = ingredients.join(',');

    String uriString =
        '$_baseUrl/recipes/findByIngredients?ingredients=$ingredientsString&apiKey=$_apiKey&number=20&ranking=1&ignorePantry=true';

    if (diet != null && diet.isNotEmpty) {
      uriString += '&diet=$diet';
    }
    if (intolerances != null && intolerances.isNotEmpty) {
      uriString += '&intolerances=$intolerances';
    }
    // NEU: Sortier-Parameter hinzufügen, falls vorhanden
    if (sort != null && sort.isNotEmpty) {
      uriString += '&sort=$sort';
      if (sortDirection != null && sortDirection.isNotEmpty) {
        uriString += '&sortDirection=$sortDirection';
      }
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
