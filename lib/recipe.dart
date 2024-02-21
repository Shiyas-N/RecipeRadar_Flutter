class Recipe {
  bool vegetarian;
  bool vegan;
  bool glutenFree;
  bool dairyFree;
  bool veryHealthy;
  bool cheap;
  bool veryPopular;
  bool sustainable;
  bool lowFodmap;
  int weightWatcherSmartPoints;
  String gaps;
  int preparationMinutes;
  int cookingMinutes;
  int aggregateLikes;
  int healthScore;
  String creditsText;
  String sourceName;
  double pricePerServing;
  List<ExtendedIngredient> extendedIngredients;
  int id;
  String title;
  int readyInMinutes;
  int servings;
  String sourceUrl;
  String image;
  String imageType;
  String summary;
  List<String> cuisines;
  List<String> dishTypes;
  List<String> diets;
  List<String> occasions;
  String instructions;
  List<AnalyzedInstruction> analyzedInstructions;
  dynamic originalId;
  double spoonacularScore;
  String spoonacularSourceUrl;

  Recipe({
    required this.vegetarian,
    required this.vegan,
    required this.glutenFree,
    required this.dairyFree,
    required this.veryHealthy,
    required this.cheap,
    required this.veryPopular,
    required this.sustainable,
    required this.lowFodmap,
    required this.weightWatcherSmartPoints,
    required this.gaps,
    required this.preparationMinutes,
    required this.cookingMinutes,
    required this.aggregateLikes,
    required this.healthScore,
    required this.creditsText,
    required this.sourceName,
    required this.pricePerServing,
    required this.extendedIngredients,
    required this.id,
    required this.title,
    required this.readyInMinutes,
    required this.servings,
    required this.sourceUrl,
    required this.image,
    required this.imageType,
    required this.summary,
    required this.cuisines,
    required this.dishTypes,
    required this.diets,
    required this.occasions,
    required this.instructions,
    required this.analyzedInstructions,
    required this.originalId,
    required this.spoonacularScore,
    required this.spoonacularSourceUrl,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      vegetarian: json['vegetarian'] ?? false,
      vegan: json['vegan'] ?? false,
      glutenFree: json['glutenFree'] ?? false,
      dairyFree: json['dairyFree'] ?? false,
      veryHealthy: json['veryHealthy'] ?? false,
      cheap: json['cheap'] ?? false,
      veryPopular: json['veryPopular'] ?? false,
      sustainable: json['sustainable'] ?? false,
      lowFodmap: json['lowFodmap'] ?? false,
      weightWatcherSmartPoints: json['weightWatcherSmartPoints'] ?? 0,
      gaps: json['gaps'] ?? '',
      preparationMinutes: json['preparationMinutes'] ?? -1,
      cookingMinutes: json['cookingMinutes'] ?? -1,
      aggregateLikes: json['aggregateLikes'] ?? 0,
      healthScore: json['healthScore'] ?? 0,
      creditsText: json['creditsText'] ?? '',
      sourceName: json['sourceName'] ?? '',
      pricePerServing: json['pricePerServing'] ?? 0.0,
      extendedIngredients: List<ExtendedIngredient>.from(
        json['extendedIngredients'].map((x) => ExtendedIngredient.fromJson(x)),
      ),
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      readyInMinutes: json['readyInMinutes'] ?? 0,
      servings: json['servings'] ?? 0,
      sourceUrl: json['sourceUrl'] ?? '',
      image: json['image'] ?? '',
      imageType: json['imageType'] ?? '',
      summary: json['summary'] ?? '',
      cuisines: List<String>.from(json['cuisines'].map((x) => x)),
      dishTypes: List<String>.from(json['dishTypes'].map((x) => x)),
      diets: List<String>.from(json['diets'].map((x) => x)),
      occasions: List<String>.from(json['occasions'].map((x) => x)),
      instructions: json['instructions'] ?? '',
      analyzedInstructions: List<AnalyzedInstruction>.from(
        json['analyzedInstructions']
            .map((x) => AnalyzedInstruction.fromJson(x)),
      ),
      originalId: json['originalId'] ?? '',
      spoonacularScore: json['spoonacularScore'] ?? 0.0,
      spoonacularSourceUrl: json['spoonacularSourceUrl'] ?? '',
    );
  }
}

