import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/wallpaper.dart';
import '../../../domain/usecases/wallpaper_usecases.dart';
import '../../widgets/empty_state.dart';

/// Categories tab: collection rows. Tapping a row browses that
/// category on Home — `architecture` lands on the empty state.
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key, required this.onBrowse});

  final ValueChanged<WallpaperCategory> onBrowse;

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late final Future<List<CategoryInfo>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<GetCategories>()();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CategoryInfo>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const EmptyState(
            icon: Icons.cloud_off_outlined,
            title: 'Could not load categories.',
            hint: 'Pull to retry by reopening this tab.',
          );
        }
        if (!snapshot.hasData) {
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
            itemCount: 6,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, _) => Container(
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          );
        }
        final categories = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(2, 10, 2, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Browse collections',
                    style: TextStyle(fontSize: 13, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            for (final c in categories) ...[
              _CategoryRow(info: c, onTap: () => widget.onBrowse(c.category)),
              const SizedBox(height: 10),
            ],
          ],
        );
      },
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.info, required this.onTap});

  final CategoryInfo info;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 14, 10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: Image.network(
                    info.thumbUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) {
                      return const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: AppColors.cardFallback,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      info.countLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 20, color: AppColors.faint),
            ],
          ),
        ),
      ),
    );
  }
}
