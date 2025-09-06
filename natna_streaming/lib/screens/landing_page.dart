import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Colors.transparent,
          image: DecorationImage(
            image: AssetImage('assets/background.png'),
            fit: BoxFit.cover,
            opacity: 0.3,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              // margin: const EdgeInsets.only(top: 150),
              width: 300,
              alignment: Alignment.center,
              decoration: BoxDecoration(),
              child: Opacity(
                opacity: 0.7,
                child: Text(
                  "Let’s Protect Our Children From Unwanted Contents And Make NatnaStreaming Our First Choice ",
                  style: TextStyle(fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 96),
              padding: const EdgeInsets.all(8),
              height: 60,
              width: 299,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/google_logo.png', width: 30, height: 30),
                  const SizedBox(width: 10),
                  Text(
                    "Continue with Google",
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.background,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              // margin: const EdgeInsets.symmetric(vertical: 96),
              padding: const EdgeInsets.all(8),
              height: 60,
              width: 299,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/facebook_logo.png',
                    width: 30,
                    height: 30,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Continue with facebook",
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.background,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: 2,
                    color: Color(0XFF5E6470),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text("OR"),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: 2,
                    color: Color(0XFF5E6470),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => context.push("/login"),
              child: Container(
                // margin: const EdgeInsets.symmetric(vertical: 96),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(8),
                height: 60,
                width: 299,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  "Sign in with email",
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
