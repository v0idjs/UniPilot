import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'features/schedule/schedule_screen.dart';
import 'features/deadlines/deadline_list_screen.dart';
import 'features/gpa/gpa_screen.dart';
import 'features/campus/campus_screen.dart';

final _router = GoRouter(
  initialLocation: '/schedule',
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Not found')),
    body: Center(child: Text('Route not found: ${state.uri}')),
  ),
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppScaffold(child: child),
      routes: [
        GoRoute(path: '/schedule', builder: (c, s) => const ScheduleScreen()),
        GoRoute(path: '/deadlines', builder: (c, s) => const DeadlineListScreen()),
        GoRoute(path: '/gpa', builder: (c, s) => const GpaScreen()),
        GoRoute(path: '/campus', builder: (c, s) => const CampusScreen()),
      ],
    ),
  ],
);

class UniPilotApp extends StatelessWidget {
  final List<Override> overrides;
  const UniPilotApp({super.key, this.overrides = const []});
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp.router(
        title: 'UniPilot',
        theme: buildLightTheme(),
        darkTheme: buildDarkTheme(),
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AppScaffold extends StatelessWidget {
  final Widget child;
  const AppScaffold({super.key, required this.child});

  static const _tabs = [
    (Icons.calendar_today, 'Schedule', '/schedule'),
    (Icons.task_alt, 'Deadlines', '/deadlines'),
    (Icons.calculate, 'GPA', '/gpa'),
    (Icons.map, 'Campus', '/campus'),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    int index = 0;
    if (loc.startsWith('/deadlines')) index = 1;
    else if (loc.startsWith('/gpa')) index = 2;
    else if (loc.startsWith('/campus')) index = 3;
    void go(int i) => context.go(_tabs[i].$3);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 800) {
          return Scaffold(
            body: Row(children: [
              NavigationRail(
                selectedIndex: index,
                onDestinationSelected: go,
                labelType: NavigationRailLabelType.all,
                destinations: [
                  for (final t in _tabs)
                    NavigationRailDestination(
                      icon: Icon(t.$1),
                      label: Text(t.$2),
                    ),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(child: child),
            ]),
          );
        }
        return Scaffold(
          body: child,
          bottomNavigationBar: NavigationBar(
            selectedIndex: index,
            onDestinationSelected: go,
            destinations: [
              for (final t in _tabs)
                NavigationDestination(icon: Icon(t.$1), label: t.$2),
            ],
          ),
        );
      },
    );
  }
}
