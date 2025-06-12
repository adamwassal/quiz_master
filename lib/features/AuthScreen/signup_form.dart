import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quiz_master/core/auth/auth.dart';
import 'package:quiz_master/core/widgets/Field.dart';
import 'package:quiz_master/core/widgets/dotsLoadingSpinner.dart';
import 'package:quiz_master/core/widgets/google_auth.dart';
import 'package:quiz_master/features/MainScreen/mainScreen.dart';

class SignUpForm extends StatefulWidget {
  final PageController pageController;

  const SignUpForm({super.key, required this.pageController});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmController =
      TextEditingController();
  bool _isLoading = false;
  bool _googleLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    emailController.clear();
    passwordController.clear();
    passwordConfirmController.clear();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    passwordConfirmController.dispose();
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

  // Hide loader
  void _hideLoader() {
    if (Navigator.of(context).canPop()) {
      Navigator.pop(context);
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

  // Handle email signup
  Future<void> _handleEmailSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _showLoader();
    });

    try {
      debugPrint(
        'Attempting email sign-up with email: ${emailController.text.trim()}',
      );
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      final passwordConfirm = passwordConfirmController.text.trim();
      final authService = AuthService();
      final user = await authService.signUpWithEmail(
        email: email,
        password: password,
        passwordConfirm: passwordConfirm,
      );
      if (user != null) {
        debugPrint('Email sign-up successful');
        await Future.delayed(
          const Duration(milliseconds: 300),
        ); // Ensure UI updates
        _hideLoader();
        _navigateToMainScreen();
      } else {
        debugPrint('Email sign-up returned null user');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Sign-up failed')));
        }
      }
    } catch (e) {
      debugPrint('Email sign-up failed: $e');
      if (mounted) {
        String errorMessage = 'Sign-up failed';
        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'email-already-in-use':
              errorMessage = 'This email is already registered';
              break;
            case 'invalid-email':
              errorMessage = 'Invalid email address';
              break;
            case 'weak-password':
              errorMessage = 'Password is too weak';
              break;
            default:
              errorMessage = 'Error: ${e.message}';
          }
        } else {
          errorMessage = e.toString().replaceFirst('Exception: ', '');
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hideLoader();
        });
      }
    }
  }

  // Handle Google sign-in
  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _googleLoading = true;
      _showLoader();
    });

    try {
      debugPrint('Attempting Google sign-in');
      final authService = AuthService();
      final user = await authService.signInWithGoogle();
      if (user != null) {
        debugPrint('Google sign-in successful');
        await Future.delayed(
          const Duration(milliseconds: 300),
        ); // Ensure UI updates
        _hideLoader();
        _navigateToMainScreen();
      } else {
        debugPrint('Google sign-in returned null user');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Google sign-in failed')),
          );
        }
      }
    } catch (e) {
      debugPrint('Google sign-in failed: $e');
      if (mounted) {
        String errorMessage = 'Error during Google sign-in';
        if (e is FirebaseAuthException) {
          errorMessage = 'Error: ${e.message}';
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
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
                topLeft: Radius.circular(screenSize.width * 0.1),
                topRight: Radius.circular(screenSize.width * 0.1),
              ),
            ),
            child: Center(
              child: Text(
                'Sign Up',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(screenSize.width * 0.04),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: screenSize.height * 0.02),
                  Text(
                    'Join us and test your knowledge',
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
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
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
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: theme.iconTheme.color?.withOpacity(0.7),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  // Confirm Password Field
                  CustomField(
                    hintText: 'Confirm Password',
                    keyboardType: TextInputType.text,
                    icon: Icons.lock,
                    controller: passwordConfirmController,
                    obscureText: _obscureConfirmPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: theme.iconTheme.color?.withOpacity(0.7),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.03),
                  // SignUp Button
                  _buildButton(
                    context: context,
                    label: 'Sign Up',
                    icon: Icons.person_add,
                    onPressed: _isLoading ? null : _handleEmailSignUp,
                    isLoading: _isLoading,
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  // Google Sign-In Button
                  GoogleAuthContainer(
                    onTap: _googleLoading ? null : _handleGoogleSignIn,
                    isLoading: _googleLoading,
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  // Sign In Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          widget.pageController.animateToPage(
                            0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Text(
                          'Sign In',
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
                  : Icon(icon, color: Colors.white), // White icon color
              label: Text(label),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white, // White text and icon color
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.1,
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
