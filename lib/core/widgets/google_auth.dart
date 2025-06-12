import 'package:flutter/material.dart';

class GoogleAuthContainer extends StatefulWidget {
  const GoogleAuthContainer({
    super.key,
    this.onTap,
    this.child,
    this.isLoading = false,
  });

  final VoidCallback? onTap;
  final Widget? child;
  final bool isLoading;

  @override
  State<GoogleAuthContainer> createState() => _GoogleAuthContainerState();
}

class _GoogleAuthContainerState extends State<GoogleAuthContainer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        onTap: widget.isLoading ? null : widget.onTap,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: MediaQuery.of(context).size.width * 0.9, // Match CustomField width
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: widget.child ??
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.isLoading)
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      )
                    else
                      Image.asset(
                        "assets/google_auth.png",
                        width: 24,
                        height: 24,
                      ),
                    const SizedBox(width: 8),
                    Text(
                      'Sign in with Google',
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.textTheme.bodyLarge?.color ?? Colors.black87,
                      ),
                    ),
                  ],
                ),
          ),
        ),
      ),
    );
  }
}