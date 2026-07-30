import 'package:flutter/material.dart';
import 'package:pally/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';

class OcrWhatCanReadScreen extends StatelessWidget {
  const OcrWhatCanReadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.text1),
          onPressed: () => context.pop(),
        ),
        title: Text(l.ocrWhatCanRead,
            style: AppTextStyles.title.copyWith(fontSize: 16)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, 0, AppSpacing.md, AppSpacing.xl),
        children: [
          const _IntroBanner(),
          const SizedBox(height: AppSpacing.md),
          _TierSection(
            tier: _Tier.great,
            items: [
              _TierItem('📝', l.ocrItemPrintedText, 97, l.ocrNotePrintedText),
              _TierItem('🔢', l.ocrItemNumbers, 92, l.ocrNoteNumbers),
              _TierItem('🅰️', l.ocrItemMcqLabels, 90, l.ocrNoteMcqLabels),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _TierSection(
            tier: _Tier.ok,
            items: [
              _TierItem('✏️', l.ocrItemHandwriting, 72, l.ocrNoteHandwriting),
              _TierItem('📐', l.ocrItemEquations, 65, l.ocrNoteEquations),
              _TierItem('🧪', l.ocrItemFormulas, 55, l.ocrNoteFormulas),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _TierSection(
            tier: _Tier.typeIt,
            items: [
              _TierItem.withAction(
                '📊',
                l.ocrItemGraphs,
                20,
                l.ocrNoteGraphs(l.mascotName),
                action: l.ocrActionGraphs(l.mascotName),
              ),
              _TierItem.withAction(
                '📐',
                l.ocrItemGeometry,
                15,
                l.ocrNoteGeometry(l.mascotName),
                action: l.ocrActionGeometry,
              ),
              _TierItem.withAction(
                '🔤',
                l.ocrItemCursive,
                20,
                l.ocrNoteCursive,
                action: l.ocrActionCursive,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const _FooterTip(),
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
    final l = AppLocalizations.of(context);
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
                  l.ocrReadsWell(l.mascotName),
                  style: AppTextStyles.title
                      .copyWith(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l.ocrCantSee,
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
    final l = AppLocalizations.of(context);
    final (label, labelColor, headerBg, borderColor) = switch (tier) {
      _Tier.great => (
          l.ocrTierGreat,
          AppColors.green,
          AppColors.greenL,
          AppColors.green,
        ),
      _Tier.ok => (
          l.ocrTierOk,
          AppColors.amber,
          AppColors.amberL,
          AppColors.amber,
        ),
      _Tier.typeIt => (
          l.ocrTierTypeIt,
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
    final l = AppLocalizations.of(context);
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
              l.ocrBestTip,
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.text2),
            ),
          ),
        ],
      ),
    );
  }
}
