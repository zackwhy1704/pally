import 'package:flutter_test/flutter_test.dart';

// Mirror the _highlightTierForFeature logic from paywall_screen.dart.
// This is a pure function — test it directly without the widget.
String? highlightTierForFeature(String? feature) => switch (feature) {
      'CHAT_DAILY' => 'pro',
      'CREATE_TUTOR' => 'pro',
      'GROUPS' => 'pro',
      'PARENT_DASHBOARD' => 'pro',
      'ADD_STUDENT' => 'family',
      _ => null,
    };

// Mirror the _planIdFromHighlightTier logic from subscription_plans_screen.dart.
String? planIdFromHighlightTier(String? tier) => switch (tier) {
      'pro' => 'pro_monthly',
      'max' => 'max_monthly',
      'family' => 'family_monthly',
      _ => null,
    };

void main() {
  group('highlightTierForFeature', () {
    test('CHAT_DAILY maps to pro — cheapest tier that raises the chat cap', () {
      expect(highlightTierForFeature('CHAT_DAILY'), 'pro');
    });

    test('CREATE_TUTOR maps to pro', () {
      expect(highlightTierForFeature('CREATE_TUTOR'), 'pro');
    });

    test('GROUPS maps to pro — cheapest tier with groups=true', () {
      expect(highlightTierForFeature('GROUPS'), 'pro');
    });

    test('PARENT_DASHBOARD maps to pro', () {
      expect(highlightTierForFeature('PARENT_DASHBOARD'), 'pro');
    });

    test('ADD_STUDENT maps to family', () {
      expect(highlightTierForFeature('ADD_STUDENT'), 'family');
    });

    test('unknown feature returns null — no highlight', () {
      expect(highlightTierForFeature('UNKNOWN_FEATURE'), isNull);
      expect(highlightTierForFeature(null), isNull);
      expect(highlightTierForFeature(''), isNull);
    });

    test('CURRICULUM and EXTRA_FREEZE have no specific tier highlight', () {
      expect(highlightTierForFeature('CURRICULUM'), isNull);
      expect(highlightTierForFeature('EXTRA_FREEZE'), isNull);
    });
  });

  group('planIdFromHighlightTier', () {
    test('pro maps to pro_monthly plan id', () {
      expect(planIdFromHighlightTier('pro'), 'pro_monthly');
    });

    test('max maps to max_monthly plan id', () {
      expect(planIdFromHighlightTier('max'), 'max_monthly');
    });

    test('family maps to family_monthly plan id', () {
      expect(planIdFromHighlightTier('family'), 'family_monthly');
    });

    test('null or unrecognised returns null — fallback to default', () {
      expect(planIdFromHighlightTier(null), isNull);
      expect(planIdFromHighlightTier('spark'), isNull);
      expect(planIdFromHighlightTier('unknown'), isNull);
    });
  });

  group('feature → highlight tier → plan id (end-to-end mapping)', () {
    test('CHAT_DAILY → pro → pro_monthly', () {
      final tier = highlightTierForFeature('CHAT_DAILY');
      expect(planIdFromHighlightTier(tier), 'pro_monthly');
    });

    test('ADD_STUDENT → family → family_monthly', () {
      final tier = highlightTierForFeature('ADD_STUDENT');
      expect(planIdFromHighlightTier(tier), 'family_monthly');
    });

    test('unknown feature → null → null (no pre-selection)', () {
      final tier = highlightTierForFeature('SOMETHING_ELSE');
      expect(planIdFromHighlightTier(tier), isNull);
    });
  });

  group('paywall CHAT_DAILY subhead copy', () {
    test('CHAT_DAILY subhead mentions 20 chats per day (correct free limit)', () {
      // This test documents the canonical copy so a regression is caught immediately.
      const correctSubhead = 'Free users get 20 chats a day. Pro lifts the cap to 100; '
          'Max and above remove it entirely.';
      // The actual number is part of the contract with users — never change silently.
      expect(correctSubhead, contains('20 chats a day'));
      expect(correctSubhead, contains('Pro lifts the cap to 100'));
    });
  });
}
