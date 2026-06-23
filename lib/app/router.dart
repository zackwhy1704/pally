import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/scaffold_shell.dart';
import 'package:pally/features/auth/auth_state.dart';
import 'package:pally/features/app_update/force_update_screen.dart';
import 'package:pally/features/auth/screens/splash_screen.dart';
import 'package:pally/features/auth/screens/sign_in_screen.dart';
import 'package:pally/features/auth/screens/sign_up_screen.dart';
import 'package:pally/features/auth/screens/child_setup_screen.dart';
import 'package:pally/features/auth/screens/parent_onboarding_screen.dart';
import 'package:pally/features/avatar_picker/screens/avatar_picker_screen.dart';
import 'package:pally/features/home/presentation/home_screen.dart';
import 'package:pally/features/home/presentation/home_view_model.dart';
import 'package:pally/shared/models/avatar.dart';
import 'package:pally/features/create_tutor/presentation/create_tutor_screen.dart';
import 'package:pally/features/upload/presentation/upload_screen.dart';
import 'package:pally/features/chat/presentation/chat_screen.dart';
import 'package:pally/features/chat/presentation/chat_tab_screen.dart';
import 'package:pally/features/wiki_viewer/presentation/wiki_viewer_screen.dart';
import 'package:pally/features/wiki_compiled/presentation/wiki_compiled_screen.dart';
import 'package:pally/features/library/presentation/library_screen.dart';
import 'package:pally/features/quiz/presentation/quiz_screen.dart';
import 'package:pally/features/flashcards/presentation/flashcard_screen.dart';
import 'package:pally/features/progress/presentation/achievements_screen.dart';
import 'package:pally/features/progress/presentation/level_roadmap_screen.dart';
import 'package:pally/features/progress/presentation/progress_screen.dart';
import 'package:pally/features/family/presentation/family_claim_screen.dart';
import 'package:pally/features/family/presentation/family_dashboard_screen.dart';
import 'package:pally/features/family/presentation/family_link_code_screen.dart';
import 'package:pally/features/referral/presentation/referral_screen.dart';
import 'package:pally/features/centre/presentation/centre_join_screen.dart';
import 'package:pally/features/subscription/presentation/paywall_screen.dart';
import 'package:pally/features/subscription/presentation/subscription_plans_screen.dart';
import 'package:pally/features/subscription/presentation/subscription_return_screen.dart';
import 'package:pally/features/subscription/presentation/trial_expired_screen.dart';
import 'package:pally/features/collection/presentation/collection_screen.dart';
import 'package:pally/features/debug/presentation/painter_gallery_screen.dart';
import 'package:pally/features/shop/presentation/shop_screen.dart';
import 'package:pally/features/parent/presentation/parent_screen.dart';
import 'package:pally/features/parent/presentation/parent_home_screen.dart';
import 'package:pally/features/parent/presentation/child_detail_screen.dart';
import 'package:pally/features/parent/presentation/report_list_screen.dart';
import 'package:pally/features/parent/presentation/report_detail_screen.dart';
import 'package:pally/features/family/presentation/family_consent_screen.dart';
import 'package:pally/features/study_plan/presentation/study_plan_screen.dart';
import 'package:pally/features/settings/presentation/settings_screen.dart';
import 'package:pally/features/photo_question/presentation/camera_screen.dart';
import 'package:pally/features/photo_question/presentation/photo_preview_screen.dart';
import 'package:pally/features/photo_question/presentation/homework_scan_detail_screen.dart';
import 'package:pally/features/onboarding/presentation/onboarding_screen.dart';
import 'package:pally/features/onboarding/presentation/direct_onboarding_screen.dart';

