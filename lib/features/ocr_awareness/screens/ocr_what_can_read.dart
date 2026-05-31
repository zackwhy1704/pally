import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';

class OcrWhatCanReadScreen extends StatelessWidget {
  const OcrWhatCanReadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.text1),
          onPressed: () => context.pop(),
        ),
        title: Text('What can Pally read?',
            style: AppTextStyles.title.copyWith(fontSize: 16)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, 0, AppSpacing.md, AppSpacing.xl),
        children: const [
          _IntroBanner(),
          SizedBox(height: AppSpacing.md),
          _TierSection(
            tier: _Tier.great,
            items: [
              _TierItem('📝', 'Printed text', 97,
                  'Clear printed questions — reads almost perfectly'),
              _TierItem('🔢', 'Numbers & basic maths', 92,
                  'Digits and operators (+, −, ×, ÷) read well'),
              _TierItem('🅰️', 'Multiple choice labels', 90,
                  'A. B. C. D. labels are reliably detected'),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          _TierSection(
            tier: _Tier.ok,
            items: [
              _TierItem('✏️', 'Neat handwriting', 72,
                  'Clear block letters work; cursive may need fixing'),
              _TierItem('📐', 'Maths equations', 65,
                  'Simple equations OK; complex fractions may need editing'),
              _TierItem('🧪', 'Chemical formulas', 55,
                  'Subscripts & superscripts often need manual correction'),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          _TierSection(
            tier: _Tier.typeIt,
            items: [
              _TierItem.withAction(
                '📊',
                'Graphs & charts',
                20,
                'Mochi may read labels but cannot read bar heights, line values, or data points.',
                action: 'Tell Mochi the numbers yourself',
              ),
              _TierItem.withAction(
                '📐',
                'Geometry figures',
                15,
                'Mochi can\'t measure a drawing — it can\'t see angles or lengths from lines on paper.',
                action: 'Type the sides & angles instead',
              ),
              _TierItem.withAction(
                '🔤',
                'Cursive handwriting',
                20,
                'Very variable — cursive letters often get mixed up.',
                action: 'Type it out for accurate results',
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          _FooterTip(),
        ],
      ),
    );
  }
}

// ── Data ──────────────────────────────────────────────────────────────────────

enum _Tier { great, ok, typeIt }

class _TierItem {
  const _TierItem(this.emoji, this.name, this.accuracy, this.note)
      : action = null;
  const _TierItem.withAction(this.emoji, this.name, this.accuracy, this.note,
      {required this.action});

  final String emoji;
  final String name;
  final int accuracy;
  final String note;
  final String? action;
}

// ── Intro banner ──────────────────────────────────────────────────────────────

class _IntroBanner extends StatelessWidget {
  const _IntroBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.purple, AppColors.purpleC],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📸', style: TextStyle(fontSize: 24)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Mochi reads text & numbers really well',
                  style: AppTextStyles.title
                      .copyWith(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'But it can\'t truly "see" pictures like graphs or shapes — '
            'it only reads the text around them.',
            style:
                AppTextStyles.bodySmall.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

// ── Tier section ──────────────────────────────────────────────────────────────

class _TierSection extends StatelessWidget {
  const _TierSection({required this.tier, required this.items});

  final _Tier tier;
  final List<_TierItem> items;

  @override
  Widget build(BuildContext context) {
    final (label, labelColor, headerBg, borderColor) = switch (tier) {
      _Tier.great => (
          '✅  Reads great',
          AppColors.green,
          AppColors.greenL,
          AppColors.green,
        ),
      _Tier.ok => (
          '⚠️  Usually OK — check it',
          AppColors.amber,
          AppColors.amberL,
          AppColors.amber,
        ),
      _Tier.typeIt => (
          '🚫  Best to type it yourself',
          AppColors.coral,
          AppColors.coralL,
          AppColors.coral,
        ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Tier header chip
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: headerBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor.withValues(alpha: 0.4)),
          ),
          child: Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: labelColor,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        ...items.map((item) => _ItemCard(item: item, tier: tier)),
      ],
    );
  }
}

// ── Item card ─────────────────────────────────────────────────────────────────

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item, required this.tier});

  final _TierItem item;
  final _Tier tier;

  @override
  Widget build(BuildContext context) {
    final isTypeIt = tier == _Tier.typeIt;
    final barColor = isTypeIt
        ? AppColors.coral
        : (tier == _Tier.ok ? AppColors.amber : AppColors.green);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isTypeIt
              ? AppColors.coralL.withValues(alpha: 0.5)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isTypeIt
                ? AppColors.coral.withValues(alpha: 0.25)
                : AppColors.outline,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(item.emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.name,
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: barColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${item.accuracy}%',
                    style: AppTextStyles.caption.copyWith(
                      color: barColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(item.note,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.text2)),
            if (item.action != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.arrow_forward_rounded,
                      size: 12, color: AppColors.coral),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      item.action!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.coral,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: item.accuracy / 100.0,
                backgroundColor: AppColors.outline,
                valueColor: AlwaysStoppedAnimation(barColor),
                minHeight: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Footer tip ────────────────────────────────────────────────────────────────

class _FooterTip extends StatelessWidget {
  const _FooterTip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: AppColors.surf2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          const Text('💡', style: TextStyle(fontSize: 18)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Best tip: snap the words & numbers, then type any graph values yourself.',
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.text2),
            ),
          ),
        ],
      ),
    );
  }
}
