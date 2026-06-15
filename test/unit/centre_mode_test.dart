import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pally/core/services/feature_flags.dart';
import 'package:pally/features/centre/centre_mode.dart';
import 'package:pally/shared/models/avatar.dart';
import 'package:pally/shared/models/mochi_character.dart';

// ── Minimal Avatar factory ────────────────────────────────────────────────────

Avatar _avatar({
  bool centreManaged = false,
  String? centreBrandName,
  String? centreAccentColor,
  String? centreId,
  AvatarKind kind = AvatarKind.personal,
}) =>
    Avatar(
      id: 'test-id',
      name: 'Test Mochi',
      character: MochiCharacter.mochi,
      subject: 'MATHS',
      centreManaged: centreManaged,
      centreBrandName: centreBrandName,
      centreAccentColor: centreAccentColor,
      centreId: centreId,
      kind: kind,
    );

// ── Fake WidgetRef ────────────────────────────────────────────────────────────
// We drive the flag map and demo override manually; we don't need a full
// ProviderScope for these pure-logic tests.

class _FakeRef extends Fake implements WidgetRef {
  _FakeRef({required this.isAdmin, required this.demoOn});
  final bool isAdmin;
  final bool demoOn;

  @override
  T watch<T>(ProviderListenable<T> provider) {
    if (provider == centreModeDemoOverrideProvider) return demoOn as T;
    if (provider == featureFlagsProvider) {
      return AsyncValue.data({FeatureFlags.isAdmin: isAdmin}) as T;
    }
    throw UnimplementedError('Unexpected provider: $provider');
  }
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('CentreModeConfig', () {
    test('inactive when centreManaged=false and no admin override', () {
      final ref = _FakeRef(isAdmin: false, demoOn: false);
      final config = resolveCentreMode(ref, _avatar());
      expect(config.active, isFalse);
      expect(config.canUpload, isTrue);
      expect(config.canTeach, isTrue);
      expect(config.canDelete, isTrue);
      expect(config.closedBook, isFalse);
    });

    test('active when centreManaged=true, uses server brand name', () {
      final ref = _FakeRef(isAdmin: false, demoOn: false);
      final avatar = _avatar(
        centreManaged: true,
        centreBrandName: 'ABC Mochi',
        centreAccentColor: '#00BBA4',
        centreId: 'centre-1',
      );
      final config = resolveCentreMode(ref, avatar);
      expect(config.active, isTrue);
      expect(config.brandName, 'ABC Mochi');
      expect(config.accentColorHex, '#00BBA4');
      expect(config.centreId, 'centre-1');
      expect(config.canUpload, isFalse);
      expect(config.canTeach, isFalse);
      expect(config.canDelete, isFalse);
      expect(config.closedBook, isTrue);
    });

    test('inactive for personal avatar even when admin+demo (demo = extra card, not name change)', () {
      // resolveCentreMode only checks centreManaged. The admin demo toggle
      // shows an EXTRA fake card (showDemoCentreCard) but never changes an
      // existing personal avatar's mode.
      final ref = _FakeRef(isAdmin: true, demoOn: true);
      final config = resolveCentreMode(ref, _avatar());
      expect(config.active, isFalse);
    });

    test('showDemoCentreCard true for admin with toggle on', () {
      final ref = _FakeRef(isAdmin: true, demoOn: true);
      expect(showDemoCentreCard(ref), isTrue);
    });

    test('showDemoCentreCard false for non-admin even with toggle on', () {
      final ref = _FakeRef(isAdmin: false, demoOn: true);
      expect(showDemoCentreCard(ref), isFalse);
    });

    test('showDemoCentreCard false for admin with toggle off', () {
      final ref = _FakeRef(isAdmin: true, demoOn: false);
      expect(showDemoCentreCard(ref), isFalse);
    });

    test('inactive for non-admin even if demo override is on', () {
      final ref = _FakeRef(isAdmin: false, demoOn: true);
      final config = resolveCentreMode(ref, _avatar());
      expect(config.active, isFalse);
    });

    test('inactive for admin with demo override off', () {
      final ref = _FakeRef(isAdmin: true, demoOn: false);
      final config = resolveCentreMode(ref, _avatar());
      expect(config.active, isFalse);
    });

    test('centreManaged=true beats demo-off for admin', () {
      final ref = _FakeRef(isAdmin: true, demoOn: false);
      final avatar = _avatar(centreManaged: true, centreBrandName: 'XYZ Mochi');
      final config = resolveCentreMode(ref, avatar);
      expect(config.active, isTrue);
      expect(config.brandName, 'XYZ Mochi');
    });

    test('active for a centre CLASS avatar even when centreManaged=false', () {
      // A student's per-class avatar (and the class corpus) is identified by
      // kind=CENTRE_CLASS, NOT the legacy centreManaged flag. It must still lock
      // down uploads/teach/delete so students can't add notes to a class.
      final ref = _FakeRef(isAdmin: false, demoOn: false);
      final avatar = _avatar(kind: AvatarKind.centreClass);
      final config = resolveCentreMode(ref, avatar);
      expect(config.active, isTrue);
      expect(config.canUpload, isFalse);
      expect(config.canTeach, isFalse);
      expect(config.canDelete, isFalse);
      expect(config.closedBook, isTrue);
    });

    test('personal avatar (kind=personal, centreManaged=false) stays inactive', () {
      final ref = _FakeRef(isAdmin: false, demoOn: false);
      final config = resolveCentreMode(ref, _avatar(kind: AvatarKind.personal));
      expect(config.active, isFalse);
      expect(config.canUpload, isTrue);
    });

    test('falls back to default brand when centreBrandName is null', () {
      final ref = _FakeRef(isAdmin: false, demoOn: false);
      final avatar = _avatar(centreManaged: true); // no brand name
      final config = resolveCentreMode(ref, avatar);
      expect(config.brandName, 'ABC Mochi');
    });
  });
}
