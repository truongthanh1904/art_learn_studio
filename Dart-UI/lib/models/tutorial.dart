/// Model bài hướng dẫn nghệ thuật.
class Tutorial {
  final String id;
  final String title;
  final String category;
  final String description;
  final String? difficultyLevel;
  final String authorName;
  final int stepCount;
  final List<TutorialStep> steps;
  final List<TutorialMaterial> materials;

  int reviewCount;
  double averageRating;
  bool isSaved;

  Tutorial({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    this.difficultyLevel,
    required this.authorName,
    required this.stepCount,
    required this.steps,
    required this.materials,
    this.reviewCount = 0,
    this.averageRating = 0,
    this.isSaved = false,
  });

  /// Chuyển JSON từ backend thành Tutorial.
  factory Tutorial.fromJson(Map<String, dynamic> json) {
    final steps = (json['steps'] is List)
        ? (json['steps'] as List)
            .map((item) => TutorialStep.fromJson(Map<String, dynamic>.from(item)))
            .toList()
        : <TutorialStep>[];

    final materials = (json['materials'] is List)
        ? (json['materials'] as List)
            .map((item) => TutorialMaterial.fromJson(Map<String, dynamic>.from(item)))
            .toList()
        : <TutorialMaterial>[];

    return Tutorial(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      difficultyLevel: json['difficultyLevel']?.toString(),
      authorName: (json['authorName'] ?? '').toString(),
      stepCount: json['stepCount'] is int ? json['stepCount'] as int : steps.length,
      steps: steps,
      materials: materials,
      reviewCount: json['reviewCount'] is int ? json['reviewCount'] as int : 0,
      averageRating: double.tryParse('${json['averageRating'] ?? 0}') ?? 0,
      isSaved: json['isSaved'] == true,
    );
  }
}

/// Model bước thực hiện.
class TutorialStep {
  final String id;
  final int stepOrder;
  final String title;
  final String content;

  TutorialStep({
    required this.id,
    required this.stepOrder,
    required this.title,
    required this.content,
  });

  /// Chuyển JSON từ backend thành TutorialStep.
  factory TutorialStep.fromJson(Map<String, dynamic> json) {
    return TutorialStep(
      id: (json['id'] ?? '').toString(),
      stepOrder: int.tryParse('${json['stepOrder'] ?? 0}') ?? 0,
      title: (json['title'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
    );
  }
}

/// Model vật liệu.
class TutorialMaterial {
  final String id;
  final String name;
  final String? quantity;

  TutorialMaterial({
    required this.id,
    required this.name,
    this.quantity,
  });

  /// Chuyển JSON từ backend thành TutorialMaterial.
  factory TutorialMaterial.fromJson(Map<String, dynamic> json) {
    return TutorialMaterial(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      quantity: json['quantity']?.toString(),
    );
  }
}

/// Model đánh giá bài hướng dẫn.
class TutorialReview {
  final String id;
  final String userName;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  TutorialReview({
    required this.id,
    required this.userName,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  /// Chuyển JSON từ backend thành TutorialReview.
  factory TutorialReview.fromJson(Map<String, dynamic> json) {
    return TutorialReview(
      id: (json['id'] ?? '').toString(),
      userName: (json['userName'] ?? '').toString(),
      rating: int.tryParse('${json['rating'] ?? 0}') ?? 0,
      comment: json['comment']?.toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }
}