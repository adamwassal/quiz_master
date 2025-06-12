import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:quiz_master/features/splashScreen/splashScreen.dart';
import 'package:quiz_master/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization failed: $e');
  }
  runApp(const QuizMasterApp());
}

class QuizMasterApp extends StatelessWidget {
  const QuizMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quiz Master',
      theme: ThemeData(
        primaryColor: const Color(0xFF6200EE),
        buttonTheme: const ButtonThemeData(
          buttonColor: Color(0xFF6366F1),
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}