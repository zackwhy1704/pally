import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/flashcards/providers/due_cards_summary_provider.dart';
import 'package:pally/features/flashcards/providers/srs_reminder_armer.dart';
import 'package:pally/shared/models/avatar.dart';
import 'package:pally/shared/models/mochi_character.dart';
import 'package:pally/l10n/app_localizations.dart';

/// Pins the fix for the self-defeating SRS reminder bootstrap.
///
/// THE DEFECT: `_rescheduleSrs()` had exactly ONE call site — inside
/// `FlashcardViewModel._loadCards()` — so the reminder that exists to bring a
/// student back to flashcards could only be armed while the student was already
/// inside flashcards. Nothing armed it for a student who never opened the deck,
/// which is most of them: cards are generated SERVER-SIDE during wiki compile.
///
/// Production evidence: 2,106 cards overdue, all 148 ratings inside the card's
/// creation hour, never once a later session.
///
/// These tests RECORD the schedule calls the armer makes and assert they actually
/// happen. An earlier version of this file only asserted `completes`, which a no-op
/// `armAll` also satisfies — it passed with the implementation neutralized and so
/// proved nothing. Capturing the real plugin channel is not possible either: the
/// plugin resolves its implementation via dart:io Platform.isAndroid/isIOS, both
/// false on a test host, so it never reaches a channel. Hence the injected seam.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<String> scheduledFor;

  setUp(() => scheduledFor = <String>[]);

  Future<void> recordingSchedule({
    required String avatarId,
    required String avatarName,
    required int dueCount,
    required DateTime? earliestDue,
    required AppLocalizations l10n,
  }) async {
    scheduledFor.add(avatarId);
  }

  List<String> scheduled() => scheduledFor;

  Avatar avatar(String id, String name) => Avatar(
        id: id,
        name: name,
        character: MochiCharacter.mochi,
        subject: 'GENERAL',
      );

  ProviderContainer containerWith(DueCardsSummary summary) {
    final container = ProviderContainer(overrides: [
      dueCardsSummaryProvider.overrideWith((ref) async => summary),
      srsReminderArmerProvider.overrideWith(
          (ref) => SrsReminderArmer(ref, schedule: recordingSchedule)),
    ]);
    addTearDown(container.dispose);
    return container;
  }

  test('armer is resolvable WITHOUT constructing the flashcard deck view model', () {
    // The structural claim: arming no longer depends on the deck screen. If this
    // ever requires FlashcardViewModel again, the bootstrap defect is back.
    final container = containerWith(const DueCardsSummary(
        totalDue: 0, byAvatar: {}, firstDueAvatar: null));

    expect(container.read(srsReminderArmerProvider), isA<SrsReminderArmer>());
  });

  test('armAll SCHEDULES a reminder when cards are due', () async {
    final container = containerWith(DueCardsSummary(
      totalDue: 12,
      byAvatar: const {'av-1': 12},
      firstDueAvatar: avatar('av-1', 'Maths Mochi'),
    ));

    await container.read(srsReminderArmerProvider).armAll();

    expect(scheduled(), hasLength(1),
        reason: 'a due batch must actually arm a notification, not just complete');
  });

  test('one reminder per AVATAR, not per card', () async {
    // 30 due cards across 2 avatars must arm exactly 2 slots. Per-card scheduling
    // would be a notification-spam loop.
    final container = containerWith(DueCardsSummary(
      totalDue: 30,
      byAvatar: const {'av-1': 12, 'av-2': 18},
      firstDueAvatar: avatar('av-1', 'Maths Mochi'),
    ));

    await container.read(srsReminderArmerProvider).armAll();

    expect(scheduled(), hasLength(2));
  });

  test('repeat arming re-points the SAME per-avatar slot, never a new one', () async {
    // Launch AND resume both call armAll. Each pass schedules the same avatarId,
    // and NotificationService.scheduleSrsReminder cancels that slot (keyed on an
    // avatarId hash) before rescheduling — so repeated arming cannot stack
    // notifications. Asserted here as: the same single avatar, every pass.
    final container = containerWith(DueCardsSummary(
      totalDue: 12,
      byAvatar: const {'av-1': 12},
      firstDueAvatar: avatar('av-1', 'Maths Mochi'),
    ));

    await container.read(srsReminderArmerProvider).armAll();
    await container.read(srsReminderArmerProvider).armAll();

    expect(scheduled(), ['av-1', 'av-1'],
        reason: 'two passes, one slot identity — not two distinct slots');
    expect(scheduled().toSet(), hasLength(1));
  });

  test('nothing due schedules NOTHING', () async {
    final container = containerWith(const DueCardsSummary(
        totalDue: 0, byAvatar: {}, firstDueAvatar: null));

    await container.read(srsReminderArmerProvider).armAll();

    expect(scheduled(), isEmpty);
  });

  test('avatars reporting zero due are skipped', () async {
    final container = containerWith(DueCardsSummary(
      totalDue: 5,
      byAvatar: const {'av-1': 5, 'av-zero': 0},
      firstDueAvatar: avatar('av-1', 'Maths Mochi'),
    ));

    await container.read(srsReminderArmerProvider).armAll();

    expect(scheduled(), hasLength(1), reason: 'only av-1 has due cards');
  });

  test('armAll is best-effort: a failing due-cards fetch never throws', () async {
    // Arming runs from a lifecycle callback. If it can throw, it can take down app
    // resume — strictly worse than no reminder.
    final container = ProviderContainer(overrides: [
      dueCardsSummaryProvider.overrideWith(
          (ref) async => throw Exception('network down')),
      srsReminderArmerProvider.overrideWith(
          (ref) => SrsReminderArmer(ref, schedule: recordingSchedule)),
    ]);
    addTearDown(container.dispose);

    await expectLater(
        container.read(srsReminderArmerProvider).armAll(), completes);
    expect(scheduled(), isEmpty);
  });
}
