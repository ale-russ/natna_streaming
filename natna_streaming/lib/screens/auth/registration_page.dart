import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../notifiers/auth_notifier.dart';
import '../../theme/app_colors.dart';
import '../../widgets/auth_wrapper.dart';
import '../../widgets/custom_snackbar.dart';
import '../../widgets/custom_textfield.dart';

class RegistrationPage extends ConsumerStatefulWidget {
  const RegistrationPage({super.key});

  @override
  ConsumerState<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends ConsumerState<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref
          .read(authProvider.notifier)
          .signup(
            _fullNameController.text,
            _emailController.text,
            _passwordController.text,
          );

      CustomSnackbar.show(
        context,
        message: "Registration successful",
        textColor: AppColors.successColor,
      );
      context.push("/login");
    } catch (err) {
      CustomSnackbar.show(
        context,
        message: "Registration Failed: ${err.toString()}",
        textColor: AppColors.errorColor,
      );
    } finally {
      _fullNameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
    return AuthWrapper(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                "Register",
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
                      title: "Full Name",
                      controller: _fullNameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your full name";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
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
                    const SizedBox(height: 24),
                    CustomTextField(
                      title: "Password",
                      controller: _passwordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (_passwordController.text !=
                            _passwordController.text) {
                          return 'Different passwords';
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
                    const SizedBox(height: 24),
                    CustomTextField(
                      title: "Confirm Password",
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      onObscureTextToggle: (isObscure) {
                        setState(() {
                          _obscureConfirmPassword = isObscure;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _register,
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
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Text(
                          "Already have an account?",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w100,
                          ),
                        ),
                        const SizedBox(width: 4),
                        TextButton(
                          onPressed: () => context.push("/login"),
                          child: const Text("Login"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
