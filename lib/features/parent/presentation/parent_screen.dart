import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/app/router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/ui/pally_loading_spinner.dart';
import 'package:pally/core/ui/pally_toast.dart';
import 'package:pally/features/parent/presentation/parent_view_model.dart';

class ParentScreen extends ConsumerWidget {
  const ParentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parentState = ref.watch(parentViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Text('Parent Mode', style: AppTextStyles.title),
        centerTitle: true,
        actions: [
          if (parentState.isPinVerified)
            IconButton(
              icon: const Icon(Icons.lock_rounded, color: AppColors.text2),
              onPressed: () =>
                  ref.read(parentViewModelProvider.notifier).lock(),
            ),
        ],
      ),
      body: parentState.isPinVerified
          ? parentState.isLoading
              ? const PallyLoadingSpinner()
              : _Dashboard(state: parentState)
          : _PinGate(
              error: parentState.pinError,
              hasExistingPin: parentState.hasExistingPin,
              onSubmit: (pin) =>
                  ref.read(parentViewModelProvider.notifier).verifyPin(pin),
              onForgot: () => _showResetPinDialog(context, ref),
            ),
    );
  }
}

/// Top-level "reset your PIN with your account password" dialog reused by
/// (a) the Forgot-PIN link on the gate and (b) the Change-PIN tile on the
/// dashboard. Same wire under the hood — both call ParentViewModel.changePin.
Future<void> _showResetPinDialog(
    BuildContext context, WidgetRef ref) async {
  final passCtrl = TextEditingController();
  final pinCtrl = TextEditingController();
  try {
  await showDialog<void>(
    context: context,
    builder: (dialogCtx) => AlertDialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Reset Parent PIN', style: AppTextStyles.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Enter your account password to set a new PIN. '
            'This prevents children from bypassing the gate.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.text2),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: passCtrl,
            obscureText: true,
            decoration:
                const InputDecoration(labelText: 'Account password'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: pinCtrl,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration:
                const InputDecoration(labelText: 'New PIN (4-6 digits)'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogCtx).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            final pass = passCtrl.text;
            final pin = pinCtrl.text;
            if (!RegExp(r'^\d{4,6}$').hasMatch(pin)) {
              PallyToast.error(context, 'PIN must be 4-6 digits');
              return;
            }
            final ok = await ref
                .read(parentViewModelProvider.notifier)
                .changePin(password: pass, newPin: pin);
            if (!context.mounted) return;
            Navigator.of(dialogCtx).pop();
            if (ok) {
              PallyToast.success(context, 'PIN updated');
            } else {
              PallyToast.error(context, 'Incorrect password');
            }
          },
          child: const Text('Update PIN'),
        ),
      ],
    ),
  );
  } finally {
    passCtrl.dispose();
    pinCtrl.dispose();
  }
}

class _PinGate extends StatefulWidget {
  const _PinGate({
    required this.error,
    required this.onSubmit,
    required this.hasExistingPin,
    required this.onForgot,
  });

  final String? error;
  final ValueChanged<String> onSubmit;
  // null = unknown; false = first-time; true = returning
  final bool? hasExistingPin;
  // Opens the "verify account password to reset PIN" flow.
  final VoidCallback onForgot;

  @override
  State<_PinGate> createState() => _PinGateState();
}

class _PinGateState extends State<_PinGate> {
  final _pin = StringBuffer();
  // First-time setup is two-step: capture once, ask again to confirm,
  // only submit when both match. Prevents a typo from silently becoming
  // a permanent (recoverable only via password reset) PIN.
  String? _firstEntry;
  String? _mismatchMessage;

  bool get _isFirstTime => widget.hasExistingPin == false;

  void _onDigit(String digit) {
    if (_pin.length >= 4) return;
    setState(() {
      _mismatchMessage = null;
      _pin.write(digit);
    });
    if (_pin.length == 4) _handleComplete();
  }

