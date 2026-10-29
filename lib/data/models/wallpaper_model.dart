import '../../domain/entities/wallpaper.dart';

class WallpaperModel extends Wallpaper {
  const WallpaperModel({
    required super.id,
    required super.title,
    required super.author,
    required super.category,
    required super.tall,
    required super.thumbUrl,
    required super.fullUrl,
    required super.actionUrl,
    required super.width,
    required super.height,
  });

  /// Parses one Pexels photo object. `src` URLs accept Pexels image params;
  /// portrait/large variants keep grid traffic small.
  factory WallpaperModel.fromPexels(
    Map<String, dynamic> map, {
    WallpaperCategory? fallbackCategory,
  }) {
    final src = map['src'] as Map<String, dynamic>? ?? {};
    String url(String key) => (src[key] as String?) ?? '';
    final width = (map['width'] as num?)?.toInt() ?? 0;
    final height = (map['height'] as num?)?.toInt() ?? 0;
    final alt = (map['alt'] as String?)?.trim() ?? '';
    return WallpaperModel(
      id: '${map['id']}',
      title: alt.isEmpty ? 'Untitled' : alt,
      author:
          '@${(map['photographer'] as String?)?.trim().isEmpty ?? true ? 'pexels' : map['photographer']}',
      category: fallbackCategory ?? WallpaperCategory.nature,
      tall: width <= 0 ? false : height / width >= 1.35,
      thumbUrl: url('portrait').isEmpty ? url('medium') : url('portrait'),
      fullUrl: url('large').isEmpty ? url('medium') : url('large'),
      actionUrl: url('large2x').isEmpty ? url('original') : url('large2x'),
      width: width,
      height: height,
    );
  }
}
