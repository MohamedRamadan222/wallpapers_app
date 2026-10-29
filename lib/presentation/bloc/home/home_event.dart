import 'package:equatable/equatable.dart';

import '../../../domain/entities/wallpaper.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Initial load and error retry. Refetches page 1 with current filters.
final class HomeStarted extends HomeEvent {
  const HomeStarted();
}

final class HomeQueryChanged extends HomeEvent {
  const HomeQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

final class HomeCategoryChanged extends HomeEvent {
  const HomeCategoryChanged(this.category);

  final WallpaperCategory? category;

  @override
  List<Object?> get props => [category];
}

/// Internal: debounced filter commit for live search.
final class HomeRefreshRequested extends HomeEvent {
  const HomeRefreshRequested();
}

/// Appends the next page when the grid scrolls near the end.
final class HomeLoadMore extends HomeEvent {
  const HomeLoadMore();
}
