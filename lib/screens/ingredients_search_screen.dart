// lib/screens/ingredients_search_screen.dart

import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/spoonacular_service.dart';
import 'recipe_detail_screen.dart'; // Für die Navigation zur Detailseite

class IngredientsSearchScreen extends StatefulWidget {
  const IngredientsSearchScreen({super.key});

  @override
  State<IngredientsSearchScreen> createState() =>
      _IngredientsSearchScreenState();
}

class _IngredientsSearchScreenState extends State<IngredientsSearchScreen> {
  final TextEditingController _ingredientController = TextEditingController();
  final SpoonacularService _spoonacularService = SpoonacularService();
  List<String> _ingredients = [];
  List<Recipe> _recipes = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _ingredientController.dispose();
    super.dispose();
  }

  void _addIngredient(String ingredient) {
    if (ingredient.trim().isNotEmpty &&
        !_ingredients.contains(ingredient.trim().toLowerCase())) {
      setState(() {
        _ingredients.add(ingredient.trim().toLowerCase());
        _ingredientController.clear();
      });
    }
  }

  void _removeIngredient(String ingredient) {
    setState(() {
      _ingredients.remove(ingredient);
    });
  }

  Future<void> _searchRecipesByIngredients() async {
    if (_ingredients.isEmpty) {
      setState(() {
        _recipes = [];
        _errorMessage = 'Bitte füge zuerst Zutaten hinzu.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _recipes = []; // Clear previous results
    });

    try {
      final recipes = await _spoonacularService.findRecipesByIngredients(
        _ingredients,
      );
      setState(() {
        _recipes = recipes;
        _isLoading = false;
        if (_recipes.isEmpty) {
          _errorMessage = 'Keine Rezepte mit diesen Zutaten gefunden.';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().contains("Exception: Netzwerkfehler")
            ? "Keine Internetverbindung oder API-Fehler."
            : e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rezepte nach Zutaten'),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _ingredientController,
              decoration: InputDecoration(
                labelText: 'Zutat hinzufügen (z.B. Huhn, Tomaten)',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addIngredient(_ingredientController.text),
                ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: _addIngredient,
            ),
            const SizedBox(height: 16.0),
            // Anzeigen der hinzugefügten Zutaten als Chips
            if (_ingredients.isNotEmpty)
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: _ingredients
                    .map(
                      (ingredient) => Chip(
                        label: Text(ingredient),
                        onDeleted: () => _removeIngredient(ingredient),
                      ),
                    )
                    .toList(),
              ),
            const SizedBox(height: 16.0),
            ElevatedButton.icon(
              icon: const Icon(Icons.kitchen),
              label: const Text('Rezepte finden'),
              onPressed: _isLoading ? null : _searchRecipesByIngredients,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
              ),
            ),
            const SizedBox(height: 16.0),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(child: Text(_errorMessage!))
                : Expanded(
                    child:
                        _recipes.isEmpty &&
                            _ingredients
                                .isNotEmpty // Nur anzeigen, wenn keine Ergebnisse und bereits gesucht wurde
                        ? const Center(
                            child: Text(
                              'Füge Zutaten hinzu und suche nach Rezepten.',
                            ),
                          )
                        : ListView.builder(
                            itemCount: _recipes.length,
                            itemBuilder: (context, index) {
                              final recipe = _recipes[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: ListTile(
                                  leading: recipe.image != null
                                      ? Image.network(
                                          recipe.image!,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(
                                                    Icons.broken_image,
                                                  ),
                                        )
                                      : const Icon(Icons.food_bank),
                                  title: Text(recipe.title),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            RecipeDetailScreen(
                                              recipeId: recipe.id,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                  ),
          ],
        ),
      ),
    );
  }
}
