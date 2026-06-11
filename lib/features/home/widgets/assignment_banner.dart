import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/app/router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/shared/models/assignment.dart';
import 'package:pally/shared/models/avatar.dart';

/// Shows assignment cards at the top of the home screen.
/// Fetches assignments for all avatars and shows them sorted:
/// overdue first (red), then due-soon (amber), then in-progress.
class AssignmentBanner extends ConsumerStatefulWidget {
  const AssignmentBanner({super.key, required this.avatars});
  final List<Avatar> avatars;

  @override
  ConsumerState<AssignmentBanner> createState() => _AssignmentBannerState();
}

class _AssignmentBannerState extends ConsumerState<AssignmentBanner> {
  List<_AvatarAssignment> _assignments = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant AssignmentBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.avatars.length != widget.avatars.length) {
      _load();
    }
  }

  Future<void> _load() async {
    final dio = ref.read(dioProvider);
    final results = <_AvatarAssignment>[];

    for (final avatar in widget.avatars) {
      try {
        final response = await dio.get<dynamic>(
          '/api/v1/avatars/${avatar.id}/assignments',
        );
        final data = response.data;
        final List<dynamic> list = data is List
            ? data
            : (data is Map && data['assignments'] is List
                ? data['assignments'] as List<dynamic>
                : const <dynamic>[]);

        for (final e in list) {
          try {
            final assignment =
                Assignment.fromJson(Map<String, dynamic>.from(e as Map));
            if (assignment.status != 'COMPLETED') {
              results.add(
                  _AvatarAssignment(avatar: avatar, assignment: assignment));
            }
          } catch (_) {}
        }
      } on DioException catch (e) {
        appLog.d(
            '[Home] Assignments for ${avatar.id} unavailable: ${e.type.name}');
      } catch (e, st) {
        appLog.e('[Home] Assignment load error for ${avatar.id}',
            error: e, stackTrace: st);
      }
    }

    // Sort: OVERDUE first, then PENDING, then IN_PROGRESS
    results.sort((a, b) {
      final order = _statusOrder(a.assignment.status)
          .compareTo(_statusOrder(b.assignment.status));
      if (order != 0) return order;
      return a.assignment.dueDate.compareTo(b.assignment.dueDate);
    });

    if (mounted) setState(() => _assignments = results);
  }

  int _statusOrder(String status) => switch (status) {
        'OVERDUE' => 0,
        'PENDING' => 1,
        'IN_PROGRESS' => 2,
        _ => 3,
      };

  @override
  Widget build(BuildContext context) {
    if (_assignments.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
          child: Text(
            'ASSIGNMENTS',
            style: AppTextStyles.label.copyWith(
              letterSpacing: 1.2,
              color: AppColors.text2,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        ..._assignments.map((a) => _AssignmentCard(
              avatar: a.avatar,
              assignment: a.assignment,
            )),
      ],
    );
  }
}

class _AvatarAssignment {
  const _AvatarAssignment({required this.avatar, required this.assignment});
  final Avatar avatar;
  final Assignment assignment;
}

class _AssignmentCard extends StatelessWidget {
  const _AssignmentCard({required this.avatar, required this.assignment});
  final Avatar avatar;
  final Assignment assignment;

  Color get _borderColor => switch (assignment.status) {
        'OVERDUE' => AppColors.coral,
        _ => _typeColor,
      };

  Color get _typeColor => switch (assignment.type) {
        'PRE_CLASS' => AppColors.teal,
        'POST_CLASS' => AppColors.amber,
        'REVISION' => AppColors.purple,
        'CUSTOM' => AppColors.pink,
        _ => AppColors.text3,
      };

  @override
  Widget build(BuildContext context) {
    final isOverdue = assignment.status == 'OVERDUE';
    final firstIncompleteModule = assignment.modules
        .where((m) => m.stage != 'COMPLETE')
        .firstOrNull;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.xs, AppSpacing.md, 0),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (firstIncompleteModule != null) {
              ModulePlayerRoute(
                avatarId: avatar.id,
                moduleId: firstIncompleteModule.id,
              ).push(context);
            }
          },
          child: Container(
            padding: AppSpacing.card,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border(
                left: BorderSide(color: _borderColor, width: 4),
                top: const BorderSide(color: AppColors.outline),
                right: const BorderSide(color: AppColors.outline),
                bottom: const BorderSide(color: AppColors.outline),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              assignment.title,
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.text1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _TypeBadge(type: assignment.type),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (isOverdue) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.coralL,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Overdue',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.coral,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                          ],
                          Flexible(
                            child: Text(
                              'Due: ${assignment.dueDate}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isOverdue
                                    ? AppColors.coral
                                    : AppColors.text2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.text2, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});
  final String type;

  Color get _color => switch (type) {
        'PRE_CLASS' => AppColors.teal,
        'POST_CLASS' => AppColors.amber,
        'REVISION' => AppColors.purple,
        'CUSTOM' => AppColors.pink,
        _ => AppColors.text3,
      };

  String get _label => switch (type) {
        'PRE_CLASS' => 'Pre-class',
        'POST_CLASS' => 'Post-class',
        'REVISION' => 'Revision',
        'CUSTOM' => 'Custom',
        _ => type,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      constraints: const BoxConstraints(maxWidth: 100),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _label,
        style: AppTextStyles.caption.copyWith(
          color: _color,
          fontWeight: FontWeight.w700,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
