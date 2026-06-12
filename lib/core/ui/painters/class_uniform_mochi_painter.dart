import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/ui/painters/character_painter.dart';
import 'package:pally/shared/models/avatar.dart';
import 'package:pally/shared/models/mochi_character.dart';

/// Maps a backend [subjectGlyph] key to a Material icon for the class tag.
///
/// Unknown or missing keys resolve to a neutral book icon so a stale/new
/// backend value never crashes or renders a blank tag.
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
/// avatar always renders a sensible ring + tag.
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

/// Renders a CENTRE_CLASS avatar by decorating the base character AROUND its
/// edges — never on top of it. The base Mochi (or any character) renders
/// pixel-identical to a personal avatar of the same character; the class
/// identity is conveyed by:
///
///   • a thin coloured **ring** around the avatar (Instagram-story style), and
///   • a small circular **class tag** anchored bottom-right, outside the body,
///     carrying the subject glyph (and initials only at larger sizes).
///
/// This "name tag around" metaphor fits every body shape and every size with
/// zero fitting, and works for both vector-painter and image-asset characters.
class ClassUniformAvatar extends StatelessWidget {
  const ClassUniformAvatar({
    super.key,
    required this.appearance,
    required this.size,
    this.character = MochiCharacter.mochi,
  });

  final ClassAppearance appearance;
  final double size;

  /// The base character to render untouched beneath the ring + tag.
  final MochiCharacter character;

  /// Below this size, initials are illegible — the tag shows the glyph only.
  static const double _initialsMinSize = 64;

  @override
  Widget build(BuildContext context) {
    final ringColor = parseBandColor(appearance.bandColorHex);
    final glyph = classGlyphIcon(appearance.subjectGlyph);
    final initials = appearance.initials.trim();
    final showInitials = initials.isNotEmpty && size >= _initialsMinSize;

    // Ring stroke scales gently with size, clamped to a crisp 3–4px band.
    final ringStroke = (size * 0.035).clamp(3.0, 4.0);
    // Class tag is at most 30% of the avatar, anchored bottom-right.
    final tagSize = size * 0.30;
    final glyphSize = tagSize * 0.56;
    final initialsFontSize = tagSize * 0.42;

    // The base character renders inside the ring, slightly inset so the ring
    // sits AROUND it rather than clipping the body.
    final bodyInset = ringStroke + size * 0.01;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Coloured ring AROUND the avatar — never over the body.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ringColor, width: ringStroke),
              ),
            ),
          ),
          // 2. Base character, untouched, inset within the ring.
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.all(bodyInset),
              child: Center(
                child: CharacterWidget(
                  character: character,
                  size: size - bodyInset * 2,
                ),
              ),
            ),
          ),
          // 3. Corner class tag — bottom-right, outside the body bounds.
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: tagSize,
              height: tagSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: ringColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: ringStroke * 0.6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: showInitials
                  ? Text(
                      initials,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w800,
                        fontSize: initialsFontSize,
                        color: Colors.white,
                        height: 1,
                      ),
                    )
                  : Icon(glyph, size: glyphSize, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
