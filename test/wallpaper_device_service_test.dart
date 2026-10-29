import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:wallpapers_app/core/error/failure.dart';
import 'package:wallpapers_app/data/services/wallpaper_device_service.dart';
import 'package:wallpapers_app/domain/device/wallpaper_device_actions.dart';
import 'package:wallpapers_app/domain/entities/wallpaper.dart';
import 'package:wallpapers_app/domain/usecases/device_actions_usecases.dart';

import 'fake_device_actions.dart';

const _bytes = [0x89, 0x50, 0x4E, 0x47];
const _wallpaper = Wallpaper(
  id: '1015',
  title: 'Misty Pines',
  author: '@fieldnotes',
  category: WallpaperCategory.nature,
  tall: true,
  thumbUrl: 'https://example.com/portrait.jpg',
  fullUrl: 'https://example.com/large.jpg',
  actionUrl: 'https://example.com/action.jpg',
  width: 1080,
  height: 1920,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('wallpapers_app/native');
  late List<MethodCall> calls;

  setUp(() {
    calls = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  WallpaperDeviceService service({int httpStatus = 200}) {
    return WallpaperDeviceService(
      client: MockClient((_) async => http.Response.bytes(_bytes, httpStatus)),
    );
  }

  test(
    'setWallpaper downloads then forwards bytes, title and target',
    () async {
      await service().setWallpaper(
        imageUrl: _wallpaper.actionUrl,
        title: _wallpaper.title,
        target: WallpaperTarget.lock,
      );

      expect(calls, hasLength(1));
      expect(calls.single.method, 'setWallpaper');
      expect(calls.single.arguments['target'], 'lock');
      expect(calls.single.arguments['title'], 'Misty Pines');
      expect((calls.single.arguments['bytes'] as Uint8List).toList(), _bytes);
    },
  );

  test('saveToGallery omits the target argument', () async {
    await service().saveToGallery(
      imageUrl: _wallpaper.actionUrl,
      title: _wallpaper.title,
    );

    expect(calls.single.method, 'saveToGallery');
    expect((calls.single.arguments as Map).containsKey('target'), isFalse);
  });

  test(
    'platform errors surface as DeviceActionFailure with the native message',
    () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            channel,
            (_) async =>
                throw PlatformException(code: 'unsupported', message: 'Nope.'),
          );

      expect(
        service().setWallpaper(
          imageUrl: _wallpaper.actionUrl,
          title: _wallpaper.title,
          target: WallpaperTarget.both,
        ),
        throwsA(
          isA<DeviceActionFailure>().having(
            (e) => e.message,
            'message',
            'Nope.',
          ),
        ),
      );
    },
  );

  test('missing plugin maps to the not-available message', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);

    expect(
      service().saveToGallery(
        imageUrl: _wallpaper.actionUrl,
        title: _wallpaper.title,
      ),
      throwsA(
        isA<DeviceActionFailure>().having(
          (e) => e.message,
          'message',
          'Not available on this device.',
        ),
      ),
    );
  });

  test('failed downloads never reach the platform channel', () async {
    expect(
      service(
        httpStatus: 404,
      ).saveToGallery(imageUrl: _wallpaper.actionUrl, title: _wallpaper.title),
      throwsA(isA<DeviceActionFailure>()),
    );
    expect(calls, isEmpty);
  });

  test('use cases forward the device-sized URL and default target', () async {
    final fake = FakeWallpaperDeviceActions();

    await SetWallpaper(fake)(_wallpaper);
    await SaveToGallery(fake)(_wallpaper);

    expect(fake.methods, ['set', 'save']);
    expect(fake.lastImageUrl, _wallpaper.actionUrl);
    expect(fake.lastTarget, WallpaperTarget.both);
  });
}
