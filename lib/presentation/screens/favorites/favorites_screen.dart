import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../core/theme/app_colors.dart';
import '../../bloc/favorites/favorites_bloc.dart';
import '../../bloc/favorites/favorites_event.dart';
import '../../bloc/favorites/favorites_state.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/wallpaper_card.dart';

/// Saved tab: favorited wallpapers plus the empty state.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesBloc, FavoritesState>(
      builder: (context, state) {
        final count = state.favorites.length;
        final subtitle = '$count ${count == 1 ? 'wallpaper' : 'wallpapers'}';
        switch (state.status) {
          case FavoritesStatus.loading || FavoritesStatus.initial:
            return const Center(
              child: CircularProgressIndicator(color: AppColors.muted),
            );
          case FavoritesStatus.error:
            return EmptyState(
              icon: Icons.cloud_off_outlined,
              title: state.errorMessage,
              hint: 'Try again.',
              actionLabel: 'Retry',
              onAction: () =>
                  context.read<FavoritesBloc>().add(const FavoritesStarted()),
            );
          case FavoritesStatus.loaded:
            if (state.favorites.isEmpty) {
              return ListView(
                children: [
                  _Header(subtitle: subtitle),
                  const EmptyState(
                    icon: Icons.favorite_border,
                    title: 'No favorites yet',
                    hint: 'Tap the heart on any wallpaper',
                  ),
                ],
              );
            }
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _Header(subtitle: subtitle)),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                  sliver: SliverMasonryGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childCount: state.favorites.length,
                    itemBuilder: (_, i) =>
                        WallpaperCard(wallpaper: state.favorites[i]),
                  ),
                ),
              ],
            );
        }
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.subtitle});

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Saved',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 13, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