class ExtendedIngredient {
  int id;
  String aisle;
  String image;
  String consistency;
  String name;
  String nameClean;
  String original;
  String originalName;
  double amount;
  String unit;
  List<dynamic> meta;
  Measures measures;

  ExtendedIngredient({
    required this.id,
    required this.aisle,
    required this.image,
    required this.consistency,
    required this.name,
    required this.nameClean,
    required this.original,
    required this.originalName,
    required this.amount,
    required this.unit,
    required this.meta,
    required this.measures,
  });

  factory ExtendedIngredient.fromJson(Map<String, dynamic> json) {
    return ExtendedIngredient(
      id: json['id'] ?? 0,
      aisle: json['aisle'] ?? '',
      image: json['image'] ?? '',
      consistency: json['consistency'] ?? '',
      name: json['name'] ?? '',
      nameClean: json['nameClean'] ?? '',
      original: json['original'] ?? '',
      originalName: json['originalName'] ?? '',
      amount: json['amount'] ?? 0.0,
      unit: json['unit'] ?? '',
      meta: List<dynamic>.from(json['meta'].map((x) => x)),
      measures: Measures.fromJson(json['measures']),
    );
  }
}

class Measures {
  Us us;
  Metric metric;

  Measures({
    required this.us,
    required this.metric,
  });

  factory Measures.fromJson(Map<String, dynamic> json) {
    return Measures(
      us: Us.fromJson(json['us']),
      metric: Metric.fromJson(json['metric']),
    );
  }
}

class Us {
  double amount;
  String unitShort;
  String unitLong;

  Us({
    required this.amount,
    required this.unitShort,
    required this.unitLong,
  });

  factory Us.fromJson(Map<String, dynamic> json) {
    return Us(
      amount: json['amount'] ?? 0.0,
      unitShort: json['unitShort'] ?? '',
      unitLong: json['unitLong'] ?? '',
    );
  }
}

class Metric {
  double amount;
  String unitShort;
  String unitLong;

  Metric({
    required this.amount,
    required this.unitShort,
    required this.unitLong,
  });

  factory Metric.fromJson(Map<String, dynamic> json) {
    return Metric(
      amount: json['amount'] ?? 0.0,
      unitShort: json['unitShort'] ?? '',
      unitLong: json['unitLong'] ?? '',
    );
  }
}

class AnalyzedInstruction {
  String name;
  List<Step> steps;

  AnalyzedInstruction({
    required this.name,
    required this.steps,
  });

  factory AnalyzedInstruction.fromJson(Map<String, dynamic> json) {
    return AnalyzedInstruction(
      name: json['name'] ?? '',
      steps: List<Step>.from(json['steps'].map((x) => Step.fromJson(x))),
    );
  }
}

class Step {
  int number;
  String step;
  List<Ingredient> ingredients;
  List<Equipment> equipment;

  Step({
    required this.number,
    required this.step,
    required this.ingredients,
    required this.equipment,
  });

  factory Step.fromJson(Map<String, dynamic> json) {
    return Step(
      number: json['number'] ?? 0,
      step: json['step'] ?? '',
      ingredients: List<Ingredient>.from(
        json['ingredients'].map((x) => Ingredient.fromJson(x)),
      ),
      equipment: List<Equipment>.from(
        json['equipment'].map((x) => Equipment.fromJson(x)),
      ),
    );
  }
}

class Ingredient {
  int id;
  String name;
  String localizedName;
  String image;

  Ingredient({
    required this.id,
    required this.name,
    required this.localizedName,
    required this.image,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      localizedName: json['localizedName'] ?? '',
      image: json['image'] ?? '',
    );
  }
}

class Equipment {
  int id;
  String name;
  String localizedName;
  String image;

  Equipment({
    required this.id,
    required this.name,
    required this.localizedName,
    required this.image,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      localizedName: json['localizedName'] ?? '',
      image: json['image'] ?? '',
    );
  }
}
