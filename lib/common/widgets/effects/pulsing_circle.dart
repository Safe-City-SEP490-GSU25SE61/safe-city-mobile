import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class PulsingCircle extends StatefulWidget {
  const PulsingCircle({super.key});

  @override
  State<PulsingCircle> createState() => _PulsingCircleState();
}

class _PulsingCircleState extends State<PulsingCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildRipple(0.0),
          _buildRipple(0.5),
          const CircleAvatar(
            radius: 18,
            backgroundColor: Colors.blueAccent,
            child: Icon(
              Iconsax.routing,
              size: 20,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRipple(double delay) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.4, end: 0.0)
          .animate(CurvedAnimation(parent: _controller, curve: Interval(delay, 1.0))),
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 2.0).animate(
          CurvedAnimation(parent: _controller, curve: Interval(delay, 1.0)),
        ),
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blueAccent.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}
