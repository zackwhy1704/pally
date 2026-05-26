import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/features/auth/auth_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Pally avatar data model ───────────────────────────────────────────────────

class PallyAvatar {
  const PallyAvatar({
    required this.id,
    required this.name,
    required this.emoji,
    required this.subject,
    required this.themeColor,
    required this.cardBgColor,
    required this.description,
  });

  final String id;
  final String name;
  final String emoji;
  final String subject;
  final Color themeColor;
  final Color cardBgColor;
  final String description;
}

const List<PallyAvatar> kAllAvatars = [
  PallyAvatar(
    id: 'mochi',
    name: 'Mochi',
    emoji: '🍡',
    subject: 'Maths',
    themeColor: Color(0xFF7042ED),
    cardBgColor: Color(0xFFE5E0FC),
    description: 'Loves numbers!',
  ),
  PallyAvatar(
    id: 'boba',
    name: 'Boba',
    emoji: '🧋',
    subject: 'English',
    themeColor: Color(0xFF00BAA3),
    cardBgColor: Color(0xFFD9F6F1),
    description: 'Wordsmith pig!',
  ),
  PallyAvatar(
    id: 'yuzu',
    name: 'Yuzu',
    emoji: '🍋',
    subject: 'Science',
    themeColor: Color(0xFFD4A50D),
    cardBgColor: Color(0xFFFFF7D6),
    description: 'Lab explorer!',
  ),
  PallyAvatar(
    id: 'lychee',
    name: 'Lychee',
    emoji: '🍈',
    subject: 'History',
    themeColor: Color(0xFFBD6524),
    cardBgColor: Color(0xFFF5EBE0),
    description: 'Time traveller!',
  ),
  PallyAvatar(
    id: 'taro',
    name: 'Taro',
    emoji: '💜',
    subject: 'Art',
    themeColor: Color(0xFF8C44CC),
    cardBgColor: Color(0xFFF0E6FA),
    description: 'Creative pig!',
  ),
  PallyAvatar(
    id: 'kiwi',
    name: 'Kiwi',
    emoji: '🥝',
    subject: 'Coding',
    themeColor: Color(0xFF2EC770),
    cardBgColor: Color(0xFFE0FAE9),
    description: 'Bug squasher!',
  ),
  PallyAvatar(
    id: 'pudding',
    name: 'Pudding',
    emoji: '🍮',
    subject: 'Geography',
    themeColor: Color(0xFFE68C25),
    cardBgColor: Color(0xFFFFF3E0),
    description: 'World explorer!',
  ),
  PallyAvatar(
    id: 'peach',
    name: 'Peach',
    emoji: '🍑',
    subject: 'Music',
    themeColor: Color(0xFFEF5350),
    cardBgColor: Color(0xFFFFECEC),
    description: 'Rock star pig!',
  ),
  PallyAvatar(
    id: 'matcha',
    name: 'Matcha',
    emoji: '🍵',
    subject: 'Languages',
    themeColor: Color(0xFF33A04C),
    cardBgColor: Color(0xFFE3F5E7),
    description: 'Polyglot pig!',
  ),
  PallyAvatar(
    id: 'durian',
    name: 'Durian',
    emoji: '🟡',
    subject: 'P.E.',
    themeColor: Color(0xFF99B81A),
    cardBgColor: Color(0xFFF7FAE0),
    description: 'Athletic pig!',
  ),
  PallyAvatar(
    id: 'berry',
    name: 'Rambutan',
    emoji: '🍓',
    subject: 'Drama',
    themeColor: Color(0xFFE83A4E),
    cardBgColor: Color(0xFFFFE5E8),
    description: 'Star performer!',
  ),
  PallyAvatar(
    id: 'mangosteen',
    name: 'Mangosteen',
    emoji: '🍇',
    subject: 'Philosophy',
    themeColor: Color(0xFF7B30D9),
    cardBgColor: Color(0xFFF1E6FF),
    description: 'Deep thinker!',
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class AvatarPickerScreen extends ConsumerStatefulWidget {
  const AvatarPickerScreen({
    super.key,
    this.isOnboarding = true,
  });

  final bool isOnboarding;

  @override
  ConsumerState<AvatarPickerScreen> createState() => _AvatarPickerScreenState();
}

class _AvatarPickerScreenState extends ConsumerState<AvatarPickerScreen> {
  String? _selectedId;
  bool _loading = false;
  final Map<String, AnimationController> _scaleControllers = {};

  @override
  void dispose() {
    for (final c in _scaleControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  PallyAvatar? get _selectedAvatar =>
      _selectedId == null
          ? null
          : kAllAvatars.firstWhere((a) => a.id == _selectedId);

  Future<void> _onTap(PallyAvatar avatar, TickerProvider ticker) async {
    setState(() => _selectedId = avatar.id);
    HapticFeedback.lightImpact();

    final ctrl = _scaleControllers.putIfAbsent(
      avatar.id,
      () => AnimationController(
        vsync: ticker,
        duration: const Duration(milliseconds: 150),
      ),
    );
    await ctrl.forward();
    await ctrl.reverse();
  }

  Future<void> _choose() async {
    final av = _selectedAvatar;
    if (av == null) return;
    setState(() => _loading = true);
    try {
      final dio = ref.read(dioProvider);
      final res = await dio.post<Map<String, dynamic>>(
        '/api/v1/avatars',
        data: {
          'characterId': av.id,
          'name': av.name,
          'subject': av.subject.toUpperCase().replaceAll('.', ''),
          'characterType': av.id.toUpperCase(),
        },
      );
      final avatarId = res.data?['id'] as String? ?? '';
      appLog.i('[AvatarPicker] Created avatar ${av.name} id=$avatarId');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('child_avatar_name', av.name);

      if (mounted) {
        if (widget.isOnboarding) {
          AuthNotifier.instance.markOnboardingComplete();
          context.go('/onboarding');
        } else {
          context.pop();
        }
      }
    } on DioException catch (e) {
      appLog.e('[AvatarPicker] Create failed', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not create tutor — ${e.message}',
                style: AppTextStyles.bodySmall.copyWith(color: Colors.white)),
            backgroundColor: AppColors.coral,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final av = _selectedAvatar;
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7FF),
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(isOnboarding: widget.isOnboarding),
            if (widget.isOnboarding) ...[
              const _ProgressBar(),
              const SizedBox(height: 8),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: 4),
              child: Text(
                'Each one is a chubby pig friend 🍡 Pick who you want to learn with!',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.text2),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: _AvatarGrid(
                selectedId: _selectedId,
                onTap: _onTap,
                scaleControllers: _scaleControllers,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: SizedBox(
                height: 52,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (av != null && !_loading) ? _choose : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: av?.themeColor ?? AppColors.text3,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppColors.text3.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          av != null
                              ? 'Choose ${av.name}! ${av.emoji}'
                              : 'Pick a tutor first',
                          style: AppTextStyles.body.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.isOnboarding});
  final bool isOnboarding;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          if (!isOnboarding)
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.text1, size: 20),
              onPressed: () => context.pop(),
            ),
          Expanded(
            child: Text(
              'Choose Your Pally 🐷',
              style: AppTextStyles.title,
              textAlign: isOnboarding ? TextAlign.center : TextAlign.start,
            ),
          ),
          if (!isOnboarding) const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: const LinearProgressIndicator(
          value: 1.0,
          minHeight: 6,
          backgroundColor: AppColors.outline,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.purple),
        ),
      ),
    );
  }
}

