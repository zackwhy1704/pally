import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/core/ui/scaffold_shell.dart';
import 'package:pally/features/auth/auth_state.dart';
import 'package:pally/features/auth/screens/splash_screen.dart';
import 'package:pally/features/auth/screens/sign_in_screen.dart';
import 'package:pally/features/auth/screens/sign_up_screen.dart';
import 'package:pally/features/auth/screens/child_setup_screen.dart';
import 'package:pally/features/avatar_picker/screens/avatar_picker_screen.dart';
import 'package:pally/features/home/presentation/home_screen.dart';
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
import 'package:pally/features/shop/presentation/shop_screen.dart';
import 'package:pally/features/parent/presentation/parent_screen.dart';
import 'package:pally/features/parent/presentation/report_list_screen.dart';
import 'package:pally/features/parent/presentation/report_detail_screen.dart';
import 'package:pally/features/study_plan/presentation/study_plan_screen.dart';
import 'package:pally/features/settings/presentation/settings_screen.dart';
import 'package:pally/features/photo_question/presentation/camera_screen.dart';
import 'package:pally/features/photo_question/presentation/photo_preview_screen.dart';
import 'package:pally/features/photo_question/presentation/homework_scan_detail_screen.dart';
import 'package:pally/features/onboarding/presentation/onboarding_screen.dart';
import 'package:pally/features/brain_map/presentation/brain_map_screen.dart';
import 'package:pally/features/groups/presentation/create_group_screen.dart';
import 'package:pally/features/groups/presentation/group_detail_screen.dart';
import 'package:pally/features/groups/presentation/group_list_screen.dart';
import 'package:pally/features/teach_mochi/presentation/teach_mochi_screen.dart';
import 'package:pally/features/brain_health/presentation/brain_health_screen.dart';
import 'package:pally/shared/models/photo_question.dart';

part 'router.g.dart';

// ─── Shell (4-tab persistent navigation) ────────────────────────────────────

@TypedStatefulShellRoute<AppShellRouteData>(
  branches: <TypedStatefulShellBranch<StatefulShellBranchData>>[
    TypedStatefulShellBranch<HomeBranchData>(
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
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<LibraryRoute>(path: '/library'),
      ],
    ),
    TypedStatefulShellBranch<ChatBranchData>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<ChatTabRoute>(path: '/chat-tab'),
      ],
    ),
    TypedStatefulShellBranch<MeBranchData>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<ProgressRoute>(path: '/progress'),
      ],
    ),
    // 5th branch — must stay at index 4 to match TabSpec.branchIndex in
    // scaffold_shell.dart. Hidden from the bar when the groups_enabled
    // feature flag is off, but still routable so deep links keep working.
    TypedStatefulShellBranch<GroupsBranchData>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<GroupsTabRoute>(path: '/groups'),
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

class ChatBranchData extends StatefulShellBranchData {
  const ChatBranchData();
}

class MeBranchData extends StatefulShellBranchData {
  const MeBranchData();
}

class GroupsBranchData extends StatefulShellBranchData {
  const GroupsBranchData();
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

@TypedGoRoute<ParentRoute>(path: '/parent')
class ParentRoute extends GoRouteData {
  const ParentRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ParentScreen();
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

@TypedGoRoute<BrainMapRoute>(path: '/avatar/:avatarId/brain-map')
class BrainMapRoute extends GoRouteData {
  const BrainMapRoute({required this.avatarId});
  final String avatarId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      BrainMapScreen(avatarId: avatarId);
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

@TypedGoRoute<SubscriptionPlansRoute>(path: '/subscription/plans')
class SubscriptionPlansRoute extends GoRouteData {
  const SubscriptionPlansRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SubscriptionPlansScreen();
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

@TypedGoRoute<CameraRoute>(path: '/camera')
class CameraRoute extends GoRouteData {
  const CameraRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const CameraScreen();
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
  '/auth/signin',
  '/auth/signup',
  '/auth/setup',
  '/auth/avatar',
  '/onboarding',
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
    redirect: (context, state) {
      final auth = authNotifier.state;
      final path = state.matchedLocation;
      final isPublic = _publicPaths.any((p) => path.startsWith(p));

      if (!auth.isSignedIn && !isPublic) {
        return '/auth/signin';
      }

      if (auth.isSignedIn && path == '/') {
        if (!auth.isSetupComplete) return '/auth/setup';
        if (!auth.isOnboardingComplete) return '/onboarding';
      }

      return null;
    },
    routes: $appRoutes,
  );
}

final appRouter = buildAppRouter();
