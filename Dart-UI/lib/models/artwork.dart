/// Model tác phẩm nghệ thuật.
class Artwork {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String imageUrl;
  final String sourceType;
  final bool isPublic;
  final DateTime createdAt;

  Artwork({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.imageUrl,
    required this.sourceType,
    required this.isPublic,
    required this.createdAt,
  });

  /// Chuyển JSON từ backend thành Artwork.
  factory Artwork.fromJson(Map<String, dynamic> json) {
    return Artwork(
      id: (json['id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: json['description']?.toString(),
      imageUrl: (json['imageUrl'] ?? '').toString(),
      sourceType: (json['sourceType'] ?? 'draw').toString(),
      isPublic: json['isPublic'] != false,
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }
}