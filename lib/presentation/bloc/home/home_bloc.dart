import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failure.dart';
import '../../../domain/usecases/wallpaper_usecases.dart';
import 'home_event.dart';
import 'home_state.dart';

/// Owns the Home grid: curated load, debounced live search, chip filter,
/// and infinite scroll. Every keystroke settles 400ms before hitting Pexels;
/// reaching the grid end appends the next page until `hasMore` runs out.
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({required this.getWallpapers, required this.searchWallpapers})
    : super(const HomeState()) {
    on<HomeStarted>(_onStarted);
    on<HomeQueryChanged>(_onQueryChanged);
    on<HomeCategoryChanged>(_onCategoryChanged);
    on<HomeRefreshRequested>(_onRefresh);
    on<HomeLoadMore>(_onLoadMore);
  }

  final GetWallpapers getWallpapers;
  final SearchWallpapers searchWallpapers;
  Timer? _debounce;
  bool _loadingMore = false;

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading));
    await _fetch(emit, append: false);
  }

  void _onQueryChanged(HomeQueryChanged event, Emitter<HomeState> emit) {
    emit(state.copyWith(query: event.query));
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 400),
      () => add(const HomeRefreshRequested()),
    );
  }

  void _onCategoryChanged(HomeCategoryChanged event, Emitter<HomeState> emit) {
    _debounce?.cancel();
    emit(state.copyWith(category: () => event.category, query: ''));
    add(const HomeRefreshRequested());
  }

  Future<void> _onRefresh(HomeRefreshRequested event, Emitter<HomeState> emit) {
    return _fetch(emit, append: false);
  }

  Future<void> _onLoadMore(HomeLoadMore event, Emitter<HomeState> emit) async {
    if (_loadingMore || state.status != HomeStatus.loaded || !state.hasMore) {
      return;
    }
    _loadingMore = true;
    emit(state.copyWith(loadingMore: true));
    try {
      await _fetch(emit, append: true);
    } finally {
      _loadingMore = false;
      emit(state.copyWith(loadingMore: false));
    }
  }

  Future<void> _fetch(Emitter<HomeState> emit, {required bool append}) async {
    final filtering = state.query.trim().isNotEmpty || state.category != null;
    final page = append ? state.page + 1 : 1;
    if (state.visible.isEmpty) {
      emit(state.copyWith(status: HomeStatus.loading));
    }
    try {
      final result = filtering
          ? await searchWallpapers(
              query: state.query,
              category: state.category,
              page: page,
            )
          : await getWallpapers(page: page);
      emit(
        state.copyWith(
          status: HomeStatus.loaded,
          visible: append ? [...state.visible, ...result.items] : result.items,
          page: page,
          hasMore: result.hasMore,
        ),
      );
    } on AppFailure catch (e) {
      // Keep a populated grid on transient failures; surface the error
      // state only when there is nothing to show.
      if (state.visible.isEmpty) {
        emit(state.copyWith(status: HomeStatus.error, errorMessage: e.message));
      }
    }
  }
}
