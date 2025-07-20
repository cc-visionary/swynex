import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pig_lifecycle_crm/app/widgets/scaffold_with_nav_bar.dart';
import 'package:pig_lifecycle_crm/features/auth/providers/auth_provider.dart';

// --- Import all your screen files here ---
// You will need to create these files as simple placeholders for now
import 'package:pig_lifecycle_crm/features/dashboard/screens/my_tasks_screen.dart';
import 'package:pig_lifecycle_crm/features/dashboard/screens/task_board_screen.dart';
import 'package:pig_lifecycle_crm/features/operations/farm_map_screen.dart';
import 'package:pig_lifecycle_crm/features/operations/scan_screen.dart';
import 'package:pig_lifecycle_crm/features/operations/reports_screen.dart';
import 'package:pig_lifecycle_crm/features/lifecycle_crm/screens/pigs_list_screen.dart';
import 'package:pig_lifecycle_crm/features/lifecycle_crm/screens/pig_profile_screen.dart';
import 'package:pig_lifecycle_crm/features/settings/screens/settings_screen.dart';
import 'package:pig_lifecycle_crm/features/settings/screens/farm_management_screen.dart';
import 'package:pig_lifecycle_crm/features/settings/screens/user_management_screen.dart';
import 'package:pig_lifecycle_crm/features/notifications/notifications_screen.dart';
import 'package:pig_lifecycle_crm/features/auth/screens/login_screen.dart';

GoRouter createRouter(AuthProvider authProvider) {
  // Define navigator keys
  final rootNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    // This tells go_router to re-evaluate the routes when the user role changes
    refreshListenable: authProvider,

    // The initial route the app will start on
    initialLocation: '/my-tasks',

    routes: [
      // Top-level route for settings, does not have the bottom nav bar
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'users', // Navigates to /settings/users
            builder: (context, state) => const UserManagementScreen(),
          ),
          GoRoute(
            path: 'management', // Navigates to /settings/management
            builder: (context, state) => const FarmManagementScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const NotificationsScreen(),
      ),

      // The main application shell with role-based bottom navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          // The shell contains the Scaffold with the BottomNavigationBar
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // BRANCH 0: The first tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/my-tasks', // Worker's home
                builder: (context, state) => const MyTasksScreen(),
              ),
              GoRoute(
                path: '/task-board', // Manager/Owner's home
                builder: (context, state) => const TaskBoardScreen(),
              ),
            ],
          ),

          // BRANCH 1: The second tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/pigs',
                builder: (context, state) => const PigsListScreen(),
                routes: [
                  // This is a sub-route, it will show on top of the pigs list
                  GoRoute(
                    path: ':pigId', // e.g., /pigs/PIG123
                    builder:
                        (context, state) => PigProfileScreen(
                          pigId: state.pathParameters['pigId']!,
                        ),
                  ),
                ],
              ),
              GoRoute(
                path: '/scan', // Worker's scan page
                builder:
                    (context, state) =>
                        const ScanScreen(), // Create a placeholder ScanScreen
              ),
            ],
          ),

          // BRANCH 2: The second tab (Manager/Owner only)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reports',
                builder: (context, state) => const ReportsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    // --- REDIRECT LOGIC ---
    // This is where your "plug-and-play" auth logic lives.
    redirect: (BuildContext context, GoRouterState state) {
      final userRole = context.read<AuthProvider>().userRole;
      final isManagerOrHigher = context.read<AuthProvider>().isManagerOrHigher;

      // --- PLUG-IN REAL AUTH LOGIC HERE IN THE FUTURE ---
      // final bool loggedIn = authProvider.isLoggedIn;
      // if (!loggedIn) return '/login';
      // ----------------------------------------------------

      // Handle role-based home screen redirection
      if (state.matchedLocation == '/my-tasks' && isManagerOrHigher) {
        return '/task-board'; // If a manager lands on worker home, send them to theirs
      }
      if (state.matchedLocation == '/task-board' &&
          userRole == UserRole.worker) {
        return '/my-tasks'; // If a worker lands on manager home, send them to theirs
      }

      // If everything is fine, don't redirect.
      return null;
    },
  );
}
