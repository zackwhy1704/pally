import 'dart:io';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_sizing.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/features/onboarding/presentation/direct_onboarding_view_model.dart';
import 'package:pally/app/router.dart';

class DirectOnboardingScreen extends ConsumerStatefulWidget {
  const DirectOnboardingScreen({super.key});

  @override
  ConsumerState<DirectOnboardingScreen> createState() =>
      _DirectOnboardingScreenState();
}

class _DirectOnboardingScreenState
    extends ConsumerState<DirectOnboardingScreen> {
  // Form data retained across steps.
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _parentEmailCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _parentEmailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(directOnboardingViewModelProvider);

    ref.listen<DirectOnboardingState>(
      directOnboardingViewModelProvider,
      (prev, next) {
        if (next.error != null && next.error != prev?.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.error!,
                  style:
                      AppTextStyles.bodySmall.copyWith(color: Colors.white)),
              backgroundColor: AppColors.coral,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      },
    );

    final notifier = ref.read(directOnboardingViewModelProvider.notifier);

    // Under-13 waiting for parental consent — overrides the normal step flow.
    if (vm.awaitingConsent) {
      return PopScope(
        canPop: false,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: AppColors.bg,
          body: SafeArea(
            child: _ParentConsentPending(
              maskedParentEmail: vm.maskedParentEmail ?? '',
            ),
          ),
        ),
      );
    }

    return PopScope(
      // Step 1: allow system back (returns to sign-in).
      // Step 2: intercept and go back to step 1.
      // Step 3: block — account already created, user uses "Skip for now".
      canPop: vm.step == 1,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && vm.step == 2) notifier.goToStep(1);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: Column(
            children: [
              _StepProgressBar(
                step: vm.step,
                onBack: vm.step == 2 ? () => notifier.goToStep(1) : null,
              ),
              Expanded(
                child: switch (vm.step) {
                  1 => _Step1SignUp(
                      nameCtrl: _nameCtrl,
                      emailCtrl: _emailCtrl,
                      passCtrl: _passCtrl,
                      parentEmailCtrl: _parentEmailCtrl,
                    ),
                  2 => _Step2SubjectLevel(
                      nameCtrl: _nameCtrl,
                      emailCtrl: _emailCtrl,
                      passCtrl: _passCtrl,
                    ),
                  3 => _Step3Upload(
                      avatarId: vm.avatarId,
                      uploadStage: vm.uploadStage,
                      firstModuleId: vm.firstModuleId,
                      firstModuleTitle: vm.firstModuleTitle,
                    ),
                  _ => const SizedBox.shrink(),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Progress bar ──────────────────────────────────────────────────────────────

class _StepProgressBar extends StatelessWidget {
  const _StepProgressBar({required this.step, this.onBack});
  final int step;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: onBack != null
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                    color: AppColors.text1,
                    onPressed: onBack,
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 40, minHeight: 40),
                  )
                : null,
          ),
          Expanded(
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: step / 3,
                    minHeight: 6,
                    backgroundColor: AppColors.outline,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.purple),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Step $step of 3',
                  style: AppTextStyles.caption.copyWith(color: AppColors.text2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 40), // mirror back button for symmetry
        ],
      ),
    );
  }
}

// ── Step 1: Sign up ──────────────────────────────────────────────────────────

class _Step1SignUp extends ConsumerStatefulWidget {
  const _Step1SignUp({
    required this.nameCtrl,
    required this.emailCtrl,
    required this.passCtrl,
    required this.parentEmailCtrl,
  });

  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final TextEditingController parentEmailCtrl;

  @override
  ConsumerState<_Step1SignUp> createState() => _Step1SignUpState();
}

class _Step1SignUpState extends ConsumerState<_Step1SignUp> {
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;

