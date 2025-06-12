import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quiz_master/core/widgets/dotsLoadingSpinner.dart';
import 'package:quiz_master/features/MainScreen/mainScreen.dart';
import 'package:quiz_master/features/AuthScreen/authScreen.dart';
import 'package:quiz_master/features/onBoardingScreen/onBoardingScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final storage = const FlutterSecureStorage();
  final FirebaseAuth auth = FirebaseAuth.instance;
  
  bool _isLoading = true;
  bool _isOnBoarded = false;
  User? _user;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // First, enforce minimum splash screen duration
      await Future.delayed(const Duration(seconds: 2));
      
      if (!mounted) return;
      
      // Then check onboarding status and auth state
      final isOnBoarded = await storage.read(key: 'onBoardingCompleted');
      final user = auth.currentUser;
      
      if (!mounted) return;
      
      setState(() {
        _isOnBoarded = isOnBoarded == 'true';
        _user = user;
        _isLoading = false;
      });
      
      // Navigate after state is updated
      _navigateToNextScreen();
      
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      _navigateToNextScreen();
    }
  }

  void _navigateToNextScreen() {
    if (!mounted) return;

    if (_error != null) {
      print('Navigating to AuthScreen due to error: $_error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $_error')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
      return;
    }

    if (_isOnBoarded) {
      if (_user != null) {
        print('Navigating to HomeScreen (user logged in)');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        print('Navigating to AuthScreen (no user)');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );
      }
    } else {
      print('Navigating to OnBoardingScreen');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnBoardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          // Full-screen loader with semi-transparent background
          Container(
            color: Colors.transparent,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading logo: $error');
                      return const Icon(
                        Icons.error,
                        size: 150,
                        color: Colors.white,
                      );
                    },
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Quiz Master',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_isLoading) const DotsLoadingSpinner(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}