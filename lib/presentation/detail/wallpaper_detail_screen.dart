import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/wallpaper.dart';
import '../bloc/favorites/favorites_bloc.dart';
import '../bloc/favorites/favorites_event.dart';
import '../bloc/favorites/favorites_state.dart';
import '../../../core/error/failure.dart';
import '../../../domain/usecases/device_actions_usecases.dart';
import '../../../domain/device/wallpaper_device_actions.dart';

/// Full-screen detail sheet, pushed as a slide-up route.
/// Mirrors the prototype overlay: large preview, drag handle, titles,
/// meta row, Set/Download actions and the save toggle.
Future<void> showWallpaperDetail(BuildContext context, Wallpaper wallpaper) {
  return Navigator.of(context).push(
    PageRouteBuilder<void>(
      fullscreenDialog: true,
      transitionDuration: const Duration(milliseconds: 260),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, _, _) => WallpaperDetailScreen(wallpaper: wallpaper),
      transitionsBuilder: (_, animation, _, child) {
        return SlideTransition(
          position: Tween(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        );
      },
    ),
  );
}

class WallpaperDetailScreen extends StatefulWidget {
  const WallpaperDetailScreen({super.key, required this.wallpaper});

  final Wallpaper wallpaper;

  @override
  State<WallpaperDetailScreen> createState() => _WallpaperDetailScreenState();
}

class _WallpaperDetailScreenState extends State<WallpaperDetailScreen> {
  String? _flashSet;
  String? _flashDownload;
  String? _busy;
  Timer? _timer;
  final TransformationController _zoom = TransformationController();
  double _dragDy = 0;

  @override
  void dispose() {
    _timer?.cancel();
    _zoom.dispose();
    super.dispose();
  }

  void _flash(bool isSet) {
    _timer?.cancel();
    setState(() {
      if (isSet) {
        _flashSet = 'Saved ✓';
      } else {
        _flashDownload = 'Downloaded ✓';
      }
    });
    _timer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _flashSet = _flashDownload = null);
    });
  }

  Future<void> _runAction({required bool isSet}) async {
    if (_busy != null) return;
    final setWallpaper = context.read<SetWallpaper>();
    final saveToGallery = context.read<SaveToGallery>();
    final target = isSet ? await _pickTarget() : null;
    if (isSet && target == null) return;
    setState(() => _busy = isSet ? 'set' : 'save');
    try {
      if (isSet) {
        await setWallpaper(widget.wallpaper, target: target!);
      } else {
        await saveToGallery(widget.wallpaper);
      }
      if (!mounted) return;
      _flash(isSet);
    } on AppFailure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  /// Home / Lock / Both chooser, styled like the rest of the sheet.
  Future<WallpaperTarget?> _pickTarget() {
    return showModalBottomSheet<WallpaperTarget>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: AppColors.border),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              for (final target in WallpaperTarget.values)
                ListTile(
                  leading: Icon(_targetIcon(target), color: AppColors.muted),
                  title: Text(
                    _targetLabel(target),
                    style: const TextStyle(color: AppColors.text),
                  ),
                  onTap: () => Navigator.of(sheetContext).pop(target),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  String _targetLabel(WallpaperTarget target) => switch (target) {
    WallpaperTarget.home => 'Home screen',
    WallpaperTarget.lock => 'Lock screen',
    WallpaperTarget.both => 'Home and lock',
  };

  IconData _targetIcon(WallpaperTarget target) => switch (target) {
    WallpaperTarget.home => Icons.home_outlined,
    WallpaperTarget.lock => Icons.lock_outline,
    WallpaperTarget.both => Icons.smartphone_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final wallpaper = widget.wallpaper;
    return Scaffold(
      backgroundColor: AppColors.phone,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  InteractiveViewer(
                    transformationController: _zoom,
                    minScale: 1,
                    maxScale: 4,
                    child: ColoredBox(
                      color: AppColors.surface,
                      child: Image.network(
                        wallpaper.fullUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const ColoredBox(color: AppColors.surface2);
                        },
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
                  // Dismiss strip: owns the top edge so swipe-down to close
                  // never fights the pinch-zoom gesture arena. While zoomed
                  // the strip stands down and the viewer pans instead.
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 148,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onVerticalDragUpdate: (details) {
                        if (_zoom.value.getMaxScaleOnAxis() > 1.01) return;
                        _dragDy += details.delta.dy;
                      },
                      onVerticalDragEnd: (details) {
                        final distance = _dragDy;
                        final velocity = details.primaryVelocity ?? 0;
                        _dragDy = 0;
                        if (distance > 110 || velocity > 700) {
                          Navigator.of(context).pop();
                        }
                      },
                      onVerticalDragCancel: () => _dragDy = 0,
                    ),
                  ),
                  Positioned(
                    top: topPadding + 10,
                    left: 0,
                    right: 0,
                    child: const Center(
                      child: SizedBox(
                        width: 36,
                        height: 4,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.surface2,
                            borderRadius: BorderRadius.all(
                              Radius.circular(999),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: topPadding + 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromRGBO(16, 16, 19, 0.75),
                          border: Border.fromBorderSide(
                            BorderSide(color: AppColors.border),
                          ),
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              wallpaper.title,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              wallpaper.author,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      BlocBuilder<FavoritesBloc, FavoritesState>(
                        builder: (context, state) {
                          final faved = state.isFavorite(wallpaper.id);
                          return GestureDetector(
                            onTap: () => context.read<FavoritesBloc>().add(
                              FavoriteToggled(wallpaper),
                            ),
                            child: Container(
                              width: 42,
                              height: 42,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: faved
                                    ? AppColors.accent
                                    : AppColors.surface,
                                border: Border.all(
                                  color: faved
                                      ? AppColors.accent
                                      : AppColors.border,
                                ),
                              ),
                              child: Icon(
                                faved ? Icons.favorite : Icons.favorite_border,
                                size: 19,
                                color: faved
                                    ? AppColors.accentInk
                                    : AppColors.muted,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      '${wallpaper.metaLine} · Pexels',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.faint,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton.primary(
                          label: _busy == 'set'
                              ? 'Setting…'
                              : (_flashSet ?? 'Set Wallpaper'),
                          onTap: () => _runAction(isSet: true),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ActionButton.ghost(
                          label: _busy == 'save'
                              ? 'Saving…'
                              : (_flashDownload ?? 'Download'),
                          onTap: () => _runAction(isSet: false),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton.primary({required this.label, required this.onTap})
    : primary = true;
  const _ActionButton.ghost({required this.label, required this.onTap})
    : primary = false;

  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: primary ? AppColors.accent : null,
          border: primary ? null : Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: primary ? AppColors.accentInk : AppColors.text,
          ),
        ),
      ),
    );
  }
}
