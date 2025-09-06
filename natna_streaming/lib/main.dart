import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notifiers/auth_notifier.dart';
import 'screens/landing_page.dart';
import 'routes/app_routes.dart';
import 'theme/app_colors.dart';
import 'widgets/gradient_scaffold.dart';
import "./utils/auth_utils.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AuthUtils.init();
  final token = AuthUtils.getUserId();
  final userId = AuthUtils.getToken();
  runApp(
    ProviderScope(
      overrides: [
        // Initialize authProvider with token and userId
        if (token != null && userId != null)
          authProvider.overrideWith(() {
            final notifier = AuthNotifier();
            return notifier;
          }),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      theme: getAppTheme(),
    );
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(body: LandingPage());
  }
}
