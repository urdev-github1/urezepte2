// lib/screens/main_screen.dart

import 'package:flutter/material.dart';
import 'package:urezepte2/screens/ingredients_search_screen.dart';
import '../services/spoonacular_service.dart';
import '../models/recipe.dart';
import '../screens/about_screen.dart';
import '../screens/recipe_detail_screen.dart';

// NEU: Enum für Sortieroptionen
enum SortOption { none, preparationTime, popularity }

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _searchController = TextEditingController();
  final SpoonacularService _spoonacularService = SpoonacularService();
  List<Recipe> _recipes = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Zustandsvariablen für die Filter
  bool _isGlutenFreeFilterActive = false;
  bool _isNutFreeFilterActive = false;

  // NEU: Zustandsvariable für die Sortierung
  SortOption _selectedSortOption = SortOption.none;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchRecipes(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _recipes = [];
        _errorMessage = 'Bitte gib einen Suchbegriff ein.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
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
      final recipes = await _spoonacularService.searchRecipes(
        query,
        diet: _isGlutenFreeFilterActive ? 'gluten_free' : null,
        intolerances: _isNutFreeFilterActive ? 'peanut,tree_nut' : null,
        sort: sortParam, // NEU: Sortierparameter übergeben
        sortDirection: sortDirectionParam, // NEU: Sortierrichtung übergeben
      );
      setState(() {
        _recipes = recipes;
        _isLoading = false;
        if (_recipes.isEmpty) {
          _errorMessage = 'Keine Rezepte für "$query" gefunden.';
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

  /// Baut die Benutzeroberfläche des MainScreen auf.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rezeptsuche'),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
            tooltip: 'Über die App',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Rezepte suchen (z.B. Pasta, Chicken)',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _searchRecipes(_searchController.text),
                ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: _searchRecipes,
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
            // NEU: Dropdown für Sortierung
            Align(
              alignment: Alignment.centerLeft,
              child: DropdownButton<SortOption>(
                value: _selectedSortOption,
                onChanged: (SortOption? newValue) {
                  setState(() {
                    _selectedSortOption = newValue ?? SortOption.none;
                    // Optional: Suche erneut auslösen, wenn Sortierung geändert wird
                    if (_searchController.text.isNotEmpty) {
                      _searchRecipes(_searchController.text);
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
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(child: Text(_errorMessage!))
                : Expanded(
                    child: _recipes.isEmpty && _searchController.text.isNotEmpty
                        ? const Center(child: Text('Keine Rezepte gefunden.'))
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const IngredientsSearchScreen(),
            ),
          );
        },
        label: const Text('Rezepte nach Zutaten'),
        icon: const Icon(Icons.kitchen),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
