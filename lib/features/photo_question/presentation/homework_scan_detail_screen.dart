import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/features/chat/presentation/widgets/answer_card.dart';
import 'package:pally/shared/models/photo_question.dart';

class HomeworkScanDetailScreen extends StatefulWidget {
  const HomeworkScanDetailScreen({super.key, required this.result});

  final HomeworkScanResult result;

  @override
  State<HomeworkScanDetailScreen> createState() =>
      _HomeworkScanDetailScreenState();
}

class _HomeworkScanDetailScreenState extends State<HomeworkScanDetailScreen> {
  late List<bool> _expanded;

  static const List<Color> _colors = [
    AppColors.teal,
    AppColors.green,
    AppColors.purple,
    AppColors.amber,
  ];

  @override
  void initState() {
    super.initState();
    _expanded = List.generate(widget.result.answers.length, (_) => true);
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final answers = result.answers;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.text1, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Homework Results',
            style: AppTextStyles.title.copyWith(fontSize: 16)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded,
                color: AppColors.purple, size: 22),
            onPressed: _share,
            tooltip: 'Share results',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.md, AppSpacing.md, 100),
        children: [
          // Photo preview
          _PhotoPreview(imagePath: result.imageLocalPath),
          const SizedBox(height: AppSpacing.md),

          // Stats row
          _StatsRow(
            questionCount: answers.length,
            xpEarned: result.xpEarned,
            sourceWikiPage: result.sourceWikiPage,
          ),
          const SizedBox(height: AppSpacing.md),

          // Header banner
          _ResultBanner(count: answers.length),
          const SizedBox(height: AppSpacing.sm),

          // Answer cards — all individually expandable
          ...answers.asMap().entries.map((entry) {
            final i = entry.key;
            final answer = entry.value;
            final color = _colors[i % _colors.length];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AnswerCard(
                answer: answer,
                questionNumber: i + 1,
                color: color,
                isExpanded: i < _expanded.length && _expanded[i],
                onToggle: () {
                  if (i < _expanded.length) {
                    setState(() => _expanded[i] = !_expanded[i]);
                  }
                },
              ),
            );
          }),

          const SizedBox(height: AppSpacing.sm),

          // Follow-up actions
          _FollowUpSection(result: result),
        ],
      ),
    );
  }

  void _share() {
    // TODO: wire up share_plus once added to pubspec
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share coming soon!')),
    );
  }
}

// ── Photo preview ─────────────────────────────────────────────────────────────

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({required this.imagePath});
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final file = File(imagePath);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: double.infinity,
        height: 200,
        child: file.existsSync()
            ? Image.file(file, fit: BoxFit.cover)
            : Container(
                color: AppColors.surf2,
                child: const Center(
                  child: Text('📷', style: TextStyle(fontSize: 48)),
                ),
              ),
      ),
    );
  }
}

// ── Stats row ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.questionCount,
    required this.xpEarned,
    this.sourceWikiPage,
  });
  final int questionCount;
  final int xpEarned;
  final String? sourceWikiPage;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatChip(
          icon: '🔍',
          label: '$questionCount question${questionCount == 1 ? '' : 's'}',
          color: AppColors.purple,
          bgColor: AppColors.purpleL,
        ),
        const SizedBox(width: AppSpacing.sm),
        _StatChip(
          icon: '⭐',
          label: '+$xpEarned XP',
          color: AppColors.amber,
          bgColor: AppColors.amberL,
        ),
        if (sourceWikiPage != null) ...[
          const SizedBox(width: AppSpacing.sm),
          _StatChip(
            icon: '📖',
            label: sourceWikiPage!,
            color: AppColors.teal,
            bgColor: AppColors.tealL,
          ),
        ],
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
  });
  final String icon;
  final String label;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Result banner ─────────────────────────────────────────────────────────────

class _ResultBanner extends StatelessWidget {
  const _ResultBanner({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.purpleL,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.purple.withValues(alpha: 0.2)),
      ),
      child: Text(
        '🔍 I found $count question${count == 1 ? '' : 's'}! Here are the solutions:',
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.purple,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Follow-up section ─────────────────────────────────────────────────────────

class _FollowUpSection extends StatelessWidget {
  const _FollowUpSection({required this.result});
  final HomeworkScanResult result;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What next?',
            style:
                AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            _ActionChip(
              label: '📝 Show full working',
              onTap: () {},
            ),
            _ActionChip(
              label: '💡 Another example',
              onTap: () {},
            ),
            _ActionChip(
              label: '🎯 Quiz me on this',
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.purple.withValues(alpha: 0.4)),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0A1F1733), blurRadius: 4, offset: Offset(0, 2))
          ],
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.purple,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