  void _handleComplete() {
    final entered = _pin.toString();
    if (_isFirstTime && _firstEntry == null) {
      // Stage 1 — capture, prompt confirm.
      setState(() {
        _firstEntry = entered;
        _pin.clear();
      });
      return;
    }
    if (_isFirstTime && _firstEntry != null) {
      // Stage 2 — must match.
      if (entered != _firstEntry) {
        setState(() {
          _mismatchMessage = "Those PINs didn't match. Try again.";
          _firstEntry = null;
          _pin.clear();
        });
        return;
      }
    }
    widget.onSubmit(entered);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _pin.clear());
    });
  }

  void _onDelete() {
    if (_pin.isEmpty) return;
    final s = _pin.toString();
    setState(() {
      _pin.clear();
      _pin.write(s.substring(0, s.length - 1));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.purpleL,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_outline_rounded,
                  color: AppColors.purple, size: 36),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              _isFirstTime
                  ? (_firstEntry == null
                      ? 'Create a Parent PIN'
                      : 'Confirm your PIN')
                  : 'Enter Parent PIN',
              style: AppTextStyles.heading1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _isFirstTime
                  ? (_firstEntry == null
                      ? 'Choose a 4-digit PIN to protect parent mode.'
                      : 'Type the same PIN again to lock it in.')
                  : 'Enter your 4-digit PIN to access parent mode.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.text2),
              textAlign: TextAlign.center,
            ),
            if (widget.hasExistingPin == false) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.amberL,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.amber, width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: AppColors.amber, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'First time? The 4 digits you enter now will become your '
                        "Parent PIN going forward. Write it down — you'll need it "
                        'every time you open parent mode.',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.text1),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            // PIN dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final filled = i < _pin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled ? AppColors.purple : Colors.transparent,
                    border: Border.all(
                      color: filled ? AppColors.purple : AppColors.outline,
                      width: 2,
                    ),
                  ),
                );
              }),
            ),
            if (_mismatchMessage != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                _mismatchMessage!,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.coral),
              ),
            ],
            if (widget.error != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.error!,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.coral),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            // Number pad
            _NumberPad(onDigit: _onDigit, onDelete: _onDelete),
            if (widget.hasExistingPin == true) ...[
              const SizedBox(height: AppSpacing.lg),
              TextButton(
                onPressed: widget.onForgot,
                child: Text('Forgot PIN?',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.purple)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NumberPad extends StatelessWidget {
  const _NumberPad({required this.onDigit, required this.onDelete});

  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final buttons = [
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '',
      '0',
      'del',
    ];

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      childAspectRatio: 2.0,
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      physics: const NeverScrollableScrollPhysics(),
      children: buttons.map((b) {
        if (b.isEmpty) return const SizedBox.shrink();
        if (b == 'del') {
          return GestureDetector(
            onTap: onDelete,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surf2,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.backspace_outlined,
                  color: AppColors.text2, size: 22),
            ),
          );
        }
        return GestureDetector(
          onTap: () => onDigit(b),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outline),
            ),
            child: Center(
              child: Text(
                b,
                style: AppTextStyles.title.copyWith(fontSize: 22),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _Dashboard extends ConsumerWidget {
  const _Dashboard({required this.state});

  final ParentState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = state.stats;
    if (stats == null) return const PallyLoadingSpinner();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _WeekStatsRow(stats: stats),
          const SizedBox(height: AppSpacing.md),
          const _WeeklyReportsCard(),
          const SizedBox(height: AppSpacing.md),
          if (stats.subjects.isNotEmpty)
            _SubjectBreakdown(subjects: stats.subjects),
          if (stats.subjects.isNotEmpty)
            const SizedBox(height: AppSpacing.md),
          if (stats.weakAreas.isNotEmpty) _WeakAreasCard(areas: stats.weakAreas),
          if (stats.weakAreas.isNotEmpty)
            const SizedBox(height: AppSpacing.md),
          if (stats.reviewTopics.isNotEmpty) ...[
            _ReviewTopicsCard(topics: stats.reviewTopics),
            const SizedBox(height: AppSpacing.md),
          ],
          _ScreenTimeCard(state: state),
          const SizedBox(height: AppSpacing.md),
          _SettingsCard(
            onChangePin: () => _showChangePinDialog(context, ref),
          ),
          const SizedBox(height: AppSpacing.md),
          _AlertsCard(),
        ],
      ),
    );
  }

  Future<void> _showChangePinDialog(
          BuildContext context, WidgetRef ref) =>
      _showResetPinDialog(context, ref);
}

class _WeekStatsRow extends StatelessWidget {
  const _WeekStatsRow({required this.stats});

