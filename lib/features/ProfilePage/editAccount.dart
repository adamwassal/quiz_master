import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quiz_master/core/widgets/dotsLoadingSpinner.dart';
import 'package:quiz_master/core/widgets/Field.dart';

class EditAccountPage extends StatefulWidget {
  const EditAccountPage({super.key});

  @override
  _EditAccountPageState createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  // Get the current user from FirebaseAuth
  Future<User?> getCurrentUser() async {
    final _auth = FirebaseAuth.instance;
    return _auth.currentUser;
  }

  @override
  void initState() {
    super.initState();
    // Initialize email field with current user data
    getCurrentUser().then((user) {
      if (user != null && mounted) {
        setState(() {
          _emailController.text = user.email ?? '';
        });
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Confirm save changes with a dialog
  Future<bool> _confirmSaveChanges() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Save Changes'),
            content: const Text('Are you sure you want to save these changes?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Save', style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
        ) ??
        false;
  }

  // Save changes to user account
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final shouldSave = await _confirmSaveChanges();
    if (!shouldSave) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await getCurrentUser();
      if (user != null) {
        // Re-authenticate user for sensitive operations
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _currentPasswordController.text,
        );
        await user.reauthenticateWithCredential(credential);

        // Update email if changed
        if (_emailController.text.isNotEmpty && _emailController.text != user.email) {
          await user.updateEmail(_emailController.text);
        }

        // Update password if provided
        if (_newPasswordController.text.isNotEmpty) {
          await user.updatePassword(_newPasswordController.text);
        }

        // Refresh user data
        await user.reload();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account updated successfully')),
          );
          Navigator.pop(context); // Return to ProfilePage
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No user signed in')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Error updating account';
        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'email-already-in-use':
              errorMessage = 'The email address is already in use';
              break;
            case 'invalid-credential':
              errorMessage = 'Incorrect current password';
              break;
            case 'requires-recent-login':
              errorMessage = 'Please sign out and sign in again to update your account';
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
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        Scaffold(
          // Custom AppBar with gradient
          appBar: AppBar(
            title: const Text(
              'Edit Account',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.primaryColor, theme.primaryColorDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            elevation: 4,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(screenSize.width * 0.04),
              child: FutureBuilder<User?>(
                future: getCurrentUser(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: DotsLoadingSpinner());
                  } else if (snapshot.hasError) {
                    return _buildErrorWidget(context);
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    return const Center(child: Text('No user signed in'));
                  }

                  return SingleChildScrollView(
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(screenSize.width * 0.04),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: screenSize.height * 0.02),
                              // Email Field
                              CustomField(
                                controller: _emailController,
                                hintText: 'Email',
                                icon: Icons.email,
                                keyboardType: TextInputType.emailAddress,
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
                              // Current Password Field
                              CustomField(
                                controller: _currentPasswordController,
                                hintText: 'Current Password',
                                icon: Icons.lock,
                                obscureText: _obscureCurrentPassword,
                                keyboardType: TextInputType.text,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your current password';
                                  }
                                  return null;
                                },
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureCurrentPassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: theme.iconTheme.color?.withOpacity(0.7),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureCurrentPassword = !_obscureCurrentPassword;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(height: screenSize.height * 0.02),
                              // New Password Field
                              CustomField(
                                controller: _newPasswordController,
                                hintText: 'New Password (optional)',
                                icon: Icons.lock,
                                obscureText: _obscureNewPassword,
                                keyboardType: TextInputType.text,
                                validator: (value) {
                                  if (value != null && value.isNotEmpty && value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureNewPassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: theme.iconTheme.color?.withOpacity(0.7),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureNewPassword = !_obscureNewPassword;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(height: screenSize.height * 0.02),
                              // Confirm Password Field
                              CustomField(
                                controller: _confirmPasswordController,
                                hintText: 'Confirm New Password (optional)',
                                icon: Icons.lock,
                                obscureText: _obscureConfirmPassword,
                                keyboardType: TextInputType.text,
                                validator: (value) {
                                  if (value != null &&
                                      value.isNotEmpty &&
                                      value != _newPasswordController.text) {
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
                              // Save Button
                              _buildButton(
                                context: context,
                                label: 'Save Changes',
                                icon: Icons.save,
                                onPressed: _saveChanges,
                              ),
                              SizedBox(height: screenSize.height * 0.02),
                              // Cancel Button
                              _buildButton(
                                context: context,
                                label: 'Cancel',
                                icon: Icons.cancel,
                                isOutlined: true,
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        // Full-screen loading overlay during save operation
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(child: DotsLoadingSpinner()),
          ),
      ],
    );
  }

  // Build a custom button with modern styling
  Widget _buildButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    bool isOutlined = false,
  }) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      child: isOutlined
          ? OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
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
              icon: Icon(icon),
              label: Text(label),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05,
                  vertical: 14,
                ),
                textStyle: const TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                shadowColor: theme.primaryColor.withOpacity(0.3),
              ),
            ),
    );
  }

  // Build error widget with retry button
  Widget _buildErrorWidget(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Error loading user data', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            // Trigger rebuild to retry fetching user data
            (context as Element).markNeedsBuild();
          },
          child: const Text('Retry'),
        ),
      ],
    );
  }
}