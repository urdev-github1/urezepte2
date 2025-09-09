// lib/screens/ingredients_search_screen.dart

import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/spoonacular_service.dart';
import '../screens/recipe_detail_screen.dart';
// Importiere das SortOption Enum, wenn es in einer separaten Datei liegt,
// ansonsten direkt aus main_screen.dart importieren, wenn es dort definiert ist.
// Für diese Demonstration nehmen wir an, dass es im selben Projekt zugänglich ist
// oder definieren es hier erneut, falls dies bevorzugt wird.
// Um Redundanz zu vermeiden, ist es besser, es globaler zu definieren, z.B. in models/sort_options.dart
// Für diese Lösung kopieren wir es der Einfachheit halber.

// NEU: Enum für Sortieroptionen (wenn nicht global definiert)
enum SortOption { none, preparationTime, popularity }

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

  // Zustandsvariablen für die Filter
  bool _isGlutenFreeFilterActive = false;
  bool _isNutFreeFilterActive = false;

  // NEU: Zustandsvariable für die Sortierung
  SortOption _selectedSortOption = SortOption.none;

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

    String? sortParam;
    String? sortDirectionParam;

    // NEU: Sortierparameter basierend auf der Auswahl setzen
    switch (_selectedSortOption) {
      case SortOption.preparationTime:
        sortParam = 'time';
        sortDirectionParam = 'asc'; // Kürzeste Zeit zuerst
        break;
      case SortOption.popularity:
        sortParam = 'popularity';
        sortDirectionParam = 'desc'; // Beliebteste zuerst
        break;
      case SortOption.none:
        // Keine Sortierung
        break;
    }

    try {
      final recipes = await _spoonacularService.findRecipesByIngredients(
        _ingredients,
        diet: _isGlutenFreeFilterActive ? 'gluten_free' : null,
        intolerances: _isNutFreeFilterActive ? 'peanut,tree_nut' : null,
        sort: sortParam, // NEU: Sortierparameter übergeben
        sortDirection: sortDirectionParam, // NEU: Sortierrichtung übergeben
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
      body: SingleChildScrollView(
        // HIER hinzugefügt
        child: Padding(
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
              const SizedBox(height: 8.0),
              Align(
                alignment: Alignment.centerLeft,
                child: DropdownButton<SortOption>(
                  value: _selectedSortOption,
                  onChanged: (SortOption? newValue) {
                    setState(() {
                      _selectedSortOption = newValue ?? SortOption.none;
                      if (_ingredients.isNotEmpty) {
                        _searchRecipesByIngredients();
                      }
                    });
                  },
                  items: const [
                    DropdownMenuItem(
                      value: SortOption.none,
                      child: Text('Standardsortierung'),
                    ),
                    DropdownMenuItem(
                      value: SortOption.preparationTime,
                      child: Text('Zubereitungszeit'),
                    ),
                    DropdownMenuItem(
                      value: SortOption.popularity,
                      child: Text('Beliebtheit'),
                    ),
                  ],
                ),
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
              // WICHTIG: Wenn Sie ein SingleChildScrollView um die gesamte Column legen,
              // sollte das Expanded-Widget für den ListView.builder entfernt werden,
              // da es im scrollbaren Kontext keinen unendlichen Platz füllen kann
              // und Konflikte verursachen würde. Stattdessen shrinkWrap: true verwenden.
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? Center(child: Text(_errorMessage!))
                  : _recipes.isEmpty && _ingredients.isNotEmpty
                  ? const Center(
                      child: Text(
                        'Füge Zutaten hinzu und suche nach Rezepten.',
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true, // HIER HINZUGEFÜGT
                      physics:
                          const NeverScrollableScrollPhysics(), // HIER HINZUGEFÜGT
                      itemCount: _recipes.length,
                      itemBuilder: (context, index) {
                        final recipe = _recipes[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            leading: recipe.image != null
                                ? Image.network(
                                    recipe.image!,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.broken_image),
                                  )
                                : const Icon(Icons.food_bank),
                            title: Text(recipe.title),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      RecipeDetailScreen(recipeId: recipe.id),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
