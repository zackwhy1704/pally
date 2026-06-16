import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

/// Nav order: Home(0) | Library(1) | Groups(2) | Me(3)
///
/// Chat tab has been removed from the nav — chat is reachable via Home and
/// Library (tap any Mochi avatar). The Chat branch (index 4) is still declared
/// in the router for backward-compatibility with any existing deep links.
List<TabSpec> buildTabs() {
  return const [
    TabSpec(
      branchIndex: 0,
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'Home',
    ),
    TabSpec(
      branchIndex: 1,
      icon: Icons.menu_book_outlined,
      selectedIcon: Icons.menu_book_rounded,
      label: 'Library',
    ),
    TabSpec(
      branchIndex: 2,
      icon: Icons.groups_outlined,
      selectedIcon: Icons.groups_rounded,
      label: 'Groups',
    ),
    TabSpec(
      branchIndex: 3,
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
      label: 'Me',
    ),
  ];
}

class ScaffoldShell extends StatelessWidget {
  const ScaffoldShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final tabs = buildTabs();

    // Map the shell's current branch index → visible tab index. Defaults to 0
    // if the active branch has no visible tab (e.g. deep-link to the hidden
    // Chat branch — the screen still renders but the bar highlights Home).
    final selected = tabs.indexWhere(
        (t) => t.branchIndex == navigationShell.currentIndex);
    final selectedIndex = selected >= 0 ? selected : 0;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        key: featureTourLibraryTabKey,
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.purpleL,
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
