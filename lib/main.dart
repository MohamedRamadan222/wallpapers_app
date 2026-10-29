import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'data/datasources/pexels_remote_data_source.dart';
import 'data/repositories/wallpaper_repository_impl.dart';
import 'data/services/wallpaper_device_service.dart';
import 'data/stores/favorites_store.dart';
import 'domain/device/wallpaper_device_actions.dart';
import 'domain/usecases/device_actions_usecases.dart';
import 'domain/usecases/wallpaper_usecases.dart';
import 'presentation/bloc/favorites/favorites_bloc.dart';
import 'presentation/bloc/favorites/favorites_event.dart';
import 'presentation/bloc/home/home_bloc.dart';
import 'presentation/bloc/home/home_event.dart';
import 'presentation/screens/app_shell.dart';

void main() {
  final repository = WallpaperRepositoryImpl(
    remote: PexelsRemoteDataSource(),
    favorites: FavoritesStore(),
  );
  runApp(
    WallpapersApp(
      getWallpapers: GetWallpapers(repository),
      searchWallpapers: SearchWallpapers(repository),
      getCategories: GetCategories(repository),
      getFavorites: GetFavorites(repository),
      toggleFavorite: ToggleFavorite(repository),
    ),
  );
}

/// Root widget. Dependencies are constructor-injected so widget tests can
/// supply fakes without touching production wiring.
class WallpapersApp extends StatelessWidget {
  const WallpapersApp({
    super.key,
    required this.getWallpapers,
    required this.searchWallpapers,
    required this.getCategories,
    required this.getFavorites,
    required this.toggleFavorite,
    this.deviceActions,
  });

  final GetWallpapers getWallpapers;
  final SearchWallpapers searchWallpapers;
  final GetCategories getCategories;
  final GetFavorites getFavorites;
  final ToggleFavorite toggleFavorite;

  /// Overrides the MethodChannel-backed service (tests inject a fake).
  final WallpaperDeviceActions? deviceActions;

  @override
  Widget build(BuildContext context) {
    final actions = deviceActions ?? WallpaperDeviceService();
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<GetCategories>.value(value: getCategories),
        RepositoryProvider<SetWallpaper>.value(value: SetWallpaper(actions)),
        RepositoryProvider<SaveToGallery>.value(value: SaveToGallery(actions)),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => HomeBloc(
              getWallpapers: getWallpapers,
              searchWallpapers: searchWallpapers,
            )..add(const HomeStarted()),
          ),
          BlocProvider(
            create: (_) => FavoritesBloc(
              getFavorites: getFavorites,
              toggleFavorite: toggleFavorite,
            )..add(const FavoritesStarted()),
          ),
        ],
        child: MaterialApp(
          title: 'Wallpapers',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark,
          home: const AppShell(),
        ),
      ),
    );
  }
}
