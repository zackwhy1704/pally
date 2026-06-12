import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/painters/character_painter.dart';
import 'package:pally/shared/models/mochi_character.dart';

/// Debug-only visual catalogue of every [MochiCharacter] vector painter.
///
/// Renders each character via [characterPainterFor] (NOT the asset image) at a
/// fixed size with its enum name beneath, so a developer can eyeball the whole
/// dispatcher at a glance and spot a character that renders as the wrong one or
/// half-drawn. Reachable only in debug builds (see [DebugPainterGalleryRoute]).
class PainterGalleryScreen extends StatelessWidget {
  const PainterGalleryScreen({super.key});

  static const double _tileSize = 96;

  @override
  Widget build(BuildContext context) {
    // Hard guard: this screen has no place in a release build.
    if (!kDebugMode) {
      return const Scaffold(
        body: Center(child: Text('Debug builds only')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Text('Painter Gallery (debug)', style: AppTextStyles.title),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 160,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: 0.8,
        ),
        itemCount: MochiCharacter.values.length,
        itemBuilder: (context, i) {
          final c = MochiCharacter.values[i];
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: _tileSize,
                height: _tileSize,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outline),
                ),
                child: CustomPaint(
                  size: const Size(_tileSize, _tileSize),
                  painter: characterPainterFor(c, _tileSize),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                c.name,
                style: AppTextStyles.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );
        },
      ),
    );
  }
}
