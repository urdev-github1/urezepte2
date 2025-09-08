// lib\screens\main_screen.dart

import 'package:flutter/material.dart';
import '../services/spoonacular_service.dart';
import '../models/recipe.dart';
import 'about_screen.dart'; // Import des neuen AboutScreen

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

    try {
      final recipes = await _spoonacularService.searchRecipes(query);
      setState(() {
        _recipes = recipes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
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
          // Info-Button, der zum AboutScreen navigiert.
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
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(child: Text(_errorMessage!))
                : Expanded(
                    child:
                        _recipes.isEmpty &&
                            _searchController
                                .text
                                .isNotEmpty // Nur anzeigen, wenn keine Ergebnisse und bereits gesucht wurde
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
                                    // TODO: Hier später zum Detail-Screen navigieren
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Rezept "${recipe.title}" ausgewählt (ID: ${recipe.id})',
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
