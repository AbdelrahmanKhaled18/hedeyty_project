import "package:animated_splash_screen/animated_splash_screen.dart";
import "package:flutter/material.dart";
import "package:lottie/lottie.dart";
import "package:yarb/start_screen.dart";

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Column(
        children: [
          Center(
            child: SizedBox(
              width: 300, // Set a specific width
              height: 300, // Set a specific height
              child: LottieBuilder.asset(
                  "assets/Lottie/Animation - 1729767849417.json"),
            ),
          ),
          Text(
            "Welcome to Hedieaty",
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          )
        ],
      ),
      splashIconSize: 400,
      nextScreen: const StartScreen(),
    );
  }
}
