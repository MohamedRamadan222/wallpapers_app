import 'package:flutter_test/flutter_test.dart';
import 'package:wallpapers_app/core/error/failure.dart';
import 'package:wallpapers_app/data/datasources/pexels_remote_data_source.dart';
import 'package:wallpapers_app/data/repositories/wallpaper_repository_impl.dart';
import 'package:wallpapers_app/data/stores/favorites_store.dart';
import 'package:wallpapers_app/domain/entities/wallpaper.dart';

import 'test_api.dart';

WallpaperRepositoryImpl repository() {
  return WallpaperRepositoryImpl(
    remote: PexelsRemoteDataSource(client: buildPexelsClient(), apiKey: 'test'),
    favorites: FavoritesStore(),
  );
}

void main() {
  test('curated parses photos with real facts', () async {
    final page = await repository().getCurated();

    expect(page.items, hasLength(3));
    expect(page.items.first.title, 'Misty Pines');
    expect(page.items.first.author, '@Field Notes');
    expect(page.items.first.tall, isTrue);
    expect(page.items[2].tall, isFalse);
    expect(page.items.first.thumbUrl, contains('101-portrait'));
    expect(page.items.first.actionUrl, contains('101-action'));
  });

  test('curated reports more pages', () async {
    expect((await repository().getCurated()).hasMore, isTrue);
  });

  test('search combines category term and query', () async {
    final page = await repository().searchWallpapers(
      query: 'mist',
      category: WallpaperCategory.nature,
    );

    expect(page.items, hasLength(3));
  });

  test('empty search reports the end of the list', () async {
    final page = await repository().searchWallpapers(query: 'zzzqqq');

    expect(page.items, isEmpty);
    expect(page.hasMore, isFalse);
  });

  test('second page appends without a next link', () async {
    final page = await repository().searchWallpapers(query: 'mist', page: 2);

    expect(page.items, hasLength(1));
    expect(page.hasMore, isFalse);
  });

  test('categories carry live counts and thumbs', () async {
    final categories = await repository().getCategories();

    expect(categories, hasLength(6));
    expect(
      categories.map((c) => c.category),
      containsAll(WallpaperCategory.values),
    );
    for (final category in categories) {
      expect(category.wallpaperCount, 842);
      expect(category.thumbUrl, isNotEmpty);
    }
  });

  test('rejected keys surface a clear failure', () {
    final bad = WallpaperRepositoryImpl(
      remote: PexelsRemoteDataSource(
        client: buildPexelsClient(),
        apiKey: 'wrong',
      ),
      favorites: FavoritesStore(),
    );

    expect(bad.getCurated(), throwsA(isA<CacheFailure>()));
  });

  test('missing key fails before any request', () {
    final keyless = WallpaperRepositoryImpl(
      remote: PexelsRemoteDataSource(client: buildPexelsClient(), apiKey: ''),
      favorites: FavoritesStore(),
    );

    expect(keyless.getCurated(), throwsA(isA<MissingApiKeyFailure>()));
  });

  test('favorites store toggles full values without refetching', () async {
    final repo = repository();
    final photo = (await repo.getCurated()).items.first;

    expect(await repo.getFavorites(), isEmpty);
    expect(await repo.toggleFavorite(photo), [photo]);
    expect(await repo.toggleFavorite(photo), isEmpty);
  });
}