  final ParentStats stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatBox(
            label: 'Sessions',
            value: '${stats.sessionsThisWeek}',
            icon: Icons.play_circle_outline_rounded,
            color: AppColors.purple,
            bgColor: AppColors.purpleL,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatBox(
            label: 'Minutes',
            value: '${stats.minutesThisWeek}',
            icon: Icons.timer_outlined,
            color: AppColors.teal,
            bgColor: AppColors.tealL,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatBox(
            label: 'XP earned',
            value: '${stats.xpThisWeek}',
            icon: Icons.star_outlined,
            color: AppColors.amber,
            bgColor: AppColors.amberL,
          ),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 2),
          Text(value,
              style: AppTextStyles.title.copyWith(color: color, fontSize: 18)),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _SubjectBreakdown extends StatelessWidget {
  const _SubjectBreakdown({required this.subjects});

  final List<SubjectStat> subjects;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Subject Breakdown', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.md),
          ...subjects.map((s) {
            final pct = (s.mastery * 100).round();
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          s.subject,
                          style: AppTextStyles.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('$pct%',
                          style: AppTextStyles.label
                              .copyWith(color: AppColors.purple)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: s.mastery.clamp(0.0, 1.0),
                      backgroundColor: AppColors.outline,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(AppColors.purple),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ScreenTimeCard extends ConsumerWidget {
  const _ScreenTimeCard({required this.state});

  final ParentState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = state.stats;
    if (stats == null) return const SizedBox.shrink();

    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Screen Time', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Daily limit', style: AppTextStyles.body),
                    Text(
                      '${stats.screenTimeLimitMinutes} minutes/day',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              Switch(
                value: stats.screenTimeLimitEnabled,
                onChanged: (v) => ref
                    .read(parentViewModelProvider.notifier)
                    .toggleScreenTimeLimit(v),
                activeColor: AppColors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeeklyReportsCard extends StatelessWidget {
  const _WeeklyReportsCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => const ParentReportsRoute().push(context),
        child: Container(
          padding: AppSpacing.card,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outline),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.tealL,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.assessment_rounded,
                    color: AppColors.teal, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Weekly Reports',
                        style: AppTextStyles.body
                            .copyWith(fontWeight: FontWeight.w700)),
                    Text(
                      "Mastery, focus areas, and what's next.",
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.text2),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.text2),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Alerts', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.md),
          const _AlertTile(
            icon: Icons.warning_amber_rounded,
            text: 'Photosynthesis topic needs more practice',
            color: AppColors.amber,
          ),
          const SizedBox(height: AppSpacing.xs),
          const _AlertTile(
            icon: Icons.check_circle_rounded,
            text: '7-day learning streak! Great work.',
            color: AppColors.green,
          ),
          const SizedBox(height: AppSpacing.xs),
          const _AlertTile(
            icon: Icons.lightbulb_rounded,
            text: 'Science test in 14 days — keep practicing!',
            color: AppColors.purple,
          ),
        ],
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(text, style: AppTextStyles.bodySmall),
          ),
        ],
      ),
    );
  }
}

/// R8 — "Topics to revisit" panel populated from the quiz feedback loop.
/// Shows the page titles the backend flagged after wrong answers so a
/// parent knows exactly what to sit down and recap with their child.
class _ReviewTopicsCard extends StatelessWidget {
  const _ReviewTopicsCard({required this.topics});
  final List<String> topics;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: AppColors.amberL,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.amber, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Topics to revisit 📌', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Mochi flagged these after wrong quiz answers — worth a quick recap.',
            style:
                AppTextStyles.bodySmall.copyWith(color: AppColors.text2),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final t in topics)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• '),
                  Expanded(
                    child: Text(t,
                        style: AppTextStyles.body
                            .copyWith(color: AppColors.text1)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _WeakAreasCard extends StatelessWidget {
  const _WeakAreasCard({required this.areas});
  final List<WeakArea> areas;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weak Areas', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.md),
          ...areas.map((a) {
            final pct = (a.mastery * 100).round();
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(a.topic,
                            style: AppTextStyles.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 8),
                      Text('$pct%',
                          style: AppTextStyles.label
                              .copyWith(color: AppColors.coral)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: a.mastery.clamp(0.0, 1.0),
                      backgroundColor: AppColors.outline,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.coral),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.onChangePin});
  final VoidCallback onChangePin;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.purple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.lock_reset_rounded,
              color: AppColors.purple, size: 20),
        ),
        title: Text('Change Parent PIN',
            style:
                AppTextStyles.body.copyWith(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right_rounded,
            size: 20, color: AppColors.text3),
        onTap: onChangePin,
      ),
    );
  }
}
