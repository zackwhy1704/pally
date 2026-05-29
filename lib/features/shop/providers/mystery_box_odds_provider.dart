import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/utils/logger.dart';

part 'mystery_box_odds_provider.g.dart';

/// One row in the "FYI — Probability" card.
@immutable
class MysteryBoxOdds {
  const MysteryBoxOdds({
    required this.character,
    required this.name,
    required this.rarity,
    required this.percent,
  });

  final String character;
  final String name;
  final String rarity; // COMMON | RARE | SECRET
  final int percent;
}

/// Reads /shop/open-box/odds — the rates come straight from the live
/// catalog so adding/removing a Mochi updates the UI without a deploy.
/// Falls back to the spec's static numbers on error so the kid never
/// sees a blank box.
@riverpod
class MysteryBoxOddsNotifier extends _$MysteryBoxOddsNotifier {
  @override
  Future<List<MysteryBoxOdds>> build() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio
          .get<Map<String, dynamic>>('/api/v1/shop/open-box/odds');
      final list = (response.data?['odds'] as List?) ?? const [];
      return list
          .whereType<Map<String, dynamic>>()
          .map((m) => MysteryBoxOdds(
                character: (m['character'] as String?) ?? '',
                name: (m['name'] as String?) ?? '',
                rarity: (m['rarity'] as String?) ?? 'COMMON',
                percent: (m['percent'] as num?)?.toInt() ?? 0,
              ))
          .toList();
    } catch (e) {
      appLog.d('[Odds] fetch failed: $e — using fallback');
      // Spec defaults: 6×15% + 8% + 2% = 100. If a catalog change ever
      // makes these wrong, the live endpoint corrects them immediately.
      return const [
        MysteryBoxOdds(character: 'PENCIL',     name: 'Pencil',     rarity: 'COMMON', percent: 15),
        MysteryBoxOdds(character: 'SCIENCE',    name: 'Science',    rarity: 'COMMON', percent: 15),
        MysteryBoxOdds(character: 'PE',         name: 'PE',         rarity: 'COMMON', percent: 15),
        MysteryBoxOdds(character: 'ART',        name: 'Art',        rarity: 'COMMON', percent: 15),
        MysteryBoxOdds(character: 'LUNCHBOX',   name: 'Lunchbox',   rarity: 'COMMON', percent: 15),
        MysteryBoxOdds(character: 'LIBRARY',    name: 'Library',    rarity: 'COMMON', percent: 15),
        MysteryBoxOdds(character: 'HEADMASTER', name: 'Headmaster', rarity: 'RARE',   percent: 8),
        MysteryBoxOdds(character: 'GOLDSTAR',   name: 'Gold Star',  rarity: 'SECRET', percent: 2),
      ];
    }
  }
}
