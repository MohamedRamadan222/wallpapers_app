import 'package:wallpapers_app/domain/device/wallpaper_device_actions.dart';

/// Records device-action calls for widget and use-case tests.
class FakeWallpaperDeviceActions implements WallpaperDeviceActions {
  final List<String> methods = [];
  String? lastImageUrl;
  String? lastTitle;
  WallpaperTarget? lastTarget;

  @override
  Future<void> setWallpaper({
    required String imageUrl,
    required String title,
    required WallpaperTarget target,
  }) async {
    methods.add('set');
    lastImageUrl = imageUrl;
    lastTitle = title;
    lastTarget = target;
  }

  @override
  Future<void> saveToGallery({
    required String imageUrl,
    required String title,
  }) async {
    methods.add('save');
    lastImageUrl = imageUrl;
    lastTitle = title;
  }
}
