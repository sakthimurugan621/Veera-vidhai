import 'package:flutter/material.dart';

/// A staggered fade + slide-up entrance animation.
/// Wrap list items / cards with an increasing [delayMs] for a cascade effect.
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final int delayMs;
  final double offsetY;
  final Duration duration;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.delayMs = 0,
    this.offsetY = 24,
    this.duration = const Duration(milliseconds: 450),
  });

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.duration);
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: Offset(0, widget.offsetY / 100),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
