import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_sizing.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/adaptive_center.dart';
import 'package:pally/core/ui/pally_error_card.dart';
import 'package:pally/features/classroom/presentation/classroom_session_view_model.dart';
import 'package:pally/l10n/app_localizations.dart';

/// Code + nickname entry for a live classroom boss session. No persistent
/// identity is collected here — the nickname is screened server-side and,
/// once accepted, exists only for this session (see
/// ClassroomSessionViewModel/ClassroomEventBus).
class ClassroomJoinScreen extends ConsumerStatefulWidget {
  const ClassroomJoinScreen({super.key, required this.avatarId});

  final String avatarId;

  @override
  ConsumerState<ClassroomJoinScreen> createState() =>
      _ClassroomJoinScreenState();
}

class _ClassroomJoinScreenState extends ConsumerState<ClassroomJoinScreen> {
  final _codeController = TextEditingController();
  final _nicknameController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(classroomSessionViewModelProvider(widget.avatarId));

    ref.listen<ClassroomSessionState>(
        classroomSessionViewModelProvider(widget.avatarId), (previous, next) {
      if (next.joined && previous?.joined != true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.go('/avatar/${widget.avatarId}/classroom/battle');
          }
        });
      }
    });

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: Text(AppLocalizations.of(context).classroomJoinTitle,
            style: AppTextStyles.title),
        centerTitle: true,
      ),
      // AdaptiveCenter is ALREADY a scrollable (SafeArea + SingleChildScrollView
      // + IntrinsicHeight internally) — it must be the outermost/sole scroll
      // wrapper; nesting it inside another SafeArea/SingleChildScrollView
      // gives it infinite height and crashes layout.
      body: AdaptiveCenter(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(AppLocalizations.of(context).classroomJoinCodeLabel,
                style: AppTextStyles.label.copyWith(color: AppColors.text2)),
            const SizedBox(height: AppSpacing.xs),
            TextField(
              controller: _codeController,
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
              style: AppTextStyles.title,
              decoration: const InputDecoration(counterText: ''),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(AppLocalizations.of(context).classroomNicknameLabel,
                style: AppTextStyles.label.copyWith(color: AppColors.text2)),
            const SizedBox(height: AppSpacing.xs),
            TextField(
              controller: _nicknameController,
              maxLength: 24,
              decoration: InputDecoration(
                counterText: '',
                errorText: state.nicknameRejectedMessage,
                errorMaxLines: 3,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (state.error != null) ...[
              PallyErrorCard(message: state.error!.userMessage),
              const SizedBox(height: AppSpacing.sm),
            ],
            SizedBox(
              height: AppSizing.buttonHeight,
              child: FilledButton(
                onPressed: state.isJoining ? null : _submit,
                style:
                    FilledButton.styleFrom(backgroundColor: AppColors.purple),
                child: state.isJoining
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(AppLocalizations.of(context).classroomJoinCta),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    final code = _codeController.text.trim().toUpperCase();
    final nickname = _nicknameController.text.trim();
    if (code.isEmpty || nickname.isEmpty) return;
    ref
        .read(classroomSessionViewModelProvider(widget.avatarId).notifier)
        .join(code, nickname);
  }
}
