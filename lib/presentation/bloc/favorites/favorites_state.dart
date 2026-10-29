import 'package:equatable/equatable.dart';

import '../../../domain/entities/wallpaper.dart';

enum FavoritesStatus { initial, loading, loaded, error }

class FavoritesState extends Equatable {
  const FavoritesState({
    this.status = FavoritesStatus.initial,
    this.favorites = const [],
    this.errorMessage = '',
  });

  final FavoritesStatus status;
  final List<Wallpaper> favorites;
  final String errorMessage;

  Set<String> get ids => favorites.map((w) => w.id).toSet();
  bool isFavorite(String id) => ids.contains(id);

  FavoritesState copyWith({
    FavoritesStatus? status,
    List<Wallpaper>? favorites,
    String? errorMessage,
  }) {
    return FavoritesState(
      status: status ?? this.status,
      favorites: favorites ?? this.favorites,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, favorites, errorMessage];
}
