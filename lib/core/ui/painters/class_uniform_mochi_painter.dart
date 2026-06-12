import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/shared/models/avatar.dart';
import 'package:pally/shared/models/mochi_character.dart';

/// Maps a backend [subjectGlyph] key to a Material icon for the class badge.
///
/// Unknown or missing keys resolve to a neutral book icon so a stale/new
/// backend value never crashes or renders a blank badge.
IconData classGlyphIcon(String? subjectGlyph) {
  switch ((subjectGlyph ?? '').toLowerCase()) {
    case 'math':
    case 'maths':
      return Icons.calculate;
    case 'science':
      return Icons.science;
    case 'english':
      return Icons.menu_book;
    case 'history':
      return Icons.history_edu;
    case 'coding':
      return Icons.code;
    case 'art':
      return Icons.palette;
    case 'geography':
      return Icons.public;
    case 'languages':
      return Icons.translate;
    case 'music':
      return Icons.music_note;
    case 'pe':
      return Icons.sports_soccer;
    case 'health':
      return Icons.favorite;
    case 'literature':
      return Icons.auto_stories;
    case 'general':
      return Icons.school;
    default:
      // Neutral fallback — never crash, never blank.
      return Icons.menu_book;
  }
}

/// Parses a hex string like "#7042ED" or "7042ED" into a [Color].
///
/// Falls back to the brand purple for empty/malformed values so a class
/// avatar always renders a sensible band.
Color parseBandColor(String? hex) {
  var s = (hex ?? '').trim();
  if (s.startsWith('#')) s = s.substring(1);
  if (s.length == 6) s = 'FF$s'; // add opaque alpha
  if (s.length == 8) {
    final value = int.tryParse(s, radix: 16);
    if (value != null) return Color(value);
  }
  return AppColors.purple;
}

/// Renders a CENTRE_CLASS avatar as a parameterised "uniform" Mochi:
/// the base Mochi body, a coloured band across its lower third, and a small
/// circular badge carrying the subject glyph with the class initials beneath.
///
/// This is deliberately a composed widget (not collectible character art) so
/// class avatars read as visually distinct from a child's own tutors.
class ClassUniformAvatar extends StatelessWidget {
  const ClassUniformAvatar({
    super.key,
    required this.appearance,
    required this.size,
  });

  final ClassAppearance appearance;
  final double size;

  @override
  Widget build(BuildContext context) {
    final bandColor = parseBandColor(appearance.bandColorHex);
    final glyph = classGlyphIcon(appearance.subjectGlyph);
    final initials = appearance.initials.trim();

    // Proportional sub-element sizes derived from the avatar size so the
    // uniform scales cleanly from a nav badge to the shop screen.
    final bandHeight = size * 0.22;
    final badgeSize = size * 0.42;
    final iconSize = badgeSize * 0.58;
    final initialsFontSize = size * 0.16;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Base Mochi body.
          Image.asset(
            MochiCharacter.mochi.assetPath,
            width: size,
            height: size,
            fit: BoxFit.contain,
          ),
          // 2. Coloured uniform band across the lower body.
          Align(
            alignment: const Alignment(0, 0.62),
            child: Container(
              width: size * 0.74,
              height: bandHeight,
              decoration: BoxDecoration(
                color: bandColor,
                borderRadius: BorderRadius.circular(bandHeight),
              ),
            ),
          ),
          // 3. Circular subject badge + initials, centred on the band.
          Align(
            alignment: const Alignment(0, 0.62),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: badgeSize,
                  height: badgeSize,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: bandColor, width: 1.5),
                  ),
                  child: Icon(glyph, size: iconSize, color: bandColor),
                ),
                if (initials.isNotEmpty) ...[
                  SizedBox(height: size * 0.02),
                  Text(
                    initials,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w800,
                      fontSize: initialsFontSize,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
