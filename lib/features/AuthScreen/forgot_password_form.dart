import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quiz_master/core/auth/auth.dart';
import 'package:quiz_master/core/widgets/Field.dart';
import 'package:quiz_master/core/widgets/dotsLoadingSpinner.dart';

class ForgotPasswordForm extends StatefulWidget {
  final PageController pageController;

  const ForgotPasswordForm({super.key, required this.pageController});

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    emailController.clear();
  }

  @override
  void dispose() {
    emailController.dispose();
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

  // Navigate to login page
  void _navigateToLogin() {
    debugPrint('Navigating to login page');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        debugPrint('Widget not mounted, skipping navigation');
      }
    });
  }

  // Handle password reset
  Future<void> _handlePasswordReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _showLoader();
    });

    try {
      debugPrint('Attempting password reset for email: ${emailController.text.trim()}');
      final email = emailController.text.trim();
      final authService = AuthService();
      await authService.sendPasswordResetEmail(email: email);
      debugPrint('Password reset email sent successfully');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent! Check your inbox.')),
        );
        await Future.delayed(const Duration(milliseconds: 300)); // Ensure UI updates
        _hideLoader();
        _navigateToLogin();
      }
    } catch (e) {
      debugPrint('Password reset failed: $e');
      if (mounted) {
        String errorMessage = 'Password reset failed';
        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'user-not-found':
              errorMessage = 'No user found with this email';
              break;
            case 'invalid-email':
              errorMessage = 'Invalid email address';
              break;
            case 'too-many-requests':
              errorMessage = 'Too many requests, please try again later';
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
          _isLoading = false;
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
                'Reset Password',
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
                    'Enter your email to receive a reset link',
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
                  SizedBox(height: screenSize.height * 0.03),
                  // Submit Button
                  _buildButton(
                    context: context,
                    label: 'Send Reset Link',
                    icon: Icons.email,
                    onPressed: _isLoading ? null : _handlePasswordReset,
                    isLoading: _isLoading,
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  // Back to Login
                  TextButton(
                    onPressed: () {
                      widget.pageController.animateToPage(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Text(
                      'Back to Sign In',
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                  horizontal: MediaQuery.of(context).size.width * 0.05,
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