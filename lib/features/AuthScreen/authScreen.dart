import 'package:flutter/material.dart';
import 'login_form.dart';
import 'signup_form.dart';
import 'forgot_password_form.dart';

class AuthScreen extends StatefulWidget {
  final int initialPage;

  const AuthScreen({super.key, this.initialPage = 0});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late int currentPage;
  late final PageController pageController;

  @override
  void initState() {
    super.initState();
    currentPage = widget.initialPage;
    pageController = PageController(initialPage: widget.initialPage);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
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
                colors: [Color(0xFF6366F1), Color(0xFF9333EA)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Logo and title at the top
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/logo.png',
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
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
                    ],
                  ),
                ),

                // Expanded form area
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    margin: const EdgeInsets.only(top: 20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: PageView(
                        controller: pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        onPageChanged: (index) {
                          setState(() {
                            currentPage = index;
                          });
                        },
                        children: [
                          SingleChildScrollView(child: LoginForm(pageController: pageController)),
                          SingleChildScrollView(child: SignUpForm(pageController: pageController)),
                          SingleChildScrollView(child: ForgotPasswordForm(pageController: pageController)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}