import 'package:pally/features/groups/presentation/create_group_screen.dart';
import 'package:pally/features/groups/presentation/group_detail_screen.dart';
import 'package:pally/features/groups/presentation/group_list_screen.dart';
import 'package:pally/features/teach_mochi/presentation/teach_mochi_screen.dart';
import 'package:pally/features/brain_health/presentation/brain_health_screen.dart';
import 'package:pally/features/modules/presentation/module_list_screen.dart';
import 'package:pally/features/modules/presentation/module_player_screen.dart';
import 'package:pally/features/exam_prep/presentation/exam_prep_screen.dart';
import 'package:pally/features/assignments/presentation/assignment_compare_screen.dart';
import 'package:pally/features/auth/screens/centre_block_screen.dart';
import 'package:pally/features/auth/screens/consent_waiting_screen.dart';
import 'package:pally/features/auth/screens/parent_consent_screen.dart';
import 'package:pally/features/auth/screens/self_consent_screen.dart';
import 'package:pally/features/consent/presentation/ai_disclosure_screen.dart';
import 'package:pally/features/ocr_awareness/screens/ocr_what_can_read.dart';
import 'package:pally/shared/models/photo_question.dart';

part 'router.g.dart';

// ─── Shell (4-tab persistent navigation) ────────────────────────────────────

// Nav: Home(0) | Library(1) | Groups(2) | Me(3)
// Chat tab removed from nav — chat is still reachable via Home/Library avatar tap.
// Chat branch kept at index 4 (hidden) so existing /chat-tab deep links don't break.
@TypedStatefulShellRoute<AppShellRouteData>(
  branches: <TypedStatefulShellBranch<StatefulShellBranchData>>[
    TypedStatefulShellBranch<HomeBranchData>(
      // index 0
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<HomeRoute>(
          path: '/',
          routes: <TypedRoute<RouteData>>[
            TypedGoRoute<CreateTutorRoute>(path: 'create'),
          ],
        ),
      ],
    ),
    TypedStatefulShellBranch<LibraryBranchData>(
      // index 1
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<LibraryRoute>(path: '/library'),
      ],
    ),
    TypedStatefulShellBranch<GroupsBranchData>(
      // index 2 — open to all
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<GroupsTabRoute>(path: '/groups'),
      ],
    ),
    TypedStatefulShellBranch<MeBranchData>(
      // index 3
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<ProgressRoute>(path: '/progress'),
      ],
    ),
    // Chat branch kept hidden so /chat-tab deep links still resolve.
    TypedStatefulShellBranch<ChatBranchData>(
      // index 4 (hidden)
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<ChatTabRoute>(path: '/chat-tab'),
      ],
    ),
  ],
)
class AppShellRouteData extends StatefulShellRouteData {
  const AppShellRouteData();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) =>
      ScaffoldShell(navigationShell: navigationShell);
}

class HomeBranchData extends StatefulShellBranchData {
  const HomeBranchData();
}

class LibraryBranchData extends StatefulShellBranchData {
  const LibraryBranchData();
}

class GroupsBranchData extends StatefulShellBranchData {
  const GroupsBranchData();
}

class MeBranchData extends StatefulShellBranchData {
  const MeBranchData();
}

class ChatBranchData extends StatefulShellBranchData {
  const ChatBranchData();
}

// ─── Tab root screens ────────────────────────────────────────────────────────

class HomeRoute extends GoRouteData {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomeScreen();
}

class CreateTutorRoute extends GoRouteData {
  const CreateTutorRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const CreateTutorScreen();
}

class LibraryRoute extends GoRouteData {
  const LibraryRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const LibraryScreen();
}

class ChatTabRoute extends GoRouteData {
  const ChatTabRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ChatTabScreen();
}

class GroupsTabRoute extends GoRouteData {
  const GroupsTabRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const GroupListScreen();
}

class ProgressRoute extends GoRouteData {
  const ProgressRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ProgressScreen();
}

// ─── Full-screen routes (no bottom nav) ──────────────────────────────────────

@TypedGoRoute<UploadRoute>(path: '/avatar/:avatarId/upload')
class UploadRoute extends GoRouteData {
  const UploadRoute({required this.avatarId});
  final String avatarId;

