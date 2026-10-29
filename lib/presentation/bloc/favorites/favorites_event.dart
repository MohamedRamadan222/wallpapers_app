import 'package:equatable/equatable.dart';

import '../../../domain/entities/wallpaper.dart';

sealed class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

final class FavoritesStarted extends FavoritesEvent {
  const FavoritesStarted();
}

final class FavoriteToggled extends FavoritesEvent {
  const FavoriteToggled(this.wallpaper);

  final Wallpaper wallpaper;

  @override
  List<Object?> get props => [wallpaper];
}
