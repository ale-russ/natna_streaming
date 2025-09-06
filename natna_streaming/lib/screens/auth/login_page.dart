import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../notifiers/auth_notifier.dart';
import '../../theme/app_colors.dart';
import '../../widgets/auth_wrapper.dart';
import '../../widgets/custom_snackbar.dart';
import '../../widgets/custom_textfield.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref
          .read(authProvider.notifier)
          .login(_emailController.text, _passwordController.text);
    } catch (err) {
      log("error in login: $err");
      if (mounted) {
        log("error in mounted: $err");
        CustomSnackbar.show(
          context,
          message: err.toString(),
          textColor: AppColors.errorColor,
        );
      }
    } finally {
      // _emailController.clear();
      // _passwordController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
    return AuthWrapper(
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 32.0),
            child: Text(
              "Login",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    title: "Email",
                    controller: _emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your email address";
                      }
                      if (!value.contains("@")) {
                        return "Please enter a valid email";
                      }
                      return null;
                    },
                    suffixIcon: Icon(FontAwesomeIcons.user, size: 10),
                  ),

                  const SizedBox(height: 48),
                  CustomTextField(
                    title: "Password",
                    controller: _passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }

                      return null;
                    },
                    onObscureTextToggle: (isObscured) {
                      setState(() {
                        _obscurePassword = isObscured;
                      });
                    },
                    obscureText: _obscurePassword,
                  ),

                  const SizedBox(height: 48),

                  // const SizedBox(height: 60),
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(6),
                      ),
                    ),
                    child: (isLoading)
                        ? Center(child: CircularProgressIndicator())
                        : Text(
                            "Submit",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  const SizedBox(height: 60),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account?",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w100,
                        ),
                      ),
                      const SizedBox(width: 4),
                      TextButton(
                        onPressed: () => context.push("/register"),
                        child: const Text("Register"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