  @override
  String? redirect(BuildContext context, GoRouterState state) {
    // Block centre-class avatars at the route level — students cannot upload
    // to a centre-managed Mochi. Belt-and-suspenders: entry points already hide
    // the affordance, and UploadScreen also pops on centre config. This redirect
    // prevents any blank-screen flash.
    final container = ProviderScope.containerOf(context, listen: false);
    final avatars = container.read(homeViewModelProvider);
    final avatar =
        avatars.valueOrNull?.where((a) => a.id == avatarId).firstOrNull;
    if (avatar != null && avatar.kind == AvatarKind.centreClass) {
      return '/';
    }
    return null;
  }

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      UploadScreen(avatarId: avatarId);
}

@TypedGoRoute<ChatRoute>(path: '/avatar/:avatarId/chat')
class ChatRoute extends GoRouteData {
  const ChatRoute({required this.avatarId});
  final String avatarId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      ChatScreen(avatarId: avatarId);
}

@TypedGoRoute<WikiViewerRoute>(path: '/avatar/:avatarId/wiki')
class WikiViewerRoute extends GoRouteData {
  const WikiViewerRoute({required this.avatarId});
  final String avatarId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      WikiViewerScreen(avatarId: avatarId);
}

@TypedGoRoute<WikiCompiledRoute>(path: '/avatar/:avatarId/wiki-compiled')
class WikiCompiledRoute extends GoRouteData {
  const WikiCompiledRoute(
      {required this.avatarId, this.newPageTitles = const []});
  final String avatarId;
  final List<String> newPageTitles;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      WikiCompiledScreen(avatarId: avatarId, newPageTitles: newPageTitles);
}

@TypedGoRoute<QuizRoute>(path: '/avatar/:avatarId/quiz')
class QuizRoute extends GoRouteData {
  const QuizRoute({required this.avatarId});
  final String avatarId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      QuizScreen(avatarId: avatarId);
}

@TypedGoRoute<FlashcardRoute>(path: '/avatar/:avatarId/flashcards')
class FlashcardRoute extends GoRouteData {
  const FlashcardRoute({required this.avatarId});
  final String avatarId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      FlashcardScreen(avatarId: avatarId);
}

@TypedGoRoute<ShopRoute>(path: '/shop')
class ShopRoute extends GoRouteData {
  const ShopRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const ShopScreen();
}

@TypedGoRoute<CollectionRoute>(path: '/collection')
class CollectionRoute extends GoRouteData {
  const CollectionRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const CollectionScreen();
}

/// Debug-only painter gallery — `/debug/painters`. Renders every
/// [MochiCharacter] via its CustomPainter so the dispatcher can be eyeballed.
/// The screen itself guards on kDebugMode; the route stays registered but the
/// body shows a placeholder in release builds.
@TypedGoRoute<DebugPainterGalleryRoute>(path: '/debug/painters')
class DebugPainterGalleryRoute extends GoRouteData {
  const DebugPainterGalleryRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const PainterGalleryScreen();
}

@TypedGoRoute<ParentRoute>(path: '/parent')
class ParentRoute extends GoRouteData {
  const ParentRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ParentScreen();
}

@TypedGoRoute<ParentHomeRoute>(path: '/parent-home')
class ParentHomeRoute extends GoRouteData {
  const ParentHomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ParentHomeScreen();
}

@TypedGoRoute<ChildDetailRoute>(path: '/parent/child/:childId')
class ChildDetailRoute extends GoRouteData {
  const ChildDetailRoute({required this.childId});
  final String childId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      ChildDetailScreen(childId: childId);
}

@TypedGoRoute<ParentOnboardingRoute>(path: '/parent-onboarding')
class ParentOnboardingRoute extends GoRouteData {
  const ParentOnboardingRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ParentOnboardingScreen();
}

@TypedGoRoute<FamilyConsentRoute2>(path: '/family/consent')
class FamilyConsentRoute2 extends GoRouteData {
  const FamilyConsentRoute2({this.parentName});
  final String? parentName;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      FamilyConsentScreen(parentName: parentName);
}

@TypedGoRoute<ParentReportsRoute>(path: '/parent/reports')
class ParentReportsRoute extends GoRouteData {
  const ParentReportsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ReportListScreen();
}

