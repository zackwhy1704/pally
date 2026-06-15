import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/app/router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/utils/logger.dart';

part 'no_notes_cta.g.dart';

/// Whether an avatar is a centre-managed class (CENTRE_CLASS) vs a child's own
/// personal Mochi. Students can upload to their personal Mochi but NOT to a
/// centre class — only the teacher/centre adds materials there.
///
/// Resolves from `GET /avatars/{id}` (the `kind` field). Defaults to `false`
/// (personal) on any error so the worst case is showing the upload button to a
/// personal avatar, never hiding it from one who needs it.
@riverpod
Future<bool> avatarIsCentreClass(Ref ref, String avatarId) async {
  final dio = ref.read(dioProvider);
  try {
    final res = await dio.get<dynamic>('/api/v1/avatars/$avatarId');
    final data = res.data;
    final map = (data is Map && data['data'] is Map)
        ? Map<String, dynamic>.from(data['data'] as Map)
        : <String, dynamic>{};
    final kind = (map['kind'] as String?)?.toUpperCase() ?? 'PERSONAL';
    return kind == 'CENTRE_CLASS';
  } catch (e, st) {
    appLog.e('[NoNotesCta] could not resolve avatar kind for $avatarId',
        error: e, stackTrace: st);
    return false;
  }
}

/// Shared "there are no notes yet" call-to-action that branches on avatar type:
///
/// * **Personal Mochi** → the child owns the knowledge base, so show the
///   [personalDescription] and an "Upload notes" button into the upload flow.
/// * **Centre class** → the child can't upload; show a friendly reminder to ask
///   their teacher to add materials, and NO upload button.
///
/// Use this anywhere a feature is empty because the knowledge base is empty
/// (flashcards, quiz, brain, teach-mochi, chat …) so the individual-vs-centre
/// rule stays consistent everywhere.
class NoNotesCta extends ConsumerWidget {
  const NoNotesCta({
    required this.avatarId,
    required this.personalDescription,
    this.personalButtonLabel = 'Upload notes',
    super.key,
  });

  final String avatarId;
  final String personalDescription;
  final String personalButtonLabel;

  static const _centreReminder =
      "This class doesn't have notes yet. Ask your teacher to add some so "
      'Mochi can help! 📚';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // null = still resolving the avatar kind. true = centre class. false =
    // personal. We only ever show the upload button once we KNOW it's personal,
    // so a centre student never flashes an "Upload notes" button mid-load.
    final isCentre = ref.watch(avatarIsCentreClassProvider(avatarId)).valueOrNull;

    if (isCentre == true) {
      return Text(
        _centreReminder,
        style: AppTextStyles.body.copyWith(color: AppColors.text2),
        textAlign: TextAlign.center,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          personalDescription,
          style: AppTextStyles.body.copyWith(color: AppColors.text2),
          textAlign: TextAlign.center,
        ),
        if (isCentre == false) ...[
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: () => UploadRoute(avatarId: avatarId).push(context),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.purple,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.upload_file_rounded, size: 18),
            label: Text(personalButtonLabel),
          ),
        ],
      ],
    );
  }
}
