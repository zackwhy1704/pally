import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/core/services/notification_service.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/features/flashcards/providers/due_cards_summary_provider.dart';
import 'package:pally/core/i18n/locale_controller.dart';
import 'package:pally/l10n/app_localizations.dart';

/// Arms the SM-2 review reminder from OUTSIDE the flashcard deck screen.
///
/// THE DEFECT THIS FIXES: `_rescheduleSrs()` had exactly one call site — inside
/// `FlashcardViewModel._loadCards()` — so the reminder whose entire purpose is to
/// bring a student BACK to flashcards could only ever be armed while the student
/// was already inside flashcards. A self-defeating bootstrap: nothing armed it for
/// a student who never opened the deck, and nothing re-armed it after a reinstall.
///
/// Production evidence: all 148 ratings landed inside the card's creation hour and
/// never once in a later session; 2,106 cards sit overdue.
///
/// It also could not have worked for the path that created most cards — flashcards
/// are generated SERVER-SIDE during wiki compile
/// (`ClaudeFlashcardGenerator` via `WikiPagePersistenceService`), so cards exist for
/// students who have never opened the deck even once. App launch and app resume are
/// the only points every student genuinely passes through.
///
/// Idempotent by construction: [NotificationService.scheduleSrsReminder] cancels the
/// previous slot before scheduling, keyed on a hash of avatarId — ONE reminder per
/// avatar per due batch, never one per card. Calling this repeatedly (launch AND
/// resume) re-points the same slot rather than stacking notifications.
/// The scheduling call this armer makes. Injectable ONLY so the arming logic
/// (which avatars, how many slots, skip-zero) is testable: the real
/// flutter_local_notifications plugin resolves its implementation via dart:io
/// `Platform.isAndroid`/`isIOS`, which are false on a test host, so the plugin
/// cannot be exercised in unit tests at all. Production always uses the default.
typedef SrsScheduleFn = Future<void> Function({
  required String avatarId,
  required String avatarName,
  required int dueCount,
  required DateTime? earliestDue,
  required AppLocalizations l10n,
});

class SrsReminderArmer {
  SrsReminderArmer(this._ref, {SrsScheduleFn? schedule})
      : _schedule = schedule ?? NotificationService.scheduleSrsReminder;

  final Ref _ref;
  final SrsScheduleFn _schedule;

  /// Arms one reminder for each avatar that currently has due cards, and clears
  /// the slot for avatars that have none.
  ///
  /// Best-effort throughout: this is a background nicety and must never surface an
  /// error or block a lifecycle callback. Every failure path logs and returns.
  Future<void> armAll() async {
    try {
      final summary = await _ref.read(dueCardsSummaryProvider.future);
      if (summary.byAvatar.isEmpty) {
        appLog.d('[SrsArmer] nothing due — no reminders armed');
        return;
      }

      final l10n = lookupAppLocalizations(_ref.read(localeControllerProvider));

      for (final entry in summary.byAvatar.entries) {
        final avatarId = entry.key;
        final dueCount = entry.value;
        if (dueCount <= 0) continue;

        final name = _avatarName(avatarId, l10n);
        // Cards are ALREADY due, so pass now — scheduleSrsReminder's overdue
        // branch defers to 16:00 local rather than firing at launch time, which
        // is what stops this from becoming an app-open notification.
        await _schedule(
          avatarId: avatarId,
          avatarName: name,
          dueCount: dueCount,
          earliestDue: DateTime.now(),
          l10n: l10n,
        );
      }
      appLog.i('[SrsArmer] armed ${summary.byAvatar.length} reminder(s), '
          'totalDue=${summary.totalDue}');
    } catch (e, st) {
      appLog.w('[SrsArmer] arming failed (non-fatal)', error: e, stackTrace: st);
    }
  }

  /// Resolves a display name from the already-loaded avatar list; falls back to
  /// the generic mascot label rather than failing the whole arm pass.
  String _avatarName(String avatarId, AppLocalizations l10n) {
    try {
      final summary = _ref.read(dueCardsSummaryProvider).valueOrNull;
      final first = summary?.firstDueAvatar;
      if (first != null && first.id == avatarId) return first.name;
    } catch (_) {
      // fall through to the default
    }
    return l10n.mascotName;
  }
}

final srsReminderArmerProvider =
    Provider<SrsReminderArmer>((ref) => SrsReminderArmer(ref));