@TypedGoRoute<ParentReportDetailRoute>(path: '/parent/reports/:weekId')
class ParentReportDetailRoute extends GoRouteData {
  const ParentReportDetailRoute({required this.weekId});
  final String weekId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      ReportDetailScreen(weekId: weekId);
}

@TypedGoRoute<CreateGroupRoute>(path: '/groups/create')
class CreateGroupRoute extends GoRouteData {
  const CreateGroupRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const CreateGroupScreen();
}

@TypedGoRoute<StudyGroupDetailRoute>(path: '/groups/detail/:groupId')
class StudyGroupDetailRoute extends GoRouteData {
  const StudyGroupDetailRoute({required this.groupId});
  final String groupId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      GroupDetailScreen(groupId: groupId);
}


@TypedGoRoute<TeachMochiRoute>(path: '/avatar/:avatarId/teach')
class TeachMochiRoute extends GoRouteData {
  const TeachMochiRoute({required this.avatarId});
  final String avatarId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      TeachMochiScreen(avatarId: avatarId);
}

@TypedGoRoute<StudyPlanRoute>(path: '/avatar/:avatarId/study-plan')
class StudyPlanRoute extends GoRouteData {
  const StudyPlanRoute({required this.avatarId});
  final String avatarId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      StudyPlanScreen(avatarId: avatarId);
}

@TypedGoRoute<SettingsRoute>(path: '/settings')
class SettingsRoute extends GoRouteData {
  const SettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SettingsScreen();
}

@TypedGoRoute<LevelRoadmapRoute>(path: '/progress/level-roadmap')
class LevelRoadmapRoute extends GoRouteData {
  const LevelRoadmapRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const LevelRoadmapScreen();
}

@TypedGoRoute<AchievementsRoute>(path: '/progress/achievements')
class AchievementsRoute extends GoRouteData {
  const AchievementsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const AchievementsScreen();
}

/// Landing route after returning from Stripe Checkout. The Manifest's
/// pally:// intent filter relaunches the app; this screen polls
/// /subscription/entitlement until isPremium flips (or times out).
@TypedGoRoute<SubscriptionReturnRoute>(path: '/subscription/return')
class SubscriptionReturnRoute extends GoRouteData {
  const SubscriptionReturnRoute({this.status});
  final String? status;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      SubscriptionReturnScreen(status: status);
}

/// Reactive paywall — pushed by the Dio interceptor on UPGRADE_REQUIRED,
/// also reachable from the Settings "Subscription" row and the Progress
/// "Go Premium" banner.
@TypedGoRoute<PaywallRoute>(path: '/paywall')
class PaywallRoute extends GoRouteData {
  const PaywallRoute({this.feature});
  final String? feature;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      PaywallScreen(feature: feature);
}

@TypedGoRoute<TrialExpiredRoute>(path: '/trial/expired')
class TrialExpiredRoute extends GoRouteData {
  const TrialExpiredRoute({this.avatarId});
  final String? avatarId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      TrialExpiredScreen(avatarId: avatarId);
}

@TypedGoRoute<SubscriptionPlansRoute>(path: '/subscription/plans')
class SubscriptionPlansRoute extends GoRouteData {
  const SubscriptionPlansRoute({this.highlightTier});

  /// Optional tier to auto-select when arriving from the paywall.
  /// Matches _Plan.id prefix: 'pro', 'max', 'family', 'centre'.
  final String? highlightTier;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      SubscriptionPlansScreen(highlightTier: highlightTier);
}

@TypedGoRoute<FamilyLinkCodeRoute>(path: '/family/link-code')
class FamilyLinkCodeRoute extends GoRouteData {
  const FamilyLinkCodeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const FamilyLinkCodeScreen();
}

@TypedGoRoute<FamilyClaimRoute>(path: '/family/claim')
class FamilyClaimRoute extends GoRouteData {
  const FamilyClaimRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const FamilyClaimScreen();
}

