import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failure.dart';
import '../../../domain/usecases/wallpaper_usecases.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

/// Owns the saved set. Emits resolved [Wallpaper] lists so screens stay dumb.
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  FavoritesBloc({required this.getFavorites, required this.toggleFavorite})
    : super(const FavoritesState()) {
    on<FavoritesStarted>(_onStarted);
    on<FavoriteToggled>(_onToggled);
  }

  final GetFavorites getFavorites;
  final ToggleFavorite toggleFavorite;

  Future<void> _onStarted(
    FavoritesStarted event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(state.copyWith(status: FavoritesStatus.loading));
    try {
      emit(
        state.copyWith(
          status: FavoritesStatus.loaded,
          favorites: await getFavorites(),
        ),
      );
    } on AppFailure catch (e) {
      emit(
        state.copyWith(status: FavoritesStatus.error, errorMessage: e.message),
      );
    }
  }

  Future<void> _onToggled(
    FavoriteToggled event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      emit(state.copyWith(favorites: await toggleFavorite(event.wallpaper)));
    } on AppFailure catch (e) {
      emit(
        state.copyWith(status: FavoritesStatus.error, errorMessage: e.message),
      );
    }
  }
}
