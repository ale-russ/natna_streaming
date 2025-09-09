import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../utils/auth_utils.dart';

class GradientScaffold extends ConsumerWidget {
  const GradientScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavbar,
  });

  final Widget body;
  final AppBar? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavbar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.read(routerProvider);
    final currentPath = GoRouterState.of(context).matchedLocation;

    // Map routes to indices
    const routeToIndex = {'/home': 0, '/library': 1, '/user-account': 2};

    // Determine current index based on route
    int currentIndex = routeToIndex[currentPath] ?? 0;

    // watch auth state dynamically
    final isLoggedIn =
        AuthUtils.getToken() != null && AuthUtils.getUserId() != null;

    return Scaffold(
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: Container(child: body),
      bottomNavigationBar: isLoggedIn
          ? bottomNavbar ??
                BottomNavigationBar(
                  backgroundColor: AppColors.primary,
                  elevation: 4,
                  selectedItemColor: AppColors.onPrimary,
                  unselectedItemColor: AppColors.borderColor,
                  items: [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: "Home",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.music_note),
                      label: "Library",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.verified_user),
                      label: "Account",
                    ),
                  ],
                  currentIndex: currentIndex,
                  onTap: (index) {
                    switch (index) {
                      case 0:
                        router.go("/home");
                        break;
                      case 1:
                        router.go("/library");
                        break;
                      case 2:
                        router.go("/user-account");
                        break;
                    }
                  },
                )
          : null,
    );
  }
}