@TypedGoRoute<FamilyDashboardRoute>(path: '/family')
class FamilyDashboardRoute extends GoRouteData {
  const FamilyDashboardRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const FamilyDashboardScreen();
}

@TypedGoRoute<ReferralRoute>(path: '/referral')
class ReferralRoute extends GoRouteData {
  const ReferralRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ReferralScreen();
}

@TypedGoRoute<CentreJoinRoute>(path: '/centre/join')
class CentreJoinRoute extends GoRouteData {
  const CentreJoinRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const CentreJoinScreen();
}

@TypedGoRoute<HomeworkScanDetailRoute>(path: '/homework-scan')
class HomeworkScanDetailRoute extends GoRouteData {
  const HomeworkScanDetailRoute({this.$extra});
  final HomeworkScanResult? $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      HomeworkScanDetailScreen(
        result: $extra ??
            const HomeworkScanResult(
              messageId: '',
              imageLocalPath: '',
              questions: [],
            ),
      );
}

@TypedGoRoute<BrainHealthRoute>(path: '/avatar/:avatarId/brain-health')
class BrainHealthRoute extends GoRouteData {
  const BrainHealthRoute({required this.avatarId});
  final String avatarId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      BrainHealthScreen(avatarId: avatarId);
}

@TypedGoRoute<ModuleListRoute>(path: '/avatar/:avatarId/modules')
class ModuleListRoute extends GoRouteData {
  const ModuleListRoute({required this.avatarId});
  final String avatarId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      ModuleListScreen(avatarId: avatarId);
}

@TypedGoRoute<ModulePlayerRoute>(path: '/avatar/:avatarId/modules/:moduleId')
class ModulePlayerRoute extends GoRouteData {
  const ModulePlayerRoute({required this.avatarId, required this.moduleId});
  final String avatarId;
  final String moduleId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      ModulePlayerScreen(avatarId: avatarId, moduleId: moduleId);
}

@TypedGoRoute<AssignmentCompareRoute>(
    path: '/avatar/:avatarId/assignments/:assignmentId')
class AssignmentCompareRoute extends GoRouteData {
  const AssignmentCompareRoute(
      {required this.avatarId, required this.assignmentId});
  final String avatarId;
  final String assignmentId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      AssignmentCompareScreen(avatarId: avatarId, assignmentId: assignmentId);
}

@TypedGoRoute<ExamPrepRoute>(path: '/avatar/:avatarId/exam-prep')
class ExamPrepRoute extends GoRouteData {
  const ExamPrepRoute({required this.avatarId});
  final String avatarId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      ExamPrepScreen(avatarId: avatarId);
}

@TypedGoRoute<SplashRoute>(path: '/splash')
class SplashRoute extends GoRouteData {
  const SplashRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SplashScreen();
}

@TypedGoRoute<SignInRoute>(path: '/auth/signin')
class SignInRoute extends GoRouteData {
  const SignInRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SignInScreen();
}

@TypedGoRoute<SignUpRoute>(path: '/auth/signup')
class SignUpRoute extends GoRouteData {
  const SignUpRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SignUpScreen();
}

@TypedGoRoute<CentreBlockRoute>(path: '/auth/centre-block')
class CentreBlockRoute extends GoRouteData {
  const CentreBlockRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const CentreBlockScreen();
}

@TypedGoRoute<ChildSetupRoute>(path: '/auth/setup')
class ChildSetupRoute extends GoRouteData {
  const ChildSetupRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ChildSetupScreen();
}

@TypedGoRoute<AvatarPickerRoute>(path: '/auth/avatar')
class AvatarPickerRoute extends GoRouteData {
  const AvatarPickerRoute({this.isOnboarding = true});
  final bool isOnboarding;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      AvatarPickerScreen(isOnboarding: isOnboarding);
}

@TypedGoRoute<OnboardingRoute>(path: '/onboarding')
class OnboardingRoute extends GoRouteData {
  const OnboardingRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const OnboardingScreen();
}

