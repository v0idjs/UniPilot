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
  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    int index = 0;
    if (loc.startsWith('/deadlines')) index = 1;
    else if (loc.startsWith('/gpa')) index = 2;
    else if (loc.startsWith('/campus')) index = 3;
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          switch (i) {
            case 0: context.go('/schedule'); break;
            case 1: context.go('/deadlines'); break;
            case 2: context.go('/gpa'); break;
            case 3: context.go('/campus'); break;
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.calendar_today), label: 'Schedule'),
          NavigationDestination(icon: Icon(Icons.task_alt), label: 'Deadlines'),
          NavigationDestination(icon: Icon(Icons.calculate), label: 'GPA'),
          NavigationDestination(icon: Icon(Icons.map), label: 'Campus'),
        ],
      ),
    );
  }
}
