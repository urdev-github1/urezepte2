// lib/models/recipe.dart

class Recipe {
  final int id;
  final String title;
  final String? image;

  Recipe({required this.id, required this.title, this.image});

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as int,
      title: json['title'] as String,
      image: json['image'] as String?,
    );
  }
}
