import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quiz_master/core/auth/auth.dart';
import 'package:quiz_master/core/widgets/Field.dart';
import 'package:quiz_master/core/widgets/dotsLoadingSpinner.dart';
import 'package:quiz_master/core/widgets/google_auth.dart';
import 'package:quiz_master/features/MainScreen/mainScreen.dart';

class LoginForm extends StatefulWidget {
  final PageController pageController;

  const LoginForm({super.key, required this.pageController});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _loading = false;
  bool _googleLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    emailController.clear();
    passwordController.clear();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Show loading overlay
  void _showLoader() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Stack(
        children: [
          Container(color: Colors.black.withOpacity(0.5)),
          const Center(child: DotsLoadingSpinner()),
        ],
      ),
    );
  }

  // Hide loading overlay
  void _hideLoader() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  // Navigate to MainScreen
  void _navigateToMainScreen() {
    debugPrint('Navigating to MainScreen');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        debugPrint('Widget not mounted, skipping navigation');
      }
    });
  }

  // Handle email login
  Future<void> _handleEmailLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _showLoader();
    });

    try {
      debugPrint('Attempting email login with email: ${emailController.text.trim()}');
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      final authService = AuthService();
      await authService.loginWithEmail(email: email, password: password);
      debugPrint('Email login successful');
      await Future.delayed(const Duration(milliseconds: 300)); // Ensure UI updates
      _hideLoader();
      _navigateToMainScreen();
    } catch (e) {
      debugPrint('Email login failed: $e');
      if (mounted) {
        String errorMessage = 'Login failed';
        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'user-not-found':
              errorMessage = 'No user found with this email';
              break;
            case 'wrong-password':
              errorMessage = 'Incorrect password';
              break;
            case 'invalid-email':
              errorMessage = 'Invalid email address';
              break;
            case 'too-many-requests':
              errorMessage = 'Too many attempts, please try again later';
              break;
            default:
              errorMessage = 'Error: ${e.message}';
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _hideLoader();
        });
      }
    }
  }

  // Handle Google login
  Future<void> _handleGoogleLogin() async {
    setState(() {
      _googleLoading = true;
      _showLoader();
    });

    try {
      debugPrint('Attempting Google login');
      final authService = AuthService();
      final user = await authService.signInWithGoogle();
      if (user != null) {
        debugPrint('Google login successful');
        await Future.delayed(const Duration(milliseconds: 300)); // Ensure UI updates
        _hideLoader();
        _navigateToMainScreen();
      } else {
        debugPrint('Google login returned null user');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Google login failed')),
          );
        }
      }
    } catch (e) {
      debugPrint('Google login failed: $e');
      if (mounted) {
        String errorMessage = 'Error during Google login';
        if (e is FirebaseAuthException) {
          errorMessage = 'Error: ${e.message}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _googleLoading = false;
          _hideLoader();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Gradient header
          Container(
            height: screenSize.height * 0.1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.primaryColor, theme.primaryColorDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(screenSize.width * 0.1),
                bottomRight: Radius.circular(screenSize.width * 0.1),
              ),
            ),
            child: Center(
              child: Text(
                'Welcome Back!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(screenSize.width * 0.05),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: screenSize.height * 0.02),
                  Text(
                    'Sign in to continue your quiz journey',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.03),
                  // Email Field
                  CustomField(
                    hintText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    icon: Icons.email,
                    controller: emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  // Password Field
                  CustomField(
                    hintText: 'Password',
                    keyboardType: TextInputType.text,
                    icon: Icons.lock,
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        color: theme.iconTheme.color?.withOpacity(0.7),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        widget.pageController.animateToPage(
                          2,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.03),
                  // Login Button
                  _buildButton(
                    context: context,
                    label: 'Login',
                    icon: Icons.login,
                    onPressed: _loading ? null : _handleEmailLogin,
                    isLoading: _loading,
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  // Google Sign-In Button
                  GoogleAuthContainer(
                    onTap: _googleLoading ? null : _handleGoogleLogin,
                    isLoading: _googleLoading,
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account?',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          widget.pageController.animateToPage(
                            1,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build a custom button with modern styling
  Widget _buildButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool isOutlined = false,
  }) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      child: isOutlined
          ? OutlinedButton.icon(
              onPressed: onPressed,
              icon: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(icon),
              label: Text(label),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05,
                  vertical: 14,
                ),
                textStyle: const TextStyle(fontSize: 16),
                side: BorderSide(color: theme.colorScheme.error),
                foregroundColor: theme.colorScheme.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
          : ElevatedButton.icon(
              onPressed: onPressed,
              icon: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(icon, color: Colors.white), // Explicitly set icon color to white
              label: Text(label),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white, // Ensure text and icon are white
                padding: EdgeInsets.symmetric(
                  vertical: 14,
                ),
                textStyle: const TextStyle(fontSize: 16, color: Colors.white),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                shadowColor: theme.primaryColor.withOpacity(0.3),
              ),
            ),
    );
  }
}