@TypedGoRoute<DirectOnboardingRoute>(path: '/onboarding/direct')
class DirectOnboardingRoute extends GoRouteData {
  const DirectOnboardingRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const DirectOnboardingScreen();
}

@TypedGoRoute<CameraRoute>(path: '/camera')
class CameraRoute extends GoRouteData {
  const CameraRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const CameraScreen();
}

@TypedGoRoute<OcrGuideRoute>(path: '/ocr-guide')
class OcrGuideRoute extends GoRouteData {
  const OcrGuideRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const OcrWhatCanReadScreen();
}

@TypedGoRoute<ParentConsentRoute>(path: '/consent/parent-email')
class ParentConsentRoute extends GoRouteData {
  const ParentConsentRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ParentConsentScreen();
}

@TypedGoRoute<ConsentWaitingRoute>(path: '/consent/waiting')
class ConsentWaitingRoute extends GoRouteData {
  const ConsentWaitingRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ConsentWaitingScreen();
}

@TypedGoRoute<SelfConsentRoute>(path: '/consent/self')
class SelfConsentRoute extends GoRouteData {
  const SelfConsentRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SelfConsentScreen();
}

@TypedGoRoute<AiDisclosureRoute>(path: '/consent/ai-disclosure')
class AiDisclosureRoute extends GoRouteData {
  const AiDisclosureRoute({this.info = false});

  /// When true, render the under-13 informational variant (no "I agree"; the
  /// parent records consent in the parent app). Defaults to the 13+
  /// self-consent variant so the `AI_CONSENT_REQUIRED` gate keeps working.
  final bool info;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      AiDisclosureScreen(informationOnly: info);
}

@TypedGoRoute<PhotoPreviewRoute>(path: '/avatar/:avatarId/photo-preview')
class PhotoPreviewRoute extends GoRouteData {
  const PhotoPreviewRoute({required this.avatarId, this.$extra});
  final String avatarId;
  final String? $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) => PhotoPreviewScreen(
        avatarId: avatarId,
        photoPath: $extra ?? '',
      );
}

// ─── Router instance ─────────────────────────────────────────────────────────

// Public routes that never require authentication
const _publicPaths = {
  '/force-update', // forced-update gate — reachable regardless of auth state
  '/auth/signin',
  '/auth/signup',
  '/auth/setup',
  '/auth/avatar',
  '/auth/centre-block',
  '/onboarding',
  '/onboarding/direct',
  '/consent/', // all consent sub-paths are accessible after login (auth token present)
  '/parent-onboarding',
  '/parent-home',
  '/family/consent',
};

GoRouter buildAppRouter({
  ProviderContainer? container,
  GlobalKey<NavigatorState>? navigatorKey,
}) {
  final authNotifier = AuthNotifier.instance;

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    navigatorKey: navigatorKey,
    refreshListenable: authNotifier,
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: AppColors.text3),
            const SizedBox(height: AppSpacing.md),
            Text('Something went wrong.', style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.sm),
            FilledButton(
              onPressed: () => context.go('/'),
              style: FilledButton.styleFrom(
                  backgroundColor: AppColors.purple),
              child: const Text('Go home'),
            ),
          ],
        ),
      ),
    ),
    redirect: (context, state) {
      final auth = authNotifier.state;
      final path = state.matchedLocation;
      final isPublic = _publicPaths.any((p) => path.startsWith(p));

      if (!auth.isSignedIn && !isPublic) {
        return '/auth/signin';
      }

      if (auth.isSignedIn && path == '/') {
        if (auth.isParentAccount) return '/parent-home';
        if (!auth.isSetupComplete) return '/auth/setup';
        if (!auth.isOnboardingComplete) return '/onboarding';
      }

      return null;
    },
    routes: [
      ...$appRoutes,
      // Plain (non-typed) route for the forced-update gate — a dead-end blocking
      // screen reached only via resolveStartRoute when the client is too old.
      GoRoute(
        path: '/force-update',
        builder: (context, state) => const ForceUpdateScreen(),
      ),
    ],
  );
}

final appRouter = buildAppRouter();
