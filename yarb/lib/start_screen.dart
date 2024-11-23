import 'package:flutter/material.dart';
import 'package:yarb/signup_screen.dart';

import 'login_screen.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image or Illustration Placeholder
          Center(
            child: Image.asset(
              'assets/Gift_Box_Explode.gif', // Replace with your image path
              height: 250,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.image, size: 250),
            ),
          ),
          const SizedBox(height: 30),

          // Description Text
          Text('Join Hedieaty today to Enjoy the Community of gifts',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 40),

          // Login Button
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ), // Adjust color to match the design
            ),
            child: const Text(
              'Log In',
              style: TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(height: 20),

          // Sign Up Button
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>  const SignUpScreen()));
            },
            style: OutlinedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Sign Up',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    ));
  }
}
