import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../widgets/gradient_scaffold.dart';

class UserAccountScreen extends ConsumerWidget {
  const UserAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GradientScaffold(
      body: Center(child: Text("This is the user account screen")),
    );
  }
}
