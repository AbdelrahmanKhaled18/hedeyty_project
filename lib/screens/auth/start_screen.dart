import 'package:flutter/material.dart';
import 'package:yarb/screens/auth/signup_screen.dart';
import 'package:yarb/screens/auth/login_screen.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('startScreen'),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Gift Image with Fade Transition
            AnimatedScale(
              scale: 1.2,
              duration: const Duration(seconds: 2),
              curve: Curves.easeInOut,
              child: Image.asset(
                'assets/Gift_Box_Explode.gif', // Replace with your image path
                height: 250,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.image, size: 250),
              ),
            ),
            const SizedBox(height: 30),

            // Description Text with Fade-In Animation
            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(seconds: 2),
              child: Text(
                'Join Hedieaty Today!\nEnjoy a Community of Gifts',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade700,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Login Button with Scale Animation
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    _customPageRoute(const LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 100, vertical: 15),
                  backgroundColor: Colors.teal.shade800,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Log In',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Sign-Up Button with Border and Color Animation
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              child: OutlinedButton(
                key: const Key("SignupButton"),
                onPressed: () {
                  Navigator.push(
                    context,
                    _customPageRoute(const SignUpScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 100, vertical: 15),
                  side: BorderSide(color: Colors.teal.shade800, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.teal.shade800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Custom Page Route for Smooth Transitions
  PageRouteBuilder _customPageRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        var offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }
}
