import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:natna_streaming/widgets/custom_snackbar.dart';

import '../models/videos_model.dart';
import '../notifiers/auth_notifier.dart';
import '../screens/auth/login_page.dart';
import '../screens/auth/registration_page.dart';
import '../screens/user/home_page.dart';
import '../screens/landing_page.dart';
import '../screens/user/library_screen.dart';
import '../screens/user/user_account_screen.dart';
import '../screens/video_player/video_player_screen.dart';
import '../theme/app_colors.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authProvider.notifier);
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: "/landing_page",
    routes: [
      GoRoute(
        path: "/landing_page",
        name: 'landing_page',
        builder: (context, state) => const LandingPage(),
      ),
      GoRoute(
        path: "/register",
        name: 'register',
        builder: (context, state) => const RegistrationPage(),
      ),
      GoRoute(
        path: "/login",
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: "/home",
        name: 'home',
        builder: (context, state) => HomePage(),
      ),
      GoRoute(
        path: "/library",
        name: 'library',
        builder: (context, state) => LibraryScreen(),
      ),
      GoRoute(
        path: "/user-account",
        name: 'user-account',
        builder: (context, state) => UserAccountScreen(),
      ),
      GoRoute(
        path: "/video-player",
        name: 'video-player',
        builder: (context, state) {
          final video = state.extra as Video;

          //Redirect to home if invalid videoId
          if (video.videoId.isEmpty || video.videoId.startsWith("UC")) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                context.go("/home");
                CustomSnackbar.show(
                  context,
                  message: "Invalid video ",
                  textColor: AppColors.errorColor,
                );
              }
              // return const HomePage();
            });
          }
          return VideoPlayerScreen(video: video);
        },
      ),
    ],
    redirect: (context, state) {
      final isAuthenticated = authState.value?.isAuthenticated ?? false;
      final isAuthRoute = [
        '/landing_page',
        '/login',
        '/register',
      ].contains(state.matchedLocation);

      // If not authenticated and trying to access protected route
      if (!isAuthenticated && !isAuthRoute) {
        return '/landing_page';
      }

      // If authenticated and trying to access auth routes
      if (isAuthenticated && isAuthRoute) {
        return '/home';
      }

      return null;
    },

    refreshListenable: GoRouterRefreshStream(authNotifier.authChanges),
    // refreshListenable: GoRouterRefreshStream(
    //   ref.watch(authProvider.select((state) => state.user)),
    // ),
  );
});

// Helper class to refresh router on auth state changes
class GoRouterRefreshStream extends ChangeNotifier {
  StreamSubscription<AuthState>? _subscription;

  GoRouterRefreshStream(Stream<AuthState> authStream) {
    _subscription = authStream.listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

// class GoRouterRefreshStream extends ChangeNotifier {
//   GoRouterRefreshStream(Stream<dynamic> stream) {
//     notifyListeners();
//     _subscription = stream.listen((dynamic user) {
//       print('GoRouterRefreshStream: Auth state changed, user=$user');
//       notifyListeners();
//     }, onError: (error) => print('GoRouterRefreshStream: Error=$error'));
//   }

//   StreamSubscription<dynamic>? _subscription;

//   @override
//   void dispose() {
//     _subscription?.cancel();
//     super.dispose();
//   }
// }
