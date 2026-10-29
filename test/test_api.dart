import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Canned Pexels API for tests. Three photos keep widget counts exact.
Map<String, dynamic> testPhoto({
  required int id,
  required String title,
  int width = 4000,
  int height = 6000,
  required String photographer,
}) {
  return {
    'id': id,
    'width': width,
    'height': height,
    'alt': title,
    'photographer': photographer,
    'src': {
      'portrait': 'https://example.com/$id-portrait.jpg',
      'large': 'https://example.com/$id-large.jpg',
      'large2x': 'https://example.com/$id-action.jpg',
      'medium': 'https://example.com/$id-medium.jpg',
      'original': 'https://example.com/$id-original.jpg',
    },
  };
}

final testPhotos = [
  testPhoto(id: 101, title: 'Misty Pines', photographer: 'Field Notes'),
  testPhoto(id: 102, title: 'Canyon Dusk', photographer: 'Field Notes'),
  testPhoto(
    id: 103,
    title: 'Granite',
    photographer: 'Mono Chrome',
    width: 6000,
    height: 3000,
  ),
];

String photosJson(
  List<Map<String, dynamic>> photos, {
  int total = 1500,
  bool next = false,
}) {
  return jsonEncode({
    'photos': photos,
    'total_results': total,
    if (next) 'next_page': 'https://api.pexels.com/v1/curated?page=2',
  });
}

/// Routes like the real API: curated list, per-category singletons for
/// thumbs/counts, real filtering for the AMOLED chip, empty for gibberish.
MockClient buildPexelsClient() {
  return MockClient((request) async {
    if (request.headers['Authorization'] != 'test') {
      return http.Response('{}', 401);
    }
    final path = request.url.path;
    final params = request.url.queryParameters;
    if (path.endsWith('/curated')) {
      if (params['page'] == '2') {
        return http.Response(photosJson([testPhotos[2]]), 200);
      }
      return http.Response(photosJson(testPhotos, next: true), 200);
    }
    if (path.endsWith('/search')) {
      final query = params['query'] ?? '';
      if (query.contains('zzzqqq')) return http.Response(photosJson([]), 200);
      if (params['per_page'] == '1') {
        return http.Response(photosJson([testPhotos.first], total: 842), 200);
      }
      if (query.contains('dark black')) {
        return http.Response(photosJson([testPhotos[2]]), 200);
      }
      if (params['page'] == '2') {
        return http.Response(photosJson([testPhotos[2]]), 200);
      }
      return http.Response(photosJson(testPhotos, next: true), 200);
    }
    return http.Response('{}', 404);
  });
}
