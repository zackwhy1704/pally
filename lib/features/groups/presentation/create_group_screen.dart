import 'package:flutter/material.dart';
import 'package:pally/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/pally_toast.dart';
import 'package:pally/features/groups/presentation/groups_view_model.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() =>
      _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final _nameCtrl = TextEditingController();
  String? _subject;
  bool _busy = false;

  static const _subjects = [
    'Maths',
    'Science',
    'English',
    'History',
    'Geography',
    'Art',
    'Music',
    'Coding',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final l = AppLocalizations.of(context);
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      PallyToast.error(context, l.groupNameHint);
      return;
    }
    setState(() => _busy = true);
    final group = await ref
        .read(groupListViewModelProvider.notifier)
        .create(name: name, subject: _subject);
    if (!mounted) return;
    setState(() => _busy = false);
    if (group != null) {
      PallyToast.success(context, l.groupCreated);
      // pushReplacement so back from the room returns to the list, not here.
      context.pushReplacement('/groups/detail/${group.id}');
    } else {
      PallyToast.error(context, l.groupCreateFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Text(l.groupNewTitle, style: AppTextStyles.title),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.groupNameLabel, style: AppTextStyles.label),
            const SizedBox(height: 6),
            TextField(
              controller: _nameCtrl,
              maxLength: 60,
              decoration: InputDecoration(
                counterText: '',
                hintText: l.groupNameExample,
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: AppColors.purple, width: 2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(l.groupSubjectOptional, style: AppTextStyles.label),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _subjects.map((s) {
                final on = _subject == s;
                return ChoiceChip(
                  label: Text(s),
                  selected: on,
                  selectedColor: AppColors.purpleL,
                  labelStyle: AppTextStyles.body.copyWith(
                      color: on ? AppColors.purple : AppColors.text2),
                  onSelected: (v) =>
                      setState(() => _subject = v ? s : null),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _busy ? null : _create,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.purple,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _busy
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text(l.groupCreate),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
