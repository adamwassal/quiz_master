import 'package:flutter/material.dart';
import 'package:quiz_master/core/contants.dart';

class DotsLoadingSpinner extends StatefulWidget {
  final Color color;
  final double size;

  const DotsLoadingSpinner({
    Key? key,
    this.color = AppConstants.primaryColor,
    this.size = 50.0,
  }) : super(key: key);

  @override
  DotsLoadingSpinnerState createState() => DotsLoadingSpinnerState();
}

class DotsLoadingSpinnerState extends State<DotsLoadingSpinner> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation1, _animation2, _animation3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _animation1 = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.33, curve: Curves.easeInOut),
      ),
    );
    _animation2 = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.33, 0.66, curve: Curves.easeInOut),
      ),
    );
    _animation3 = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.66, 1.0, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildDot(_animation1),
          const SizedBox(width: 8),
          _buildDot(_animation2),
          const SizedBox(width: 8),
          _buildDot(_animation3),
        ],
      ),
    );
  }

  Widget _buildDot(Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -animation.value),
          child: Container(
            width: widget.size / 5,
            height: widget.size / 5,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}