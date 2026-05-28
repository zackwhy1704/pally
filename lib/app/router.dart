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
import 'package:pally/features/progress/presentation/progress_screen.dart';
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

GoRouter buildAppRouter({ProviderContainer? container}) {
  final authNotifier = AuthNotifier.instance;

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
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
