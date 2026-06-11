// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $appShellRouteData,
      $uploadRoute,
      $chatRoute,
      $wikiViewerRoute,
      $wikiCompiledRoute,
      $quizRoute,
      $flashcardRoute,
      $shopRoute,
      $collectionRoute,
      $parentRoute,
      $parentHomeRoute,
      $childDetailRoute,
      $parentOnboardingRoute,
      $familyConsentRoute2,
      $parentReportsRoute,
      $parentReportDetailRoute,
      $createGroupRoute,
      $studyGroupDetailRoute,
      $brainMapRoute,
      $teachMochiRoute,
      $studyPlanRoute,
      $settingsRoute,
      $levelRoadmapRoute,
      $achievementsRoute,
      $subscriptionReturnRoute,
      $paywallRoute,
      $subscriptionPlansRoute,
      $familyLinkCodeRoute,
      $familyClaimRoute,
      $familyDashboardRoute,
      $referralRoute,
      $centreJoinRoute,
      $homeworkScanDetailRoute,
      $brainHealthRoute,
      $moduleListRoute,
      $modulePlayerRoute,
      $examPrepRoute,
      $splashRoute,
      $signInRoute,
      $signUpRoute,
      $childSetupRoute,
      $avatarPickerRoute,
      $onboardingRoute,
      $directOnboardingRoute,
      $cameraRoute,
      $ocrGuideRoute,
      $parentConsentRoute,
      $consentWaitingRoute,
      $selfConsentRoute,
      $aiDisclosureRoute,
      $photoPreviewRoute,
    ];

