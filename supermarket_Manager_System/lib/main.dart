import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:supermarket_manager_system/presentation/pages/admin_dashboard_page.dart';
import 'package:supermarket_manager_system/presentation/pages/cashier_barcode_scanner_page.dart';
import 'package:supermarket_manager_system/presentation/pages/cashier_open_shift_page.dart';
import 'package:supermarket_manager_system/presentation/pages/login_page.dart';
import 'package:supermarket_manager_system/presentation/pages/manager_dashboard_page.dart';
import 'package:supermarket_manager_system/presentation/pages/role_home_page.dart';
import 'package:supermarket_manager_system/utils/app_session.dart';

void main() {
  usePathUrlStrategy();
  runApp(const SupermarketManagerApp());
}

class SupermarketManagerApp extends StatelessWidget {
  const SupermarketManagerApp({super.key});

  static final GoRouter _router = GoRouter(
    initialLocation: '/login',
    refreshListenable: AppSession.instance,
    redirect: (context, state) {
      final path = state.uri.path;
      final isLoggedIn = AppSession.instance.isLoggedIn;
      final isLogin = path == '/login' || path == '/';

      if (!isLoggedIn && !isLogin) {
        return '/login';
      }
      if (isLoggedIn && isLogin) {
        return _defaultPathForCurrentSession();
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => '/login',
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/admin',
        redirect: (context, state) => '/admin/dashboard',
      ),
      GoRoute(
        path: '/admin/:section',
        pageBuilder: (context, state) => NoTransitionPage(
          key: const ValueKey('admin-shell'),
          child: _buildAdminPage(
            context: context,
            initialTabKey: _resolveAdminTabKey(state),
          ),
        ),
      ),
      GoRoute(
        path: '/admin/:section/:subSection',
        pageBuilder: (context, state) => NoTransitionPage(
          key: const ValueKey('admin-shell'),
          child: _buildAdminPage(
            context: context,
            initialTabKey: _resolveAdminTabKey(state),
          ),
        ),
      ),
      GoRoute(
        path: '/role-home',
        builder: (context, state) {
          return RoleHomePage(
            role: AppSession.instance.role,
            fullName: AppSession.instance.fullName,
          );
        },
      ),
      GoRoute(
        path: '/cashier',
        redirect: (context, state) => '/cashier/open-shift',
      ),
      GoRoute(
        path: '/cashier/open-shift',
        builder: (context, state) => CashierOpenShiftPage(
          fullName: AppSession.instance.fullName,
        ),
      ),
      GoRoute(
        path: '/cashier/barcode-scanner',
        builder: (context, state) => CashierBarcodeScannerPage(
          fullName: AppSession.instance.fullName,
        ),
      ),
      GoRoute(
        path: '/manager',
        redirect: (context, state) => '/manager/dashboard',
      ),
      GoRoute(
        path: '/manager/:section',
        pageBuilder: (context, state) => NoTransitionPage(
          key: const ValueKey('manager-dashboard'),
          child: _buildManagerPage(
            context: context,
            initialTabKey: _resolveManagerTabKey(state),
          ),
        ),
      ),
      GoRoute(
        path: '/manager/:section/:subSection',
        pageBuilder: (context, state) => NoTransitionPage(
          key: const ValueKey('manager-dashboard'),
          child: _buildManagerPage(
            context: context,
            initialTabKey: _resolveManagerTabKey(state),
          ),
        ),
      ),
    ],
  );

  static Widget _buildAdminPage({
    required BuildContext context,
    required String initialTabKey,
  }) {
    final userId = AppSession.instance.userId;
    final fullName = AppSession.instance.fullName;
    if (userId == null) {
      return const LoginPage();
    }
    return AdminDashboardPage(
      key: const ValueKey('admin-dashboard-shell'),
      fullName: fullName,
      userId: userId,
      initialTabKey: initialTabKey,
      onNavigatePath: (path) {
        context.go(path);
      },
      onLogoutRequested: () {
        AppSession.instance.clear();
        context.go('/login');
      },
    );
  }

  static String _resolveAdminTabKey(GoRouterState state) {
    final section = state.pathParameters['section'] ?? 'dashboard';
    final subSection = state.pathParameters['subSection'];

    if (section == 'users') {
      return 'users';
    }
    if (section == 'orders') {
      return 'orders';
    }
    if (section == 'profile' && subSection == 'edit') {
      return 'profile-edit';
    }
    if (section == 'profile') {
      return 'profile';
    }
    return 'dashboard';
  }

  static Widget _buildManagerPage({
    required BuildContext context,
    required String initialTabKey,
  }) {
    final userId = AppSession.instance.userId;
    if (userId == null) {
      return const LoginPage();
    }
    return ManagerDashboardPage(
      key: const ValueKey('manager-dashboard-shell'),
      fullName: AppSession.instance.fullName,
      userId: userId,
      initialTabKey: initialTabKey,
      onNavigatePath: (path) => context.go(path),
      onLogoutRequested: () {
        AppSession.instance.clear();
        context.go('/login');
      },
    );
  }

  static String _resolveManagerTabKey(GoRouterState state) {
    final section = state.pathParameters['section'] ?? 'dashboard';
    final subSection = state.pathParameters['subSection'];
    if (section == 'profile' && subSection == 'edit') {
      return 'profile-edit';
    }
    if (section == 'orders') {
      return 'orders';
    }
    if (section == 'profile') {
      return 'profile';
    }
    return 'dashboard';
  }

  static String _defaultPathForCurrentSession() {
    final roleId = AppSession.instance.roleId;
    final role = AppSession.instance.role.toLowerCase();
    if (roleId == 3 || role.contains('cashier')) {
      return '/cashier/open-shift';
    }
    if (role.contains('admin')) {
      return '/admin/dashboard';
    }
    if (role.contains('manager')) {
      return '/manager/dashboard';
    }
    return '/role-home';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Supermarket Manager',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Segoe UI',
      ),
      routerConfig: _router,
    );
  }
}
