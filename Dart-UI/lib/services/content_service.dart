import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/artwork.dart';
import '../models/tutorial.dart';

/// Service gọi API cho bài hướng dẫn và tác phẩm.
class ContentService {
  const ContentService._();

  /// Gọi API lấy danh sách bài hướng dẫn.
  static Future<List<Tutorial>> fetchTutorials({
    String? query,
    String? category,
  }) async {
    final params = <String>[];

    if (query != null && query.trim().isNotEmpty) {
      params.add('q=${Uri.encodeQueryComponent(query.trim())}');
    }

    if (category != null &&
        category.trim().isNotEmpty &&
        category.trim() != 'Tất cả') {
      params.add('category=${Uri.encodeQueryComponent(category.trim())}');
    }

    final suffix = params.isEmpty ? '' : '?${params.join('&')}';
    final uri =
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.tutorialsPath}$suffix');

    final response = await http.get(uri);
    final decoded = jsonDecode(response.body);

    final data = decoded['data'];

    if (data is! List) return [];

    return data
        .map((item) => Tutorial.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  /// Gọi API lấy chi tiết bài hướng dẫn.
  static Future<Tutorial?> fetchTutorialDetail(String tutorialId) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.tutorialsPath}/$tutorialId',
    );

    final response = await http.get(uri);
    final decoded = jsonDecode(response.body);
    final data = decoded['data'];

    if (data is! Map) return null;

    return Tutorial.fromJson(Map<String, dynamic>.from(data));
  }

  /// Gọi API lấy danh sách đánh giá bài hướng dẫn.
  static Future<List<TutorialReview>> fetchTutorialReviews(
    String tutorialId,
  ) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.tutorialsPath}/$tutorialId/reviews',
    );

    final response = await http.get(uri);
    final decoded = jsonDecode(response.body);
    final data = decoded['data'];

    if (data is! List) return [];

    return data
        .map((item) => TutorialReview.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  /// Gọi API lưu hoặc bỏ lưu bài hướng dẫn yêu thích.
  static Future<void> setTutorialFavorite({
    required String tutorialId,
    required bool favorite,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.tutorialsPath}/$tutorialId/favorite',
    );

    if (favorite) {
      await http.post(uri);
    } else {
      await http.delete(uri);
    }
  }

  /// Gọi API gửi đánh giá bài hướng dẫn.
  static Future<void> postTutorialReview({
    required String tutorialId,
    required int rating,
    String? comment,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.tutorialsPath}/$tutorialId/reviews',
    );

    await http.post(
      uri,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode({
        'rating': rating,
        'comment': comment,
      }),
    );
  }

  /// Gọi API upload ảnh tác phẩm.
  static Future<String?> uploadArtworkImageBytes(
    Uint8List bytes, {
    String filename = 'drawing.png',
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.artworksUploadPath}',
    );

    final request = http.MultipartRequest('POST', uri)
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: filename,
        ),
      );

    final streamed = await request.send();
    final responseBody = await streamed.stream.bytesToString();
    final decoded = jsonDecode(responseBody);

    return decoded['imageUrl']?.toString();
  }

  /// Gọi API tạo bản ghi tác phẩm.
  static Future<Artwork?> createArtwork({
    required String title,
    String? description,
    required String imageUrl,
    String sourceType = 'draw',
    bool isPublic = true,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.artworksPath}');

    final response = await http.post(
      uri,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode({
        'title': title,
        'description': description,
        'imageUrl': imageUrl,
        'sourceType': sourceType,
        'isPublic': isPublic,
      }),
    );

    final decoded = jsonDecode(response.body);
    final data = decoded['data'];

    if (data is! Map) return null;

    return Artwork.fromJson(Map<String, dynamic>.from(data));
  }
}