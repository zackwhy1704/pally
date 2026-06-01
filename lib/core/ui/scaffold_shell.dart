import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/core/services/feature_flags.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/features/onboarding/presentation/feature_tour.dart';

/// A single tab in the bottom navigation. {@code branchIndex} is the index in
/// the {@code StatefulShellRoute}'s branches array — it stays stable even when
/// tabs are hidden by feature flags. {@code visible} controls whether the tab
/// shows in the bar (hidden branches stay routable via deep-link).
class TabSpec {
  const TabSpec({
    required this.branchIndex,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.visible = true,
  });

  final int branchIndex;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool visible;
}

/// Returns the ordered tab list to render in the bar.
///
/// Order is fixed (Home, Library, Groups, Chat, Me) but Groups is only present
/// when the `groups_enabled` feature flag is on for the current user.
/// Branch indexes correspond to the order branches are declared in
/// `AppShellRouteData`.
List<TabSpec> buildTabs({required bool groupsEnabled}) {
  return [
    const TabSpec(
      branchIndex: 0,
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'Home',
    ),
    const TabSpec(
      branchIndex: 1,
      icon: Icons.menu_book_outlined,
      selectedIcon: Icons.menu_book_rounded,
      label: 'Library',
    ),
    // Groups slot — pilot-gated. The branch must exist in the shell or the
    // index lookup blows up; for now it's hidden and the actual branch is
    // added in Batch 6. When that lands, flip visible to {@code groupsEnabled}.
    if (groupsEnabled)
      const TabSpec(
        branchIndex: 4,
        icon: Icons.groups_outlined,
        selectedIcon: Icons.groups_rounded,
        label: 'Groups',
      ),
    const TabSpec(
      branchIndex: 2,
      icon: Icons.chat_bubble_outline_rounded,
      selectedIcon: Icons.chat_bubble_rounded,
      label: 'Chat',
    ),
    const TabSpec(
      branchIndex: 3,
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
      label: 'Me',
    ),
  ];
}

class ScaffoldShell extends ConsumerWidget {
  const ScaffoldShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsEnabled = isFlagEnabled(ref, FeatureFlags.groupsEnabled);
    final tabs = buildTabs(groupsEnabled: groupsEnabled);

    // Map the shell's current branch index → visible tab index. Defaults to 0
    // if the active branch has no visible tab (e.g. user deep-links to a
    // pilot-only branch with the flag off — the screen still renders but the
    // bar highlights Home so the user can navigate elsewhere).
    final selected = tabs.indexWhere(
        (t) => t.branchIndex == navigationShell.currentIndex);
    final selectedIndex = selected >= 0 ? selected : 0;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        key: featureTourLibraryTabKey,
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.purpleL,
        // Labels shrink fine down to 5 tabs on a 360px phone; force-show keeps
        // them legible.
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        selectedIndex: selectedIndex,
        onDestinationSelected: (visibleIndex) {
          final branchIndex = tabs[visibleIndex].branchIndex;
          navigationShell.goBranch(
            branchIndex,
            initialLocation: branchIndex == navigationShell.currentIndex,
          );
        },
        destinations: [
          for (final tab in tabs)
            NavigationDestination(
              icon: Icon(tab.icon),
              selectedIcon: Icon(tab.selectedIcon, color: AppColors.purple),
              label: tab.label,
            ),
        ],
      ),
    );
  }
}
