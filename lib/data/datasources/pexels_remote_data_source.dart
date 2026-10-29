import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/error/failure.dart';
import '../../domain/entities/wallpaper.dart';
import '../models/wallpaper_model.dart';

typedef PexelsResult = ({List<WallpaperModel> photos, int total, bool hasMore});

/// Live Pexels backend. The API key bakes in at compile time:
/// `flutter run --dart-define=PEXELS_API_KEY=your_key`.
class PexelsRemoteDataSource {
  PexelsRemoteDataSource({http.Client? client, String? apiKey})
    : _client = client ?? http.Client(),
      _apiKey = apiKey ?? const String.fromEnvironment('PEXELS_API_KEY');

  static const _base = 'https://api.pexels.com/v1';
  static const _perPage = 15;

  final http.Client _client;
  final String _apiKey;

  Future<PexelsResult> curated({int page = 1}) {
    return _get(
      Uri.parse('$_base/curated')
          .replace(queryParameters: {'per_page': '$_perPage', 'page': '$page'}),
      WallpaperCategory.nature,
    );
  }

  Future<PexelsResult> search(
    String query, {
    int page = 1,
    int perPage = _perPage,
  }) {
    final uri = Uri.parse('$_base/search').replace(
      queryParameters: {
        'query': query,
        'per_page': '$perPage',
        'page': '$page',
        'orientation': 'portrait',
      },
    );
    return _get(uri, null);
  }

  Future<PexelsResult> _get(
    Uri uri,
    WallpaperCategory? fallbackCategory,
  ) async {
    if (_apiKey.isEmpty) throw const MissingApiKeyFailure();
    late final http.Response response;
    try {
      response = await _client.get(uri, headers: {'Authorization': _apiKey});
    } catch (_) {
      throw const CacheFailure(
        'Could not reach Pexels. Check your connection.',
      );
    }
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const CacheFailure('Pexels rejected the API key.');
    }
    if (response.statusCode != 200) {
      throw CacheFailure('Pexels request failed (${response.statusCode}).');
    }
    final map = jsonDecode(response.body) as Map<String, dynamic>;
    final photos = (map['photos'] as List).map((photo) {
      return WallpaperModel.fromPexels(
        photo as Map<String, dynamic>,
        fallbackCategory: fallbackCategory,
      );
    }).toList();
    final total = (map['total_results'] as num?)?.toInt() ?? photos.length;
    return (
      photos: photos,
      total: total,
      hasMore: map.containsKey('next_page'),
    );
  }
}
