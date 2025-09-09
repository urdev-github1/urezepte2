// lib/screens/recipe_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart'; // Für die HTML-Anzeige der Zusammenfassung
import 'package:url_launcher/url_launcher.dart';
import '../models/recipe_detail.dart';
import '../services/spoonacular_service.dart';

class RecipeDetailScreen extends StatefulWidget {
  final int recipeId;

  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late Future<RecipeDetail> _recipeDetailFuture;

  @override
  void initState() {
    super.initState();
    _recipeDetailFuture = SpoonacularService().getRecipeDetails(
      widget.recipeId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rezeptdetails'),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<RecipeDetail>(
        future: _recipeDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Fehler: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Keine Rezeptdetails gefunden.'));
          } else {
            final recipe = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  if (recipe.image != null)
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          recipe.image!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, size: 100),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16.0),
                  Wrap(
                    spacing: 8.0,
                    children: [
                      if (recipe.readyInMinutes != null)
                        Chip(
                          avatar: const Icon(Icons.timer),
                          label: Text('${recipe.readyInMinutes} Min.'),
                        ),
                      if (recipe.servings != null)
                        Chip(
                          avatar: const Icon(Icons.people),
                          label: Text('${recipe.servings} Portionen'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  if (recipe.summary != null && recipe.summary!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Zusammenfassung',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Html(data: recipe.summary!), // Anzeigen von HTML-Text
                        const SizedBox(height: 16.0),
                      ],
                    ),
                  if (recipe.extendedIngredients.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Zutaten',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8.0),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: recipe.extendedIngredients.length,
                          itemBuilder: (context, index) {
                            final ingredient =
                                recipe.extendedIngredients[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              child: Text(
                                '- ${ingredient.amount} ${ingredient.unit} ${ingredient.name}',
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16.0),
                      ],
                    ),
                  if (recipe.analyzedInstructions.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Zubereitung',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8.0),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount:
                              recipe.analyzedInstructions.first.steps.length,
                          itemBuilder: (context, index) {
                            final step =
                                recipe.analyzedInstructions.first.steps[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              child: Text('${step.number}. ${step.step}'),
                            );
                          },
                        ),
                        const SizedBox(height: 16.0),
                      ],
                    ),
                  if (recipe.sourceUrl != null && recipe.sourceUrl!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quelle',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        InkWell(
                          onTap: () {
                            // Öffnen der URL im Browser
                            launchUrl(Uri.parse(recipe.sourceUrl!));
                          },
                          child: Text(
                            recipe.sourceUrl!,
                            style: const TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
