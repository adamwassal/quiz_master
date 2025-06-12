import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quiz_master/core/widgets/dotsLoadingSpinner.dart';
import 'package:quiz_master/features/ProfilePage/editAccount.dart';
import 'package:quiz_master/features/AuthScreen/authScreen.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // Get the current user from FirebaseAuth
  Future<User?> getCurrentUser() async {
    final _auth = FirebaseAuth.instance;
    return _auth.currentUser;
  }

  // Show sign-out confirmation dialog
  Future<void> _confirmSignOut(BuildContext context) async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldSignOut == true) {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      // Use SafeArea to avoid notches and status bars
      body: SafeArea(
        child: Column(
          children: [
            // Header with gradient background
            Container(
              height: screenSize.height * 0.1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.primaryColor, theme.primaryColorDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Text(
                  'My Profile',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Main content
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(screenSize.width * 0.04),
                child: FutureBuilder<User?>(
                  future: getCurrentUser(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // Full-screen CustomLoadingSpinner
                      return const Center(child: DotsLoadingSpinner());
                    } else if (snapshot.hasError) {
                      return _buildErrorWidget(context);
                    } else if (!snapshot.hasData || snapshot.data == null) {
                      return const Center(child: Text('No user signed in'));
                    }

                    final user = snapshot.data!;
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: screenSize.height * 0.02),
                          // Profile card
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(screenSize.width * 0.04),
                              child: Column(
                                children: [
                                  // Profile Avatar with only person icon
                                  CircleAvatar(
                                    radius: screenSize.width * 0.15,
                                    backgroundColor: Colors.grey[200],
                                    child: Icon(
                                      Icons.person,
                                      size: screenSize.width * 0.2,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(height: screenSize.height * 0.02),
                                  // User Name
                                  Text(
                                    user.displayName ??
                                        (user.email != null
                                            ? user.email!.split('@')[0]
                                            : 'Guest User'),
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: screenSize.height * 0.01),
                                  // User Email
                                  Text(
                                    user.email ?? 'No email provided',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(height: screenSize.height * 0.03),
                                  // Edit Account Button
                                  _buildButton(
                                    context: context,
                                    label: 'Edit Account',
                                    icon: Icons.edit,
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const EditAccountPage(),
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(height: screenSize.height * 0.02),
                                  // Sign Out Button
                                  _buildButton(
                                    context: context,
                                    label: 'Sign Out',
                                    icon: Icons.logout,
                                    isOutlined: true,
                                    onPressed: () => _confirmSignOut(context),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: screenSize.height * 0.02),
                          // Settings Section
                          const Divider(),
                          ListTile(
                            leading: Icon(Icons.settings, color: theme.primaryColor),
                            title: const Text('Settings'),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              print('Settings Pressed');
                              // Navigate to settings page (to be implemented)
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      // Floating Action Button for quick profile editing
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditAccountPage()),
          );
        },
        child: const Icon(Icons.edit),
        tooltip: 'Edit Profile',
      ),
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