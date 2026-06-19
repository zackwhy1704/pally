import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pally/features/centre/centre_mode.dart';
import 'package:pally/shared/models/avatar.dart';
import 'package:pally/shared/models/mochi_character.dart';

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

class _FakeRef extends Fake implements WidgetRef {}

void main() {
  group('CentreModeConfig', () {
    test('inactive for personal avatar', () {
      final config = resolveCentreMode(_FakeRef(), _avatar());
      expect(config.active, isFalse);
      expect(config.canUpload, isTrue);
      expect(config.canTeach, isTrue);
      expect(config.canDelete, isTrue);
      expect(config.closedBook, isFalse);
    });

    test('active when centreManaged=true, uses server brand name', () {
      final avatar = _avatar(
        centreManaged: true,
        centreBrandName: 'ABC Mochi',
        centreAccentColor: '#00BBA4',
        centreId: 'centre-1',
      );
      final config = resolveCentreMode(_FakeRef(), avatar);
      expect(config.active, isTrue);
      expect(config.brandName, 'ABC Mochi');
      expect(config.accentColorHex, '#00BBA4');
      expect(config.centreId, 'centre-1');
      expect(config.canUpload, isFalse);
      expect(config.canTeach, isFalse);
      expect(config.canDelete, isFalse);
      expect(config.closedBook, isTrue);
    });

    test('active for a centre CLASS avatar even when centreManaged=false', () {
      final avatar = _avatar(kind: AvatarKind.centreClass);
      final config = resolveCentreMode(_FakeRef(), avatar);
      expect(config.active, isTrue);
      expect(config.canUpload, isFalse);
      expect(config.canTeach, isFalse);
      expect(config.canDelete, isFalse);
      expect(config.closedBook, isTrue);
    });

    test('personal avatar (kind=personal, centreManaged=false) stays inactive', () {
      final config = resolveCentreMode(_FakeRef(), _avatar(kind: AvatarKind.personal));
      expect(config.active, isFalse);
      expect(config.canUpload, isTrue);
    });

    test('falls back to default brand when centreBrandName is null', () {
      final avatar = _avatar(centreManaged: true);
      final config = resolveCentreMode(_FakeRef(), avatar);
      expect(config.brandName, 'ABC Mochi');
    });

    test('centreManaged=true activates correctly', () {
      final avatar = _avatar(centreManaged: true, centreBrandName: 'XYZ Mochi');
      final config = resolveCentreMode(_FakeRef(), avatar);
      expect(config.active, isTrue);
      expect(config.brandName, 'XYZ Mochi');
    });
  });
}
