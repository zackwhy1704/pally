import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_sizing.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/utils/logger.dart';

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
    required this.backendSubject,
    required this.backendCharacterType,
  });

  final String id;
  final String name;
  final String emoji;
  final String subject;
  final Color themeColor;
  final Color cardBgColor;
  final String description;
  final String backendSubject;
  final String backendCharacterType;
}

const List<PallyAvatar> kAllAvatars = [
  PallyAvatar(
    id: 'mochi', name: 'Mochi', emoji: '🍡', subject: 'Science 🔬',
    themeColor: Color(0xFFFFB81A), cardBgColor: Color(0xFFFFF5D1),
    description: 'Lab explorer!',
    backendSubject: 'SCIENCE', backendCharacterType: 'MOCHI',
  ),
  PallyAvatar(
    id: 'boba', name: 'Boba', emoji: '🧋', subject: 'Maths ➕',
    themeColor: Color(0xFF7042ED), cardBgColor: Color(0xFFEBE0FF),
    description: 'Loves numbers!',
    backendSubject: 'MATHS', backendCharacterType: 'BOBA',
  ),
  PallyAvatar(
    id: 'tofu', name: 'Tofu', emoji: '🧈', subject: 'History 📜',
    themeColor: Color(0xFFC78533), cardBgColor: Color(0xFFF5EBE0),
    description: 'Time traveller!',
    backendSubject: 'HISTORY', backendCharacterType: 'ZAP',
  ),
  PallyAvatar(
    id: 'tempura', name: 'Tempura', emoji: '🍤', subject: 'English 📖',
    themeColor: Color(0xFF2EC770), cardBgColor: Color(0xFFDBFAE8),
    description: 'Wordsmith buddy!',
    backendSubject: 'ENGLISH', backendCharacterType: 'FINN',
  ),
  PallyAvatar(
    id: 'dumpling', name: 'Dumpling', emoji: '🥟', subject: 'Art 🎨',
    themeColor: Color(0xFFE05587), cardBgColor: Color(0xFFFFE0F0),
    description: 'Creative buddy!',
    backendSubject: 'ART', backendCharacterType: 'PUDDI',
  ),
  PallyAvatar(
    id: 'matcha', name: 'Matcha', emoji: '🍵', subject: 'Coding 💻',
    themeColor: Color(0xFF00BAA3), cardBgColor: Color(0xFFD9F6F1),
    description: 'Bug squasher!',
    backendSubject: 'CODING', backendCharacterType: 'BYTE',
  ),
  PallyAvatar(
    id: 'sushi', name: 'Sushi', emoji: '🍣', subject: 'Geography 🌍',
    themeColor: Color(0xFF2B87B0), cardBgColor: Color(0xFFD6EFF8),
    description: 'World explorer!',
    backendSubject: 'GEOGRAPHY', backendCharacterType: 'NORI',
  ),
  PallyAvatar(
    id: 'kimchi', name: 'Kimchi', emoji: '🌶️', subject: 'Languages 🗣',
    themeColor: Color(0xFFC73D2E), cardBgColor: Color(0xFFFFE5E4),
    description: 'Polyglot buddy!',
    backendSubject: 'LANGUAGES', backendCharacterType: 'CHIMI',
  ),
  PallyAvatar(
    id: 'waffle', name: 'Waffle', emoji: '🧇', subject: 'Music 🎵',
    themeColor: Color(0xFFE6A800), cardBgColor: Color(0xFFFFF5D1),
    description: 'Rock star buddy!',
    backendSubject: 'MUSIC', backendCharacterType: 'LUMIS',
  ),
  PallyAvatar(
    id: 'ramen', name: 'Ramen', emoji: '🍜', subject: 'P.E. ⚽',
    themeColor: Color(0xFFE07028), cardBgColor: Color(0xFFFFF3E0),
    description: 'Athletic buddy!',
    backendSubject: 'SCIENCE', backendCharacterType: 'MOCHI',
  ),
  PallyAvatar(
    id: 'taiyaki', name: 'Taiyaki', emoji: '🐟', subject: 'Drama 🎭',
    themeColor: Color(0xFF8C44CC), cardBgColor: Color(0xFFF0E6FA),
    description: 'Star performer!',
    backendSubject: 'ART', backendCharacterType: 'PUDDI',
  ),
  PallyAvatar(
    id: 'croissant', name: 'Croissant', emoji: '🥐', subject: 'Philosophy 🤔',
    themeColor: Color(0xFFB89840), cardBgColor: Color(0xFFFFF8E0),
    description: 'Deep thinker!',
    backendSubject: 'HISTORY', backendCharacterType: 'ZAP',
  ),
  PallyAvatar(
    id: 'naan', name: 'Naan', emoji: '🫓', subject: 'Economics 📊',
    themeColor: Color(0xFFA0825A), cardBgColor: Color(0xFFF5EBE0),
    description: 'Money wise!',
    backendSubject: 'MATHS', backendCharacterType: 'BOBA',
  ),
  PallyAvatar(
    id: 'gelato', name: 'Gelato', emoji: '🍨', subject: 'Design 🎨',
    themeColor: Color(0xFF4A90C0), cardBgColor: Color(0xFFD6EFF8),
    description: 'Pixel perfect!',
    backendSubject: 'ART', backendCharacterType: 'NORI',
  ),
  PallyAvatar(
    id: 'churro', name: 'Churro', emoji: '🍩', subject: 'Writing ✏️',
    themeColor: Color(0xFFC0883A), cardBgColor: Color(0xFFFFF3E0),
    description: 'Story teller!',
    backendSubject: 'ENGLISH', backendCharacterType: 'FINN',
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
          'name': av.name,
          'subject': av.backendSubject,
          'characterType': av.backendCharacterType,
        },
      );
      final avatarId = res.data?['id'] as String? ?? '';
      appLog.i('[AvatarPicker] Created avatar ${av.name} id=$avatarId');

      if (mounted) {
        if (widget.isOnboarding) {
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
            content: Text('Could not create Mochi — ${e.message}',
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
                'Each one is unique 🍡 Pick who you want to learn with!',
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
                height: AppSizing.buttonHeight,
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
                          width: AppSizing.checkboxSize,
                          height: AppSizing.checkboxSize,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          av != null
                              ? 'Choose ${av.name}! ${av.emoji}'
                              : 'Pick a Mochi first',
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
      height: AppSizing.appBarHeight,
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
              'Choose Your Mochi ✨',
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
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 140,
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
                        Center(
                          child: Text(
                            avatar.emoji,
                            style: const TextStyle(fontSize: 46),
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
                width: AppSizing.avatarPickerBadge,
                height: AppSizing.avatarPickerBadge,
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
