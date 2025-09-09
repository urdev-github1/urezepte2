// lib/screens/ingredients_search_screen.dart

import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/spoonacular_service.dart';
import '../screens/recipe_detail_screen.dart';

class IngredientsSearchScreen extends StatefulWidget {
  const IngredientsSearchScreen({super.key});

  @override
  State<IngredientsSearchScreen> createState() =>
      _IngredientsSearchScreenState();
}

class _IngredientsSearchScreenState extends State<IngredientsSearchScreen> {
  final TextEditingController _ingredientController = TextEditingController();
  final SpoonacularService _spoonacularService = SpoonacularService();
  final List<String> _ingredients = [];
  List<Recipe> _recipes = [];
  bool _isLoading = false;
  String? _errorMessage;

  // NEU: Zustandsvariablen für die Filter
  bool _isGlutenFreeFilterActive = false;
  bool _isNutFreeFilterActive = false;

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
      _recipes = [];
    });

    try {
      // Parameter für Diät und Unverträglichkeiten übergeben
      final recipes = await _spoonacularService.findRecipesByIngredients(
        _ingredients,
        diet: _isGlutenFreeFilterActive ? 'gluten_free' : null,
        intolerances: _isNutFreeFilterActive ? 'peanut,tree_nut' : null,
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
            // Filter-Checkboxen für IngredientsSearchScreen
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    title: const Text('glutenfrei'),
                    value: _isGlutenFreeFilterActive,
                    onChanged: (bool? newValue) {
                      setState(() {
                        _isGlutenFreeFilterActive = newValue ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    title: const Text('ohne Nüsse'),
                    value: _isNutFreeFilterActive,
                    onChanged: (bool? newValue) {
                      setState(() {
                        _isNutFreeFilterActive = newValue ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0), // Abstand nach den Checkboxen
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
                    child: _recipes.isEmpty && _ingredients.isNotEmpty
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
