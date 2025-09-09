// lib/models/recipe_detail.dart

class Ingredient {
  final int id;
  final String name;
  final String? image;
  final double amount;
  final String unit;

  Ingredient({
    required this.id,
    required this.name,
    this.image,
    required this.amount,
    required this.unit,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'] as int,
      name: json['name'] as String,
      image: json['image'] as String?,
      amount: (json['amount'] as num).toDouble(),
      unit: json['unit'] as String,
    );
  }
}

class InstructionStep {
  final int number;
  final String step;

  InstructionStep({required this.number, required this.step});

  factory InstructionStep.fromJson(Map<String, dynamic> json) {
    return InstructionStep(
      number: json['number'] as int,
      step: json['step'] as String,
    );
  }
}

class AnalyzedInstruction {
  final String name;
  final List<InstructionStep> steps;

  AnalyzedInstruction({required this.name, required this.steps});

  factory AnalyzedInstruction.fromJson(Map<String, dynamic> json) {
    return AnalyzedInstruction(
      name: json['name'] as String? ?? '', // Kann leer sein
      steps: (json['steps'] as List<dynamic>)
          .map((stepJson) => InstructionStep.fromJson(stepJson))
          .toList(),
    );
  }
}

class RecipeDetail {
  final int id;
  final String title;
  final String? image;
  final int? servings;
  final int? readyInMinutes;
  final String? sourceUrl;
  final String? summary;
  final List<Ingredient> extendedIngredients;
  final List<AnalyzedInstruction> analyzedInstructions;

  RecipeDetail({
    required this.id,
    required this.title,
    this.image,
    this.servings,
    this.readyInMinutes,
    this.sourceUrl,
    this.summary,
    required this.extendedIngredients,
    required this.analyzedInstructions,
  });

  factory RecipeDetail.fromJson(Map<String, dynamic> json) {
    var ingredientsList = json['extendedIngredients'] as List<dynamic>?;
    List<Ingredient> ingredients = ingredientsList != null
        ? ingredientsList.map((i) => Ingredient.fromJson(i)).toList()
        : [];

    var instructionsList = json['analyzedInstructions'] as List<dynamic>?;
    List<AnalyzedInstruction> instructions = instructionsList != null
        ? instructionsList.map((i) => AnalyzedInstruction.fromJson(i)).toList()
        : [];

    return RecipeDetail(
      id: json['id'] as int,
      title: json['title'] as String,
      image: json['image'] as String?,
      servings: json['servings'] as int?,
      readyInMinutes: json['readyInMinutes'] as int?,
      sourceUrl: json['sourceUrl'] as String?,
      summary: json['summary'] as String?,
      extendedIngredients: ingredients,
      analyzedInstructions: instructions,
    );
  }
}
