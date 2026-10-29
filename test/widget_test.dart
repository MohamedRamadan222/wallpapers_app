import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallpapers_app/data/datasources/pexels_remote_data_source.dart';
import 'package:wallpapers_app/data/repositories/wallpaper_repository_impl.dart';
import 'package:wallpapers_app/data/stores/favorites_store.dart';
import 'package:wallpapers_app/domain/usecases/wallpaper_usecases.dart';
import 'package:wallpapers_app/main.dart';
import 'package:wallpapers_app/presentation/widgets/wallpaper_card.dart';

import 'fake_device_actions.dart';
import 'test_api.dart';

WallpapersApp buildTestApp() {
  final repository = WallpaperRepositoryImpl(
    remote: PexelsRemoteDataSource(client: buildPexelsClient(), apiKey: 'test'),
    favorites: FavoritesStore(),
  );
  return WallpapersApp(
    getWallpapers: GetWallpapers(repository),
    searchWallpapers: SearchWallpapers(repository),
    getCategories: GetCategories(repository),
    getFavorites: GetFavorites(repository),
    toggleFavorite: ToggleFavorite(repository),
    deviceActions: FakeWallpaperDeviceActions(),
  );
}

Future<void> settle(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 3000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('home shows the curated catalog', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await settle(tester);

    expect(find.text('Wallpapers'), findsOneWidget);
    expect(find.text('Curated by Pexels'), findsOneWidget);
    expect(find.byType(WallpaperCard), findsNWidgets(3));
  });

  testWidgets(
    'gibberish search shows the empty state, clearing restores the grid',
    (tester) async {
      await tester.pumpWidget(buildTestApp());
      await settle(tester);

      await tester.enterText(find.byType(TextField), 'zzzqqq');
      await settle(tester);
      expect(find.byType(WallpaperCard), findsNothing);
      expect(find.textContaining('No results for'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '');
      await settle(tester);
      expect(find.byType(WallpaperCard), findsNWidgets(3));
    },
  );

  testWidgets('category row filters home, Saved starts empty', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await settle(tester);

    await tester.tap(find.text('Categories').last);
    await settle(tester);
    expect(find.text('Browse collections'), findsOneWidget);
    expect(find.text('842 wallpapers'), findsNWidgets(6));

    await tester.tap(find.text('AMOLED'));
    await settle(tester);
    expect(find.byType(WallpaperCard), findsOneWidget);

    await tester.tap(find.text('Saved').last);
    await settle(tester);
    expect(find.text('No favorites yet'), findsOneWidget);
  });

  testWidgets('detail offers targets and confirms the native action', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp());
    await settle(tester);

    await tester.tap(find.byType(WallpaperCard).first);
    await tester.pumpAndSettle();

    expect(find.text('Misty Pines'), findsWidgets);
    expect(find.text('4000 × 6000 · Pexels'), findsOneWidget);
    expect(find.byType(InteractiveViewer), findsOneWidget);

    await tester.tap(find.text('Set Wallpaper'));
    await tester.pumpAndSettle();
    expect(find.text('Home screen'), findsOneWidget);
    expect(find.text('Lock screen'), findsOneWidget);
    expect(find.text('Home and lock'), findsOneWidget);

    await tester.tap(find.text('Home and lock'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Saved ✓'), findsOneWidget);
  });

  testWidgets('swipe down dismisses the detail screen', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await settle(tester);

    await tester.tap(find.byType(WallpaperCard).first);
    await tester.pumpAndSettle();
    expect(find.text('Set Wallpaper'), findsOneWidget);

    await tester.flingFrom(const Offset(400, 100), const Offset(0, 500), 800);
    await tester.pumpAndSettle();
    expect(find.text('Set Wallpaper'), findsNothing);
    expect(find.byType(WallpaperCard), findsNWidgets(3));
  });
  testWidgets('heart toggle adds a favorite to Saved', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await settle(tester);

    await tester.tap(find.byType(WallpaperCard).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.favorite_border).first);
    await settle(tester);
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Saved').last);
    await settle(tester);
    expect(find.text('1 wallpaper'), findsOneWidget);
    expect(find.byType(WallpaperCard), findsOneWidget);
  });
  testWidgets('scrolling to the end appends the next page', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await settle(tester);
    expect(find.byType(WallpaperCard), findsNWidgets(3));

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -4000));
    await settle(tester);
    expect(find.byType(WallpaperCard), findsNWidgets(4));
  });
}