RouteBase get $appShellRouteData => StatefulShellRouteData.$route(
      factory: $AppShellRouteDataExtension._fromState,
      branches: [
        StatefulShellBranchData.$branch(
          routes: [
            GoRouteData.$route(
              path: '/',
              factory: $HomeRouteExtension._fromState,
              routes: [
                GoRouteData.$route(
                  path: 'create',
                  factory: $CreateTutorRouteExtension._fromState,
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranchData.$branch(
          routes: [
            GoRouteData.$route(
              path: '/library',
              factory: $LibraryRouteExtension._fromState,
            ),
          ],
        ),
        StatefulShellBranchData.$branch(
          routes: [
            GoRouteData.$route(
              path: '/groups',
              factory: $GroupsTabRouteExtension._fromState,
            ),
          ],
        ),
        StatefulShellBranchData.$branch(
          routes: [
            GoRouteData.$route(
              path: '/tuition',
              factory: $TuitionTabRouteExtension._fromState,
            ),
          ],
        ),
        StatefulShellBranchData.$branch(
          routes: [
            GoRouteData.$route(
              path: '/progress',
              factory: $ProgressRouteExtension._fromState,
            ),
          ],
        ),
        StatefulShellBranchData.$branch(
          routes: [
            GoRouteData.$route(
              path: '/chat-tab',
              factory: $ChatTabRouteExtension._fromState,
            ),
          ],
        ),
      ],
    );

extension $AppShellRouteDataExtension on AppShellRouteData {
  static AppShellRouteData _fromState(GoRouterState state) =>
      const AppShellRouteData();
}

extension $HomeRouteExtension on HomeRoute {
  static HomeRoute _fromState(GoRouterState state) => const HomeRoute();

  String get location => GoRouteData.$location(
        '/',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $CreateTutorRouteExtension on CreateTutorRoute {
  static CreateTutorRoute _fromState(GoRouterState state) =>
      const CreateTutorRoute();

  String get location => GoRouteData.$location(
        '/create',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $LibraryRouteExtension on LibraryRoute {
  static LibraryRoute _fromState(GoRouterState state) => const LibraryRoute();

  String get location => GoRouteData.$location(
        '/library',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $GroupsTabRouteExtension on GroupsTabRoute {
  static GroupsTabRoute _fromState(GoRouterState state) =>
      const GroupsTabRoute();

  String get location => GoRouteData.$location(
        '/groups',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $TuitionTabRouteExtension on TuitionTabRoute {
  static TuitionTabRoute _fromState(GoRouterState state) =>
      const TuitionTabRoute();

  String get location => GoRouteData.$location(
        '/tuition',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $ProgressRouteExtension on ProgressRoute {
  static ProgressRoute _fromState(GoRouterState state) => const ProgressRoute();

  String get location => GoRouteData.$location(
        '/progress',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $ChatTabRouteExtension on ChatTabRoute {
  static ChatTabRoute _fromState(GoRouterState state) => const ChatTabRoute();

  String get location => GoRouteData.$location(
        '/chat-tab',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $uploadRoute => GoRouteData.$route(
      path: '/avatar/:avatarId/upload',
      factory: $UploadRouteExtension._fromState,
    );

extension $UploadRouteExtension on UploadRoute {
  static UploadRoute _fromState(GoRouterState state) => UploadRoute(
        avatarId: state.pathParameters['avatarId']!,
      );

  String get location => GoRouteData.$location(
        '/avatar/${Uri.encodeComponent(avatarId)}/upload',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $chatRoute => GoRouteData.$route(
      path: '/avatar/:avatarId/chat',
      factory: $ChatRouteExtension._fromState,
    );

extension $ChatRouteExtension on ChatRoute {
  static ChatRoute _fromState(GoRouterState state) => ChatRoute(
        avatarId: state.pathParameters['avatarId']!,
      );

  String get location => GoRouteData.$location(
        '/avatar/${Uri.encodeComponent(avatarId)}/chat',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $wikiViewerRoute => GoRouteData.$route(
      path: '/avatar/:avatarId/wiki',
      factory: $WikiViewerRouteExtension._fromState,
    );

extension $WikiViewerRouteExtension on WikiViewerRoute {
  static WikiViewerRoute _fromState(GoRouterState state) => WikiViewerRoute(
        avatarId: state.pathParameters['avatarId']!,
      );

  String get location => GoRouteData.$location(
        '/avatar/${Uri.encodeComponent(avatarId)}/wiki',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $wikiCompiledRoute => GoRouteData.$route(
      path: '/avatar/:avatarId/wiki-compiled',
      factory: $WikiCompiledRouteExtension._fromState,
    );

extension $WikiCompiledRouteExtension on WikiCompiledRoute {
  static WikiCompiledRoute _fromState(GoRouterState state) => WikiCompiledRoute(
        avatarId: state.pathParameters['avatarId']!,
        newPageTitles: (state.uri.queryParametersAll['new-page-titles']
                ?.map((e) => e))?.toList() ??
            const [],
      );

  String get location => GoRouteData.$location(
        '/avatar/${Uri.encodeComponent(avatarId)}/wiki-compiled',
        queryParams: {
          if (!_$iterablesEqual(newPageTitles, const []))
            'new-page-titles': newPageTitles.map((e) => e).toList(),
        },
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

bool _$iterablesEqual<T>(Iterable<T>? iterable1, Iterable<T>? iterable2) {
  if (identical(iterable1, iterable2)) return true;
  if (iterable1 == null || iterable2 == null) return false;
  final iterator1 = iterable1.iterator;
  final iterator2 = iterable2.iterator;
  while (true) {
    final hasNext1 = iterator1.moveNext();
    final hasNext2 = iterator2.moveNext();
    if (hasNext1 != hasNext2) return false;
    if (!hasNext1) return true;
    if (iterator1.current != iterator2.current) return false;
  }
}

RouteBase get $quizRoute => GoRouteData.$route(
      path: '/avatar/:avatarId/quiz',
      factory: $QuizRouteExtension._fromState,
    );

extension $QuizRouteExtension on QuizRoute {
  static QuizRoute _fromState(GoRouterState state) => QuizRoute(
        avatarId: state.pathParameters['avatarId']!,
      );

  String get location => GoRouteData.$location(
        '/avatar/${Uri.encodeComponent(avatarId)}/quiz',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $flashcardRoute => GoRouteData.$route(
      path: '/avatar/:avatarId/flashcards',
      factory: $FlashcardRouteExtension._fromState,
    );

extension $FlashcardRouteExtension on FlashcardRoute {
  static FlashcardRoute _fromState(GoRouterState state) => FlashcardRoute(
        avatarId: state.pathParameters['avatarId']!,
      );

  String get location => GoRouteData.$location(
        '/avatar/${Uri.encodeComponent(avatarId)}/flashcards',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $shopRoute => GoRouteData.$route(
      path: '/shop',
      factory: $ShopRouteExtension._fromState,
    );

extension $ShopRouteExtension on ShopRoute {
  static ShopRoute _fromState(GoRouterState state) => const ShopRoute();

  String get location => GoRouteData.$location(
        '/shop',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $collectionRoute => GoRouteData.$route(
      path: '/collection',
      factory: $CollectionRouteExtension._fromState,
    );

extension $CollectionRouteExtension on CollectionRoute {
  static CollectionRoute _fromState(GoRouterState state) =>
      const CollectionRoute();

  String get location => GoRouteData.$location(
        '/collection',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $parentRoute => GoRouteData.$route(
      path: '/parent',
      factory: $ParentRouteExtension._fromState,
    );

extension $ParentRouteExtension on ParentRoute {
  static ParentRoute _fromState(GoRouterState state) => const ParentRoute();

  String get location => GoRouteData.$location(
        '/parent',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $parentHomeRoute => GoRouteData.$route(
      path: '/parent-home',
      factory: $ParentHomeRouteExtension._fromState,
    );

extension $ParentHomeRouteExtension on ParentHomeRoute {
  static ParentHomeRoute _fromState(GoRouterState state) =>
      const ParentHomeRoute();

  String get location => GoRouteData.$location(
        '/parent-home',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $childDetailRoute => GoRouteData.$route(
      path: '/parent/child/:childId',
      factory: $ChildDetailRouteExtension._fromState,
    );

extension $ChildDetailRouteExtension on ChildDetailRoute {
  static ChildDetailRoute _fromState(GoRouterState state) => ChildDetailRoute(
        childId: state.pathParameters['childId']!,
      );

  String get location => GoRouteData.$location(
        '/parent/child/${Uri.encodeComponent(childId)}',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $parentOnboardingRoute => GoRouteData.$route(
      path: '/parent-onboarding',
      factory: $ParentOnboardingRouteExtension._fromState,
    );

extension $ParentOnboardingRouteExtension on ParentOnboardingRoute {
  static ParentOnboardingRoute _fromState(GoRouterState state) =>
      const ParentOnboardingRoute();

  String get location => GoRouteData.$location(
        '/parent-onboarding',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $familyConsentRoute2 => GoRouteData.$route(
      path: '/family/consent',
      factory: $FamilyConsentRoute2Extension._fromState,
    );

extension $FamilyConsentRoute2Extension on FamilyConsentRoute2 {
  static FamilyConsentRoute2 _fromState(GoRouterState state) =>
      FamilyConsentRoute2(
        parentName: state.uri.queryParameters['parent-name'],
      );

  String get location => GoRouteData.$location(
        '/family/consent',
        queryParams: {
          if (parentName != null) 'parent-name': parentName,
        },
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $parentReportsRoute => GoRouteData.$route(
      path: '/parent/reports',
      factory: $ParentReportsRouteExtension._fromState,
    );

extension $ParentReportsRouteExtension on ParentReportsRoute {
  static ParentReportsRoute _fromState(GoRouterState state) =>
      const ParentReportsRoute();

  String get location => GoRouteData.$location(
        '/parent/reports',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $parentReportDetailRoute => GoRouteData.$route(
      path: '/parent/reports/:weekId',
      factory: $ParentReportDetailRouteExtension._fromState,
    );

extension $ParentReportDetailRouteExtension on ParentReportDetailRoute {
  static ParentReportDetailRoute _fromState(GoRouterState state) =>
      ParentReportDetailRoute(
        weekId: state.pathParameters['weekId']!,
      );

  String get location => GoRouteData.$location(
        '/parent/reports/${Uri.encodeComponent(weekId)}',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $createGroupRoute => GoRouteData.$route(
      path: '/groups/create',
      factory: $CreateGroupRouteExtension._fromState,
    );

extension $CreateGroupRouteExtension on CreateGroupRoute {
  static CreateGroupRoute _fromState(GoRouterState state) =>
      const CreateGroupRoute();

  String get location => GoRouteData.$location(
        '/groups/create',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $studyGroupDetailRoute => GoRouteData.$route(
      path: '/groups/detail/:groupId',
      factory: $StudyGroupDetailRouteExtension._fromState,
    );

extension $StudyGroupDetailRouteExtension on StudyGroupDetailRoute {
  static StudyGroupDetailRoute _fromState(GoRouterState state) =>
      StudyGroupDetailRoute(
        groupId: state.pathParameters['groupId']!,
      );

  String get location => GoRouteData.$location(
        '/groups/detail/${Uri.encodeComponent(groupId)}',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $brainMapRoute => GoRouteData.$route(
      path: '/avatar/:avatarId/brain-map',
      factory: $BrainMapRouteExtension._fromState,
    );

extension $BrainMapRouteExtension on BrainMapRoute {
  static BrainMapRoute _fromState(GoRouterState state) => BrainMapRoute(
        avatarId: state.pathParameters['avatarId']!,
      );

  String get location => GoRouteData.$location(
        '/avatar/${Uri.encodeComponent(avatarId)}/brain-map',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $teachMochiRoute => GoRouteData.$route(
      path: '/avatar/:avatarId/teach',
      factory: $TeachMochiRouteExtension._fromState,
    );

extension $TeachMochiRouteExtension on TeachMochiRoute {
  static TeachMochiRoute _fromState(GoRouterState state) => TeachMochiRoute(
        avatarId: state.pathParameters['avatarId']!,
      );

  String get location => GoRouteData.$location(
        '/avatar/${Uri.encodeComponent(avatarId)}/teach',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $studyPlanRoute => GoRouteData.$route(
      path: '/avatar/:avatarId/study-plan',
      factory: $StudyPlanRouteExtension._fromState,
    );

extension $StudyPlanRouteExtension on StudyPlanRoute {
  static StudyPlanRoute _fromState(GoRouterState state) => StudyPlanRoute(
        avatarId: state.pathParameters['avatarId']!,
      );

  String get location => GoRouteData.$location(
        '/avatar/${Uri.encodeComponent(avatarId)}/study-plan',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $settingsRoute => GoRouteData.$route(
      path: '/settings',
      factory: $SettingsRouteExtension._fromState,
    );

extension $SettingsRouteExtension on SettingsRoute {
  static SettingsRoute _fromState(GoRouterState state) => const SettingsRoute();

  String get location => GoRouteData.$location(
        '/settings',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $levelRoadmapRoute => GoRouteData.$route(
      path: '/progress/level-roadmap',
      factory: $LevelRoadmapRouteExtension._fromState,
    );

extension $LevelRoadmapRouteExtension on LevelRoadmapRoute {
  static LevelRoadmapRoute _fromState(GoRouterState state) =>
      const LevelRoadmapRoute();

  String get location => GoRouteData.$location(
        '/progress/level-roadmap',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $achievementsRoute => GoRouteData.$route(
      path: '/progress/achievements',
      factory: $AchievementsRouteExtension._fromState,
    );

extension $AchievementsRouteExtension on AchievementsRoute {
  static AchievementsRoute _fromState(GoRouterState state) =>
      const AchievementsRoute();

  String get location => GoRouteData.$location(
        '/progress/achievements',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $subscriptionReturnRoute => GoRouteData.$route(
      path: '/subscription/return',
      factory: $SubscriptionReturnRouteExtension._fromState,
    );

extension $SubscriptionReturnRouteExtension on SubscriptionReturnRoute {
  static SubscriptionReturnRoute _fromState(GoRouterState state) =>
      SubscriptionReturnRoute(
        status: state.uri.queryParameters['status'],
      );

  String get location => GoRouteData.$location(
        '/subscription/return',
        queryParams: {
          if (status != null) 'status': status,
        },
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $paywallRoute => GoRouteData.$route(
      path: '/paywall',
      factory: $PaywallRouteExtension._fromState,
    );

extension $PaywallRouteExtension on PaywallRoute {
  static PaywallRoute _fromState(GoRouterState state) => PaywallRoute(
        feature: state.uri.queryParameters['feature'],
      );

  String get location => GoRouteData.$location(
        '/paywall',
        queryParams: {
          if (feature != null) 'feature': feature,
        },
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $subscriptionPlansRoute => GoRouteData.$route(
      path: '/subscription/plans',
      factory: $SubscriptionPlansRouteExtension._fromState,
    );

extension $SubscriptionPlansRouteExtension on SubscriptionPlansRoute {
  static SubscriptionPlansRoute _fromState(GoRouterState state) =>
      SubscriptionPlansRoute(
        highlightTier: state.uri.queryParameters['highlight-tier'],
      );

  String get location => GoRouteData.$location(
        '/subscription/plans',
        queryParams: {
          if (highlightTier != null) 'highlight-tier': highlightTier,
        },
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $familyLinkCodeRoute => GoRouteData.$route(
      path: '/family/link-code',
      factory: $FamilyLinkCodeRouteExtension._fromState,
    );

extension $FamilyLinkCodeRouteExtension on FamilyLinkCodeRoute {
  static FamilyLinkCodeRoute _fromState(GoRouterState state) =>
      const FamilyLinkCodeRoute();

  String get location => GoRouteData.$location(
        '/family/link-code',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $familyClaimRoute => GoRouteData.$route(
      path: '/family/claim',
      factory: $FamilyClaimRouteExtension._fromState,
    );

extension $FamilyClaimRouteExtension on FamilyClaimRoute {
  static FamilyClaimRoute _fromState(GoRouterState state) =>
      const FamilyClaimRoute();

  String get location => GoRouteData.$location(
        '/family/claim',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $familyDashboardRoute => GoRouteData.$route(
      path: '/family',
      factory: $FamilyDashboardRouteExtension._fromState,
    );

extension $FamilyDashboardRouteExtension on FamilyDashboardRoute {
  static FamilyDashboardRoute _fromState(GoRouterState state) =>
      const FamilyDashboardRoute();

  String get location => GoRouteData.$location(
        '/family',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $referralRoute => GoRouteData.$route(
      path: '/referral',
      factory: $ReferralRouteExtension._fromState,
    );

extension $ReferralRouteExtension on ReferralRoute {
  static ReferralRoute _fromState(GoRouterState state) => const ReferralRoute();

  String get location => GoRouteData.$location(
        '/referral',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $centreJoinRoute => GoRouteData.$route(
      path: '/centre/join',
      factory: $CentreJoinRouteExtension._fromState,
    );

extension $CentreJoinRouteExtension on CentreJoinRoute {
  static CentreJoinRoute _fromState(GoRouterState state) =>
      const CentreJoinRoute();

  String get location => GoRouteData.$location(
        '/centre/join',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $homeworkScanDetailRoute => GoRouteData.$route(
      path: '/homework-scan',
      factory: $HomeworkScanDetailRouteExtension._fromState,
    );

extension $HomeworkScanDetailRouteExtension on HomeworkScanDetailRoute {
  static HomeworkScanDetailRoute _fromState(GoRouterState state) =>
      HomeworkScanDetailRoute(
        $extra: state.extra as HomeworkScanResult?,
      );

  String get location => GoRouteData.$location(
        '/homework-scan',
      );

  void go(BuildContext context) => context.go(location, extra: $extra);

  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: $extra);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: $extra);

  void replace(BuildContext context) =>
      context.replace(location, extra: $extra);
}

RouteBase get $brainHealthRoute => GoRouteData.$route(
      path: '/avatar/:avatarId/brain-health',
      factory: $BrainHealthRouteExtension._fromState,
    );

extension $BrainHealthRouteExtension on BrainHealthRoute {
  static BrainHealthRoute _fromState(GoRouterState state) => BrainHealthRoute(
        avatarId: state.pathParameters['avatarId']!,
      );

  String get location => GoRouteData.$location(
        '/avatar/${Uri.encodeComponent(avatarId)}/brain-health',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $moduleListRoute => GoRouteData.$route(
      path: '/avatar/:avatarId/modules',
      factory: $ModuleListRouteExtension._fromState,
    );

extension $ModuleListRouteExtension on ModuleListRoute {
  static ModuleListRoute _fromState(GoRouterState state) => ModuleListRoute(
        avatarId: state.pathParameters['avatarId']!,
      );

  String get location => GoRouteData.$location(
        '/avatar/${Uri.encodeComponent(avatarId)}/modules',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $modulePlayerRoute => GoRouteData.$route(
      path: '/avatar/:avatarId/modules/:moduleId',
      factory: $ModulePlayerRouteExtension._fromState,
    );

extension $ModulePlayerRouteExtension on ModulePlayerRoute {
  static ModulePlayerRoute _fromState(GoRouterState state) => ModulePlayerRoute(
        avatarId: state.pathParameters['avatarId']!,
        moduleId: state.pathParameters['moduleId']!,
      );

  String get location => GoRouteData.$location(
        '/avatar/${Uri.encodeComponent(avatarId)}/modules/${Uri.encodeComponent(moduleId)}',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $examPrepRoute => GoRouteData.$route(
      path: '/avatar/:avatarId/exam-prep',
      factory: $ExamPrepRouteExtension._fromState,
    );

extension $ExamPrepRouteExtension on ExamPrepRoute {
  static ExamPrepRoute _fromState(GoRouterState state) => ExamPrepRoute(
        avatarId: state.pathParameters['avatarId']!,
      );

  String get location => GoRouteData.$location(
        '/avatar/${Uri.encodeComponent(avatarId)}/exam-prep',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $splashRoute => GoRouteData.$route(
      path: '/splash',
      factory: $SplashRouteExtension._fromState,
    );

extension $SplashRouteExtension on SplashRoute {
  static SplashRoute _fromState(GoRouterState state) => const SplashRoute();

  String get location => GoRouteData.$location(
        '/splash',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $signInRoute => GoRouteData.$route(
      path: '/auth/signin',
      factory: $SignInRouteExtension._fromState,
    );

extension $SignInRouteExtension on SignInRoute {
  static SignInRoute _fromState(GoRouterState state) => const SignInRoute();

  String get location => GoRouteData.$location(
        '/auth/signin',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $signUpRoute => GoRouteData.$route(
      path: '/auth/signup',
      factory: $SignUpRouteExtension._fromState,
    );

extension $SignUpRouteExtension on SignUpRoute {
  static SignUpRoute _fromState(GoRouterState state) => const SignUpRoute();

  String get location => GoRouteData.$location(
        '/auth/signup',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $childSetupRoute => GoRouteData.$route(
      path: '/auth/setup',
      factory: $ChildSetupRouteExtension._fromState,
    );

extension $ChildSetupRouteExtension on ChildSetupRoute {
  static ChildSetupRoute _fromState(GoRouterState state) =>
      const ChildSetupRoute();

  String get location => GoRouteData.$location(
        '/auth/setup',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $avatarPickerRoute => GoRouteData.$route(
      path: '/auth/avatar',
      factory: $AvatarPickerRouteExtension._fromState,
    );

extension $AvatarPickerRouteExtension on AvatarPickerRoute {
  static AvatarPickerRoute _fromState(GoRouterState state) => AvatarPickerRoute(
        isOnboarding: _$convertMapValue(
                'is-onboarding', state.uri.queryParameters, _$boolConverter) ??
            true,
      );

  String get location => GoRouteData.$location(
        '/auth/avatar',
        queryParams: {
          if (isOnboarding != true) 'is-onboarding': isOnboarding.toString(),
        },
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

T? _$convertMapValue<T>(
  String key,
  Map<String, String> map,
  T? Function(String) converter,
) {
  final value = map[key];
  return value == null ? null : converter(value);
}

bool _$boolConverter(String value) {
  switch (value) {
    case 'true':
      return true;
    case 'false':
      return false;
    default:
      throw UnsupportedError('Cannot convert "$value" into a bool.');
  }
}

RouteBase get $onboardingRoute => GoRouteData.$route(
      path: '/onboarding',
      factory: $OnboardingRouteExtension._fromState,
    );

extension $OnboardingRouteExtension on OnboardingRoute {
  static OnboardingRoute _fromState(GoRouterState state) =>
      const OnboardingRoute();

  String get location => GoRouteData.$location(
        '/onboarding',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $directOnboardingRoute => GoRouteData.$route(
      path: '/onboarding/direct',
      factory: $DirectOnboardingRouteExtension._fromState,
    );

extension $DirectOnboardingRouteExtension on DirectOnboardingRoute {
  static DirectOnboardingRoute _fromState(GoRouterState state) =>
      const DirectOnboardingRoute();

  String get location => GoRouteData.$location(
        '/onboarding/direct',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $cameraRoute => GoRouteData.$route(
      path: '/camera',
      factory: $CameraRouteExtension._fromState,
    );

extension $CameraRouteExtension on CameraRoute {
  static CameraRoute _fromState(GoRouterState state) => const CameraRoute();

  String get location => GoRouteData.$location(
        '/camera',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $ocrGuideRoute => GoRouteData.$route(
      path: '/ocr-guide',
      factory: $OcrGuideRouteExtension._fromState,
    );

extension $OcrGuideRouteExtension on OcrGuideRoute {
  static OcrGuideRoute _fromState(GoRouterState state) => const OcrGuideRoute();

  String get location => GoRouteData.$location(
        '/ocr-guide',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $parentConsentRoute => GoRouteData.$route(
      path: '/consent/parent-email',
      factory: $ParentConsentRouteExtension._fromState,
    );

extension $ParentConsentRouteExtension on ParentConsentRoute {
  static ParentConsentRoute _fromState(GoRouterState state) =>
      const ParentConsentRoute();

  String get location => GoRouteData.$location(
        '/consent/parent-email',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $consentWaitingRoute => GoRouteData.$route(
      path: '/consent/waiting',
      factory: $ConsentWaitingRouteExtension._fromState,
    );

extension $ConsentWaitingRouteExtension on ConsentWaitingRoute {
  static ConsentWaitingRoute _fromState(GoRouterState state) =>
      const ConsentWaitingRoute();

  String get location => GoRouteData.$location(
        '/consent/waiting',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $selfConsentRoute => GoRouteData.$route(
      path: '/consent/self',
      factory: $SelfConsentRouteExtension._fromState,
    );

extension $SelfConsentRouteExtension on SelfConsentRoute {
  static SelfConsentRoute _fromState(GoRouterState state) =>
      const SelfConsentRoute();

  String get location => GoRouteData.$location(
        '/consent/self',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $aiDisclosureRoute => GoRouteData.$route(
      path: '/consent/ai-disclosure',
      factory: $AiDisclosureRouteExtension._fromState,
    );

extension $AiDisclosureRouteExtension on AiDisclosureRoute {
  static AiDisclosureRoute _fromState(GoRouterState state) =>
      const AiDisclosureRoute();

  String get location => GoRouteData.$location(
        '/consent/ai-disclosure',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $photoPreviewRoute => GoRouteData.$route(
      path: '/avatar/:avatarId/photo-preview',
      factory: $PhotoPreviewRouteExtension._fromState,
    );

extension $PhotoPreviewRouteExtension on PhotoPreviewRoute {
  static PhotoPreviewRoute _fromState(GoRouterState state) => PhotoPreviewRoute(
        avatarId: state.pathParameters['avatarId']!,
        $extra: state.extra as String?,
      );

  String get location => GoRouteData.$location(
        '/avatar/${Uri.encodeComponent(avatarId)}/photo-preview',
      );

  void go(BuildContext context) => context.go(location, extra: $extra);

  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: $extra);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: $extra);

  void replace(BuildContext context) =>
      context.replace(location, extra: $extra);
}