class _AvatarGrid extends StatefulWidget {
  const _AvatarGrid({
    required this.selectedId,
    required this.onTap,
    required this.scaleControllers,
  });

  final String? selectedId;
  final Future<void> Function(PallyAvatar, TickerProvider) onTap;
  final Map<String, AnimationController> scaleControllers;

  @override
  State<_AvatarGrid> createState() => _AvatarGridState();
}

class _AvatarGridState extends State<_AvatarGrid>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 110 / 142,
      ),
      itemCount: kAllAvatars.length,
      itemBuilder: (context, index) {
        final av = kAllAvatars[index];
        final isSelected = widget.selectedId == av.id;
        final ctrl = widget.scaleControllers[av.id];
        final scale = ctrl != null
            ? (1.0 + (0.04 * ctrl.value))
            : 1.0;
        return GestureDetector(
          onTap: () => widget.onTap(av, this),
          child: AnimatedBuilder(
            animation: ctrl ?? const AlwaysStoppedAnimation(0),
            builder: (_, __) => Transform.scale(
              scale: scale,
              child: _AvatarCard(avatar: av, isSelected: isSelected),
            ),
          ),
        );
      },
    );
  }
}

class _AvatarCard extends StatelessWidget {
  const _AvatarCard({required this.avatar, required this.isSelected});

  final PallyAvatar avatar;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: isSelected
            ? avatar.themeColor.withValues(alpha: 0.15)
            : avatar.cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? avatar.themeColor
              : Colors.grey.withValues(alpha: 0.3),
          width: isSelected ? 2.5 : 1.0,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: avatar.themeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Stack(
                      children: [
                        const Center(
                          child: Text(
                            '🐷',
                            style: TextStyle(fontSize: 46),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 6,
                          child: Text(
                            avatar.emoji,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  avatar.name,
                  style: AppTextStyles.label.copyWith(
                    color: isSelected ? avatar.themeColor : AppColors.text1,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  avatar.subject,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.text3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          if (isSelected)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: avatar.themeColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 10),
              ),
            ),
        ],
      ),
    );
  }
}
