import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/shared/models/wiki_page.dart';

class BrainHealthScreen extends ConsumerWidget {
  const BrainHealthScreen({super.key, required this.avatarId});

  final String avatarId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        title: Text('Brain Health 🧠',
            style: AppTextStyles.title.copyWith(fontSize: 16)),
        centerTitle: true,
      ),
      body: _BrainHealthBody(avatarId: avatarId),
    );
  }
}

class _BrainHealthBody extends ConsumerStatefulWidget {
  const _BrainHealthBody({required this.avatarId});
  final String avatarId;

  @override
  ConsumerState<_BrainHealthBody> createState() => _BrainHealthBodyState();
}

class _BrainHealthBodyState extends ConsumerState<_BrainHealthBody> {
  List<WikiPage>? _pages;
  Map<String, dynamic>? _errorPatterns;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final dio = ref.read(dioProvider);
      final pagesRes = await dio
          .get<Map<String, dynamic>>('/api/v1/avatars/${widget.avatarId}/wiki/pages');
      final List pagesJson = pagesRes.data?['pages'] ?? [];
      final pages = pagesJson.map((p) => WikiPage.fromJson(p as Map<String, dynamic>)).toList();

      final errorRes = await dio.get<Map<String, dynamic>>(
          '/api/v1/avatars/${widget.avatarId}/quiz/error-patterns');
      final errorData = errorRes.data ?? {};

      setState(() {
        _pages = pages;
        _errorPatterns = errorData;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.purple));
    }

    final pages = _pages ?? [];
    final verified = pages.where((p) => p.humanVerified).length;
    final avgQuality = pages.isEmpty
        ? 0.0
        : pages.map((p) => p.qualityScore).reduce((a, b) => a + b) /
            pages.length;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // Health score card
        _HealthScoreCard(
          pageCount: pages.length,
          verifiedCount: verified,
          avgQuality: avgQuality.round(),
        ),
        const SizedBox(height: AppSpacing.md),

        // Quality breakdown
        if (pages.isNotEmpty) ...[
          Text('Wiki Pages', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.sm),
          ...pages.map((p) => _PageHealthRow(page: p)),
          const SizedBox(height: AppSpacing.md),
        ],

        // Error patterns
        if (_errorPatterns != null && _errorPatterns!.isNotEmpty) ...[
          Text('Weak Topics', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.sm),
          ..._errorPatterns!.entries.take(5).map((e) => _ErrorPatternRow(
                topic: e.key,
                count: (e.value as num).toInt(),
              )),
        ],
      ],
    );
  }
}

class _HealthScoreCard extends StatelessWidget {
  const _HealthScoreCard({
    required this.pageCount,
    required this.verifiedCount,
    required this.avgQuality,
  });

  final int pageCount;
  final int verifiedCount;
  final int avgQuality;

  @override
  Widget build(BuildContext context) {
    final score = pageCount == 0
        ? 0
        : ((verifiedCount / pageCount.clamp(1, 999)) * 50 +
                avgQuality * 0.5)
            .round();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.purpleL,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppColors.purple.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text('Brain Health Score',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.text2)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '$score%',
            style: AppTextStyles.heading1
                .copyWith(color: AppColors.purple, fontSize: 48),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatPill(label: 'Pages', value: '$pageCount',
                  color: AppColors.purple),
              _StatPill(label: 'Verified', value: '$verifiedCount',
                  color: AppColors.teal),
              _StatPill(label: 'Avg Quality', value: '$avgQuality/100',
                  color: AppColors.amber),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill(
      {required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: AppTextStyles.title
                .copyWith(color: color, fontSize: 16)),
        Text(label,
            style:
                AppTextStyles.caption.copyWith(color: AppColors.text3)),
      ],
    );
  }
}

class _PageHealthRow extends StatelessWidget {
  const _PageHealthRow({required this.page});
  final WikiPage page;

  @override
  Widget build(BuildContext context) {
    final q = page.qualityScore;
    final color = q >= 70
        ? AppColors.green
        : q >= 40
            ? AppColors.amber
            : AppColors.coral;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          if (page.humanVerified)
            const Icon(Icons.verified_rounded,
                color: AppColors.teal, size: 14)
          else
            const SizedBox(width: 14),
          const SizedBox(width: 6),
          Expanded(
              child: Text(page.title,
                  style: AppTextStyles.bodySmall, overflow: TextOverflow.ellipsis)),
          const SizedBox(width: AppSpacing.sm),
          Container(
            width: 40,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.outline,
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: q / 100.0,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text('$q', style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _ErrorPatternRow extends StatelessWidget {
  const _ErrorPatternRow({required this.topic, required this.count});
  final String topic;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 14)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
              child: Text(topic,
                  style: AppTextStyles.bodySmall,
                  overflow: TextOverflow.ellipsis)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.coralL,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count errors',
              style: AppTextStyles.caption.copyWith(
                  color: AppColors.coral, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
