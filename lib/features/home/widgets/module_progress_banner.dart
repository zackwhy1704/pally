import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/app/router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/shared/models/avatar.dart';
import 'package:pally/shared/models/learning_module.dart';

/// Shows the first in-progress module for each avatar on the home screen.
/// Tap navigates directly to the module player.
class ModuleProgressBanner extends ConsumerStatefulWidget {
  const ModuleProgressBanner({super.key, required this.avatars});
  final List<Avatar> avatars;

  @override
  ConsumerState<ModuleProgressBanner> createState() =>
      _ModuleProgressBannerState();
}

class _ModuleProgressBannerState extends ConsumerState<ModuleProgressBanner> {
  List<_ActiveModule> _activeModules = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant ModuleProgressBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.avatars.length != widget.avatars.length) {
      _load();
    }
  }

  Future<void> _load() async {
    final dio = ref.read(dioProvider);
    final results = <_ActiveModule>[];

    for (final avatar in widget.avatars) {
      try {
        final response = await dio.get<dynamic>(
          '/api/v1/avatars/${avatar.id}/modules',
        );
        final data = response.data;
        final List<dynamic> list = data is List
            ? data
            : (data is Map && data['modules'] is List
                ? data['modules'] as List<dynamic>
                : const <dynamic>[]);

        for (final e in list) {
          try {
            final module = LearningModule.fromJson(
                Map<String, dynamic>.from(e as Map));
            if (module.stage != 'COMPLETE') {
              results.add(_ActiveModule(avatar: avatar, module: module));
              break; // Only show first in-progress module per avatar
            }
          } catch (_) {}
        }
      } on DioException catch (e) {
        appLog.d('[Home] Modules for ${avatar.id} unavailable: ${e.type.name}');
      } catch (e, st) {
        appLog.e('[Home] Module load error for ${avatar.id}',
            error: e, stackTrace: st);
      }
    }

    if (mounted) setState(() => _activeModules = results);
  }

  @override
  Widget build(BuildContext context) {
    if (_activeModules.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
          child: Text(
            'CONTINUE LEARNING',
            style: AppTextStyles.label.copyWith(
              letterSpacing: 1.2,
              color: AppColors.text2,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        ..._activeModules.map((m) => _ModuleProgressCard(
              avatar: m.avatar,
              module: m.module,
            )),
      ],
    );
  }
}

class _ActiveModule {
  const _ActiveModule({required this.avatar, required this.module});
  final Avatar avatar;
  final LearningModule module;
}

class _ModuleProgressCard extends StatelessWidget {
  const _ModuleProgressCard({required this.avatar, required this.module});
  final Avatar avatar;
  final LearningModule module;

  Color get _stageColor => switch (module.stage) {
        'LEARN' => AppColors.teal,
        'TEST' => AppColors.amber,
        'PROVE' => AppColors.purple,
        _ => AppColors.text3,
      };

  String get _stageLabel => switch (module.stage) {
        'LEARN' => 'LEARN',
        'TEST' => 'TEST',
        'PROVE' => 'PROVE',
        _ => module.stage,
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.xs, AppSpacing.md, 0),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => ModulePlayerRoute(
            avatarId: avatar.id,
            moduleId: module.id,
          ).push(context),
          child: Container(
            padding: AppSpacing.card,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outline),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _stageColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: _stageColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        module.title,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.text1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _stageColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _stageLabel,
                              style: AppTextStyles.caption.copyWith(
                                color: _stageColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Flexible(
                            child: Text(
                              '${avatar.name} — ${module.masteryDisplayPct}%',
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.text2),
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