  void _next() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final notifier =
        ref.read(directOnboardingViewModelProvider.notifier);
    final isUnder13 =
        ref.read(directOnboardingViewModelProvider).isUnder13;
    if (isUnder13 == null) {
      // Force user to select an age group before proceeding.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select your age group to continue.',
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.coral,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    if (isUnder13) {
      notifier.setParentEmail(widget.parentEmailCtrl.text.trim());
    }
    notifier.goToStep(2);
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(directOnboardingViewModelProvider);
    final isUnder13 = vm.isUnder13;
    final notifier = ref.read(directOnboardingViewModelProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Form(
        key: _formKey,
        onChanged: () => setState(() {}),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.lg),
            // Mochi mascot
            Center(
              child: Image.asset(
                'assets/images/mochi.png',
                width: AppSizing.heroMochiSize,
                height: AppSizing.heroMochiSize,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Create your account',
              style: AppTextStyles.heading1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Mochi will become your personal study buddy.',
              style: AppTextStyles.body.copyWith(color: AppColors.text2),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            _Field(
              label: 'Name',
              hint: 'Your name',
              controller: widget.nameCtrl,
              textInputAction: TextInputAction.next,
              validator: (v) {
                if (v == null || v.trim().length < 2) {
                  return 'Name must be at least 2 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            _Field(
              label: 'Email',
              hint: 'your@email.com',
              controller: widget.emailCtrl,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (v) {
                if (v == null || !v.contains('@') || !v.contains('.')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            _Field(
              label: 'Password',
              hint: 'At least 8 characters',
              controller: widget.passCtrl,
              obscure: _obscure,
              textInputAction: TextInputAction.done,
              suffix: IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.text3,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
              validator: (v) {
                if (v == null || v.length < 8) {
                  return 'Password must be at least 8 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            // Age group selection — required for legal consent.
            Text(
              'Age group',
              style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.xs),
            _AgeGroupTile(
              label: 'I am 13 or older',
              selected: isUnder13 == false,
              onTap: () => notifier.setAgeGroup(isUnder13: false),
            ),
            const SizedBox(height: AppSpacing.xs),
            _AgeGroupTile(
              label: 'I am under 13',
              selected: isUnder13 == true,
              onTap: () => notifier.setAgeGroup(isUnder13: true),
            ),
            // Parent email field — only shown for under-13.
            if (isUnder13 == true) ...[
              const SizedBox(height: AppSpacing.md),
              _Field(
                label: "Parent's email address",
                hint: 'parent@example.com',
                controller: widget.parentEmailCtrl,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                validator: (v) {
                  if (v == null ||
                      !v.contains('@') ||
                      !v.contains('.')) {
                    return 'Please enter a valid parent email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                "We'll email your parent to approve your account before you can use AI features.",
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.text2),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              height: AppSizing.buttonHeight,
              child: FilledButton(
                onPressed: _next,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.purple,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  'Next',
                  style: AppTextStyles.body.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Center(
              child: TextButton(
                onPressed: () => context.go('/auth/signin'),
                style: TextButton.styleFrom(foregroundColor: AppColors.text2),
                child: Text('Already have an account? Sign in',
                    style: AppTextStyles.bodySmall),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _AgeGroupTile extends StatelessWidget {
  const _AgeGroupTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.purpleL : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.purple : AppColors.outline,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? AppColors.purple : AppColors.text3,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.body.copyWith(
                  color: selected ? AppColors.purple : AppColors.text1,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step 2: Subject & Level ─────────────────────────────────────────────────

class _Step2SubjectLevel extends ConsumerWidget {
  const _Step2SubjectLevel({
    required this.nameCtrl,
    required this.emailCtrl,
    required this.passCtrl,
  });

  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(directOnboardingViewModelProvider);
    final notifier = ref.read(directOnboardingViewModelProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Image.asset(
              'assets/images/mochi.png',
              width: AppSizing.heroMochiSize,
              height: AppSizing.heroMochiSize,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'What are you studying?',
            style: AppTextStyles.heading1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Pick one subject to start with. You can add more later.',
            style: AppTextStyles.body.copyWith(color: AppColors.text2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          // Subject chips
          Text('Subject',
              style: AppTextStyles.label
                  .copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: directOnboardingSubjects.map((s) {
              final selected = vm.selectedSubject == s;
              return ChoiceChip(
                label: Text(subjectLabel(s)),
                selected: selected,
                onSelected: (_) => notifier.setSubject(s),
                selectedColor: AppColors.purpleL,
                labelStyle: AppTextStyles.body.copyWith(
                  color: selected ? AppColors.purple : AppColors.text1,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: selected ? AppColors.purple : AppColors.outline,
                  ),
                ),
                backgroundColor: AppColors.surface,
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Education stage picker (replaces Singapore-specific levels)
          Text('Education stage',
              style: AppTextStyles.label
                  .copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.sm),
          ...directOnboardingLevels.map((l) {
            final selected = vm.selectedLevel == l;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: GestureDetector(
                onTap: () => notifier.setLevel(l),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm + 2,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.purpleL : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? AppColors.purple : AppColors.outline,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        selected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color: selected ? AppColors.purple : AppColors.text3,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              levelLabel(l),
                              style: AppTextStyles.body.copyWith(
                                color: selected
                                    ? AppColors.purple
                                    : AppColors.text1,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                            Text(
                              levelSubtitle(l),
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.text3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            height: AppSizing.buttonHeight,
            child: FilledButton(
              onPressed: vm.isLoading ||
                      vm.selectedSubject == null ||
                      vm.selectedLevel == null
                  ? null
                  : () {
                      notifier.quickOnboard(
                        email: emailCtrl.text.trim(),
                        password: passCtrl.text,
                        displayName: nameCtrl.text.trim(),
                        subject: vm.selectedSubject!,
                        level: vm.selectedLevel!,
                      );
                    },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.purple,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: vm.isLoading
                  ? const SizedBox(
                      width: AppSizing.spinnerSm,
                      height: AppSizing.spinnerSm,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      'Create account',
                      style: AppTextStyles.body.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w700),
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

// ── Step 3: Upload first notes ──────────────────────────────────────────────

class _Step3Upload extends ConsumerWidget {
  const _Step3Upload({
    required this.avatarId,
    required this.uploadStage,
    required this.firstModuleId,
    required this.firstModuleTitle,
  });

  final String? avatarId;
  final DirectUploadStage uploadStage;
  final String? firstModuleId;
  final String? firstModuleTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Processing states
    if (uploadStage == DirectUploadStage.uploading ||
        uploadStage == DirectUploadStage.compiling ||
        uploadStage == DirectUploadStage.generatingModules) {
      return _ProcessingView(stage: uploadStage);
    }

    // Ready — module generated
    if (uploadStage == DirectUploadStage.ready) {
      return _ReadyView(
        avatarId: avatarId ?? '',
        moduleId: firstModuleId,
        moduleTitle: firstModuleTitle,
      );
    }

    // Idle or failed — show upload prompt
    return _UploadIdleView(
      avatarId: avatarId,
      uploadStage: uploadStage,
      onPickCamera: (ctx, r) => _pickFromCamera(ctx, r),
      onPickFile: (ctx, r) => _pickFile(ctx, r),
    );
  }

  Future<void> _pickFromCamera(BuildContext context, WidgetRef ref) async {
    try {
      final paths = await CunningDocumentScanner.getPictures(
        noOfPages: 1,
        isGalleryImportAllowed: false,
      );
      if (paths == null || paths.isEmpty) return;
      await ref
          .read(directOnboardingViewModelProvider.notifier)
          .uploadFromCamera(paths.first);
    } catch (e) {
      // Fallback to ImagePicker.
      appLog.w('[DirectOnboard] Scanner unavailable, fallback: $e');
      try {
        final picker = ImagePicker();
        final image =
            await picker.pickImage(source: ImageSource.camera, imageQuality: 90);
        if (image == null) return;
        await ref
            .read(directOnboardingViewModelProvider.notifier)
            .uploadFromCamera(image.path);
      } catch (e2) {
        appLog.w('[DirectOnboard] Camera fallback also failed: $e2');
      }
    }
  }

  Future<void> _pickFile(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'txt'],
    );
    if (result == null || result.files.isEmpty) return;
    await ref
        .read(directOnboardingViewModelProvider.notifier)
        .uploadFile(result.files.first);
  }
}

// ── Upload idle view (with typed notes primary + photo secondary) ───────────

class _UploadIdleView extends ConsumerStatefulWidget {
  const _UploadIdleView({
    required this.avatarId,
    required this.uploadStage,
    required this.onPickCamera,
    required this.onPickFile,
  });

  final String? avatarId;
  final DirectUploadStage uploadStage;
  final void Function(BuildContext, WidgetRef) onPickCamera;
  final void Function(BuildContext, WidgetRef) onPickFile;

  @override
  ConsumerState<_UploadIdleView> createState() => _UploadIdleViewState();
}

class _UploadIdleViewState extends ConsumerState<_UploadIdleView> {
  final _textCtrl = TextEditingController();
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    _textCtrl.addListener(_onChanged);
  }

  void _onChanged() {
    final len = _textCtrl.text.length;
    if (len != _charCount) setState(() => _charCount = len);
  }

  @override
  void dispose() {
    _textCtrl.removeListener(_onChanged);
    _textCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit => _charCount >= 50;

  Future<void> _submitTypedNotes() async {
    if (!_canSubmit) return;
    final avatarId = widget.avatarId;
    if (avatarId == null || avatarId.isEmpty) return;

    final text = _textCtrl.text.trim();
    // Write to a temp file and upload via the direct onboarding VM
    final dir = await getTemporaryDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'typed-notes-$ts.txt';
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(text);

    final platformFile = PlatformFile(
      name: fileName,
      path: file.path,
      size: text.length,
    );
    await ref
        .read(directOnboardingViewModelProvider.notifier)
        .uploadFile(platformFile);
  }

  @override
  Widget build(BuildContext context) {
    final charColor = _charCount > 5000 ? AppColors.coral : AppColors.text3;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  Center(
                    child: Image.asset(
                      'assets/images/mochi.png',
                      width: AppSizing.heroMochiSize,
                      height: AppSizing.heroMochiSize,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Add your first notes',
                    style: AppTextStyles.heading1,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Type or paste your notes below. Mochi will read them and build a study module for you.',
                    style: AppTextStyles.body.copyWith(color: AppColors.text2),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Text field
                  TextField(
                    controller: _textCtrl,
                    maxLines: 6,
                    minLines: 4,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      hintText: 'Paste or type your notes here...',
                      hintStyle:
                          AppTextStyles.body.copyWith(color: AppColors.text3),
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
                            color: AppColors.purple, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.all(AppSpacing.md),
                    ),
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  // Char count
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '$_charCount chars${_charCount < 50 ? ' (min 50)' : ''}',
                      style: AppTextStyles.caption.copyWith(color: charColor),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Submit typed notes button
                  SizedBox(
                    height: AppSizing.buttonHeight,
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _canSubmit ? _submitTypedNotes : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.purple,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        'Add to Mochi',
                        style: AppTextStyles.body.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Divider with "or"
                  Row(
                    children: [
                      const Expanded(child: Divider(color: AppColors.outline)),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md),
                        child: Text('or',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.text3)),
                      ),
                      const Expanded(child: Divider(color: AppColors.outline)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Photo button (secondary)
                  SizedBox(
                    height: AppSizing.buttonHeightSm,
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          widget.onPickCamera(context, ref),
                      icon: const Icon(Icons.camera_alt_rounded,
                          color: AppColors.purple),
                      label: Text(
                        'Or snap a photo',
                        style: AppTextStyles.body.copyWith(
                            color: AppColors.purple,
                            fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.purple),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // File picker (tertiary)
                  SizedBox(
                    height: AppSizing.buttonHeightSm,
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          widget.onPickFile(context, ref),
                      icon: const Icon(Icons.upload_file_rounded,
                          color: AppColors.text2),
                      label: Text(
                        'Or choose a file',
                        style: AppTextStyles.body.copyWith(
                            color: AppColors.text2,
                            fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.outline),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  if (widget.uploadStage == DirectUploadStage.failed) ...[
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: AppSpacing.card,
                      decoration: BoxDecoration(
                        color: AppColors.coralL,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Upload failed. Please try again.',
                        style:
                            AppTextStyles.body.copyWith(color: AppColors.coral),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
          // Highest-leverage join capture: a centre/group-referred student is
          // holding their code right now. Skippable — never blocks onboarding.
          TextButton(
            onPressed: () => const JoinRoute().push(context),
            child: Text(
              '🎟️  Have a class or group code? Enter or scan it',
              style: AppTextStyles.body.copyWith(
                  color: AppColors.purple, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
          ),
          // Skip option
          TextButton(
            onPressed: () => context.go('/'),
            child: Text(
              'Skip for now',
              style: AppTextStyles.body.copyWith(color: AppColors.text2),
            ),
          ),
          SizedBox(
              height: MediaQuery.of(context).padding.bottom + AppSpacing.md),
        ],
      ),
    );
  }
}

// ── Processing view ─────────────────────────────────────────────────────────

class _ProcessingView extends StatelessWidget {
  const _ProcessingView({required this.stage});
  final DirectUploadStage stage;

  String get _message => switch (stage) {
        DirectUploadStage.uploading => 'Uploading your notes...',
        DirectUploadStage.compiling => 'Mochi is reading your notes...',
        DirectUploadStage.generatingModules =>
          'Creating your first study module...',
        _ => 'Working on it...',
      };

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pulsing Mochi
            _PulsingMochi(),
            const SizedBox(height: AppSpacing.lg),
            Text(
              _message,
              style: AppTextStyles.title,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'This may take a minute.',
              style: AppTextStyles.body.copyWith(color: AppColors.text2),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            const SizedBox(
              width: AppSizing.spinnerSm,
              height: AppSizing.spinnerSm,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.purple),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulsingMochi extends StatefulWidget {
  @override
  State<_PulsingMochi> createState() => _PulsingMochiState();
}

class _PulsingMochiState extends State<_PulsingMochi>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mochiSize = MediaQuery.of(context).size.shortestSide * 0.3;
    return ScaleTransition(
      scale: _scale,
      child: Image.asset(
        'assets/images/mochi.png',
        width: mochiSize,
        height: mochiSize,
        fit: BoxFit.contain,
      ),
    );
  }
}

// ── Ready view ──────────────────────────────────────────────────────────────

class _ReadyView extends StatelessWidget {
  const _ReadyView({
    required this.avatarId,
    required this.moduleId,
    required this.moduleTitle,
  });

  final String avatarId;
  final String? moduleId;
  final String? moduleTitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.shortestSide * 0.25,
            height: MediaQuery.of(context).size.shortestSide * 0.25,
            decoration: const BoxDecoration(
              color: AppColors.greenL,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child:
                  Icon(Icons.check_rounded, size: 48, color: AppColors.green),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            moduleId != null
                ? 'Your "${moduleTitle ?? 'first'}" module is ready!'
                : 'Your Mochi is set up!',
            style: AppTextStyles.heading1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Mochi has read your notes and built a study module for you.',
            style: AppTextStyles.body.copyWith(color: AppColors.text2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            height: AppSizing.buttonHeight,
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                if (moduleId != null && moduleId!.isNotEmpty) {
                  context.go(
                      '/avatar/$avatarId/modules/$moduleId');
                } else {
                  context.go('/');
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.green,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                moduleId != null ? 'Start learning' : 'Go to home',
                style: AppTextStyles.body.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: () => context.go('/'),
            child: Text(
              'Go to home',
              style: AppTextStyles.body.copyWith(color: AppColors.text2),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Parent consent pending ──────────────────────────────────────────────────

class _ParentConsentPending extends ConsumerWidget {
  const _ParentConsentPending({required this.maskedParentEmail});

  final String maskedParentEmail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(directOnboardingViewModelProvider);
    final notifier = ref.read(directOnboardingViewModelProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Image.asset(
              'assets/images/mochi.png',
              width: AppSizing.heroMochiSize,
              height: AppSizing.heroMochiSize,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Check your parent\'s email!',
            style: AppTextStyles.heading1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'We sent a consent request to:',
            style: AppTextStyles.body.copyWith(color: AppColors.text2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            maskedParentEmail,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.text1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Ask a parent or guardian to click the link in the email. Your account will unlock as soon as they approve.',
            style: AppTextStyles.body.copyWith(color: AppColors.text2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          if (vm.consentResendError != null) ...[
            Container(
              padding: AppSpacing.card,
              decoration: BoxDecoration(
                color: AppColors.coralL,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                vm.consentResendError!,
                style: AppTextStyles.body.copyWith(color: AppColors.coral),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          SizedBox(
            height: AppSizing.buttonHeight,
            child: OutlinedButton(
              onPressed: vm.isLoading ? null : notifier.resendParentConsent,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.purple),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: vm.isLoading
                  ? const SizedBox(
                      width: AppSizing.spinnerSm,
                      height: AppSizing.spinnerSm,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.purple),
                    )
                  : Text(
                      'Resend consent email',
                      style: AppTextStyles.body.copyWith(
                          color: AppColors.purple,
                          fontWeight: FontWeight.w600),
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: TextButton(
              onPressed: () async {
                await notifier.signOutFromConsentScreen();
                if (context.mounted) context.go('/auth/signin');
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.text2),
              child: Text(
                'Sign out and use a different account',
                style: AppTextStyles.bodySmall,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

// ── Shared form field ───────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.hint,
    required this.controller,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.suffix,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.label
                .copyWith(fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          style: AppTextStyles.body,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.body.copyWith(color: AppColors.text3),
            counterText: '',
            filled: true,
            fillColor: const Color(0xFFEDE8F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.coral),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.coral, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}
