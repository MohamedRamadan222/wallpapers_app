import 'package:equatable/equatable.dart';

import '../../../domain/entities/wallpaper.dart';

enum HomeStatus { initial, loading, loaded, error }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.visible = const [],
    this.query = '',
    this.category,
    this.page = 1,
    this.hasMore = true,
    this.loadingMore = false,
    this.errorMessage = '',
  });

  final HomeStatus status;
  final List<Wallpaper> visible;
  final String query;
  final WallpaperCategory? category;
  final int page;
  final bool hasMore;
  final bool loadingMore;
  final String errorMessage;

  HomeState copyWith({
    HomeStatus? status,
    List<Wallpaper>? visible,
    String? query,
    WallpaperCategory? Function()? category,
    int? page,
    bool? hasMore,
    bool? loadingMore,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      visible: visible ?? this.visible,
      query: query ?? this.query,
      category: category != null ? category() : this.category,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      loadingMore: loadingMore ?? this.loadingMore,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    visible,
    query,
    category,
    page,
    hasMore,
    loadingMore,
    errorMessage,
  ];
}
