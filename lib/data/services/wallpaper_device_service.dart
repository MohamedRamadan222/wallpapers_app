import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../../core/error/failure.dart';
import '../../domain/device/wallpaper_device_actions.dart';

/// Downloads the image in Dart, then hands raw bytes to the host platform
/// over `wallpapers_app/native`. One download path, testable, swappable.
class WallpaperDeviceService implements WallpaperDeviceActions {
  WallpaperDeviceService({http.Client? client, MethodChannel? channel})
    : _client = client ?? http.Client(),
      _channel = channel ?? const MethodChannel('wallpapers_app/native');

  final http.Client _client;
  final MethodChannel _channel;

  @override
  Future<void> setWallpaper({
    required String imageUrl,
    required String title,
    required WallpaperTarget target,
  }) {
    return _send(
      'setWallpaper',
      imageUrl: imageUrl,
      title: title,
      target: target,
    );
  }

  @override
  Future<void> saveToGallery({
    required String imageUrl,
    required String title,
  }) {
    return _send(
      'saveToGallery',
      imageUrl: imageUrl,
      title: title,
      target: null,
    );
  }

  Future<void> _send(
    String method, {
    required String imageUrl,
    required String title,
    required WallpaperTarget? target,
  }) async {
    final bytes = await _download(imageUrl);
    try {
      await _channel.invokeMethod<void>(method, {
        'bytes': bytes,
        'title': title,
        if (target != null) 'target': target.name,
      });
    } on PlatformException catch (e) {
      throw DeviceActionFailure(e.message ?? 'Could not complete that action.');
    } on MissingPluginException {
      throw const DeviceActionFailure('Not available on this device.');
    }
  }

  Future<Uint8List> _download(String imageUrl) async {
    late final http.Response response;
    try {
      response = await _client.get(Uri.parse(imageUrl));
    } catch (_) {
      throw const DeviceActionFailure(
        'Could not download the image. Check your connection.',
      );
    }
    if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
      throw const DeviceActionFailure(
        'Could not download the image. Check your connection.',
      );
    }
    return response.bodyBytes;
  }
}
