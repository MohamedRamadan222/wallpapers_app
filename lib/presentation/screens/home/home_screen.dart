import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/wallpaper.dart';
import '../../bloc/home/home_bloc.dart';
import '../../bloc/home/home_event.dart';
import '../../bloc/home/home_state.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/search_field.dart';
import '../../widgets/wallpaper_card.dart';

const _chips = <({String label, WallpaperCategory? category})>[
  (label: 'All', category: null),
  (label: 'Nature', category: WallpaperCategory.nature),
  (label: 'Abstract', category: WallpaperCategory.abstract),
  (label: 'Minimal', category: WallpaperCategory.minimal),
  (label: 'AMOLED', category: WallpaperCategory.amoled),
  (label: 'Gradient', category: WallpaperCategory.gradient),
];

/// Home tab: header, live search, category chips, masonry grid.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listenWhen: (prev, next) => prev.query != next.query,
      listener: (_, state) {
        if (_controller.text != state.query) _controller.text = state.query;
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification &&
              notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent - 200) {
            context.read<HomeBloc>().add(const HomeLoadMore());
          }
          return false;
        },
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Wallpapers',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.4,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Curated by Pexels',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                        _Avatar(),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SearchField(
                      controller: _controller,
                      onChanged: (q) =>
                          context.read<HomeBloc>().add(HomeQueryChanged(q)),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 60,
                child: BlocSelector<HomeBloc, HomeState, WallpaperCategory?>(
                  selector: (s) => s.category,
                  builder: (context, active) {
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
                      ),
                      itemCount: _chips.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final chip = _chips[i];
                        final selected = active == chip.category;
                        return ChoiceChip(
                          label: Text(chip.label),
                          selected: selected,
                          onSelected: (_) => context.read<HomeBloc>().add(
                            HomeCategoryChanged(chip.category),
                          ),
                          labelStyle: TextStyle(
                            fontSize: 13,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: selected
                                ? AppColors.accentInk
                                : AppColors.muted,
                          ),
                          selectedColor: AppColors.accent,
                          backgroundColor: AppColors.surface,
                          side: BorderSide(
                            color: selected
                                ? AppColors.accent
                                : AppColors.border,
                          ),
                          shape: const StadiumBorder(),
                          showCheckmark: false,
                          visualDensity: VisualDensity.compact,
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                switch (state.status) {
                  case HomeStatus.loading || HomeStatus.initial:
                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                      sliver: SliverMasonryGrid.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childCount: 4,
                        itemBuilder: (_, i) => AspectRatio(
                          aspectRatio: i.isOdd ? 3 / 4.4 : 3 / 4,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface2,
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ),
                    );
                  case HomeStatus.error:
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyState(
                        icon: Icons.cloud_off_outlined,
                        title: state.errorMessage,
                        hint: 'Check your connection and try again.',
                        actionLabel: 'Retry',
                        onAction: () =>
                            context.read<HomeBloc>().add(const HomeStarted()),
                      ),
                    );
                  case HomeStatus.loaded:
                    if (state.visible.isEmpty) {
                      final searching = state.query.trim().isNotEmpty;
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: EmptyState(
                          icon: Icons.search,
                          title: searching
                              ? 'No results for "${state.query.trim()}"'
                              : 'Nothing here yet',
                          hint: searching
                              ? 'Try "mist" or "dune"'
                              : 'Try another collection',
                        ),
                      );
                    }
                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                      sliver: SliverMasonryGrid.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childCount: state.visible.length,
                        itemBuilder: (_, i) =>
                            WallpaperCard(wallpaper: state.visible[i]),
                      ),
                    );
                }
              },
            ),
            BlocBuilder<HomeBloc, HomeState>(
              buildWhen: (prev, next) =>
                  prev.loadingMore != next.loadingMore ||
                  prev.status != next.status ||
                  prev.visible.length != next.visible.length,
              builder: (context, state) {
                if (!state.loadingMore) {
                  return const SliverToBoxAdapter(child: SizedBox(height: 20));
                }
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: AppColors.muted,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surface2,
        border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
      ),
      child: const Text(
        'W',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.muted,
        ),
      ),
    );
  }
}
