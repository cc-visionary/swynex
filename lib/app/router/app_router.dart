import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pig_lifecycle_crm/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:pig_lifecycle_crm/features/menu/presentation/screens/menu_screens.dart';
import 'package:pig_lifecycle_crm/features/operations/presentation/screens/inventory_screen.dart';
import 'package:pig_lifecycle_crm/features/financials/presentation/screens/cost_record_screen.dart';
import 'package:pig_lifecycle_crm/features/financials/presentation/screens/sales_record_screen.dart';
import 'package:provider/provider.dart';
import 'package:pig_lifecycle_crm/app/widgets/scaffold_with_nav_bar.dart';
import 'package:pig_lifecycle_crm/features/auth/presentation/providers/auth_provider.dart';

// --- Import all your screen files here ---
// You will need to create these files as simple placeholders for now
import 'package:pig_lifecycle_crm/features/tasks/presentation/screens/my_tasks_screen.dart';
import 'package:pig_lifecycle_crm/features/tasks/presentation/screens/task_board_screen.dart';
import 'package:pig_lifecycle_crm/features/operations/presentation/screens/farm_map_screen.dart';
import 'package:pig_lifecycle_crm/features/operations/presentation/screens/scan_screen.dart';
import 'package:pig_lifecycle_crm/features/pigs/presentation/screens/pigs_list_screen.dart';
import 'package:pig_lifecycle_crm/features/pigs/presentation/screens/pig_detail_screen.dart';
import 'package:pig_lifecycle_crm/features/settings/presentation/screens/farm_management_screen.dart';
import 'package:pig_lifecycle_crm/features/settings/presentation/screens/user_management_screen.dart';
import 'package:pig_lifecycle_crm/features/notifications/notifications_screen.dart';
import 'package:pig_lifecycle_crm/features/auth/presentation/screens/login_screen.dart';

GoRouter createRouter(AuthProvider authProvider) {
  // Define navigator keys
  final rootNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    // This tells go_router to re-evaluate the routes when the user role changes
    refreshListenable: authProvider,

    // The initial route the app will start on
    initialLocation: '/',

    routes: [
      // Top-level route for settings, does not have the bottom nav bar
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/sales',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SalesRecordsScreen(),
      ),
      GoRoute(
        path: '/costs',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const CostRecordsScreen(),
      ),
      GoRoute(
        path: '/inventory',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const InventoryScreen(),
      ),
      GoRoute(
        path: '/farm-map',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const FarmMapScreen(),
      ),
      GoRoute(
        path: '/user-management',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const UserManagementScreen(),
      ),
      GoRoute(
        path: '/farm-management',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const FarmManagementScreen(),
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
                path: '/',
                builder: (context, state) => const DashboardScreen(),
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
                  GoRoute(
                    path: ':pigId', // e.g. /pigs/PIG123
                    builder:
                        (context, state) => PigDetailScreen(
                          pigId: state.pathParameters['pigId']!,
                        ),
                  ),
                ],
              ),
            ],
          ),

          // BRANCH 2: The second tab (Manager/Owner only)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tasks',
                builder: (context, state) => const TaskBoardScreen(),
              ),
            ],
          ),

          // BRANCH 3: The fourth tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/menu',
                builder: (context, state) => const MenuScreen(),
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
