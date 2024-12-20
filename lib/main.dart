import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yarb/screens/splash_screen.dart';
import 'notifications.dart';


// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize Firebase Messaging
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Request notification permissions
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    announcement: true,
    carPlay: true,
    criticalAlert: true,
    provisional: true,
  );

  // Initialize FCM background messaging
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const app());
}


class app extends StatelessWidget {
  const app({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home:const SplashScreen());
  }
}
