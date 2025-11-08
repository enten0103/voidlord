import 'package:flutter/material.dart';
import '../widgets/app_title_bar.dart';

class NavItem {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  const NavItem({required this.icon, this.selectedIcon, required this.label});
}

class ResponsiveScaffold extends StatelessWidget {
  final String title;
  final List<Widget> actions;
  final List<Widget> pages;
  final List<NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final double railBreakpoint;
  final double railExtendedBreakpoint;

  const ResponsiveScaffold({
    super.key,
    required this.title,
    required this.actions,
    required this.pages,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.railBreakpoint = 800,
    this.railExtendedBreakpoint = 1200,
  }) : assert(
         pages.length == items.length,
         'pages and items length must be equal',
       );

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final useRail = width >= railBreakpoint;
    final railExtended = width >= railExtendedBreakpoint;

    if (useRail) {
      return Scaffold(
        appBar: AppTitleBar(title: title, actions: actions),
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                selectedIndex: selectedIndex,
                onDestinationSelected: onSelected,
                groupAlignment: -1,
                extended: railExtended,
                labelType: railExtended
                    ? NavigationRailLabelType.none
                    : NavigationRailLabelType.selected,
                destinations: [
                  for (final item in items)
                    NavigationRailDestination(
                      icon: Icon(item.icon),
                      selectedIcon: item.selectedIcon != null
                          ? Icon(item.selectedIcon)
                          : null,
                      label: Text(item.label),
                    ),
                ],
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: pages[selectedIndex]),
          ],
        ),
      );
    }

    // 窄屏：底部导航
    return Scaffold(
      appBar: AppTitleBar(title: title, actions: actions),
      body: pages[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onSelected,
        destinations: [
          for (final item in items)
            NavigationDestination(
              icon: Icon(item.icon),
              selectedIcon: item.selectedIcon != null
                  ? Icon(item.selectedIcon)
                  : null,
              label: item.label,
            ),
        ],
      ),
    );
  }
}
