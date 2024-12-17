import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:yarb/screens/auth/start_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSplashScreen(
        splash: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie Animation without a Circle
            Lottie.asset(
              "assets/Lottie/Animation - 1729767849417.json",
              width: 300,
              height: 300,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 30),

            // Welcome Text
            Text(
              "Welcome to Hedieaty",
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade700,
              ),
            ),
            const SizedBox(height: 10),

            // Subtitle Text
            Text(
              "Make every gift special!",
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        splashIconSize: 400,
        nextScreen: const StartScreen(),
        splashTransition: SplashTransition.fadeTransition,
        animationDuration: const Duration(seconds: 3),
        duration: 4000,
      ),
    );
  }
}
