import 'package:flutter/material.dart';

/// Widget Animasi Kemunculan Data Secara Perlahan, Mewah, & Sangat Smooth (Staggered Cascade)
class SmoothStaggeredReveal extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration baseDelay;
  final Duration stepDelay;
  final Duration duration;
  final Offset beginOffset;
  final double beginScale;

  const SmoothStaggeredReveal({
    super.key,
    required this.child,
    this.index = 0,
    this.baseDelay = const Duration(milliseconds: 60),
    this.stepDelay = const Duration(milliseconds: 85),
    this.duration = const Duration(milliseconds: 680),
    this.beginOffset = const Offset(0, 0.14),
    this.beginScale = 0.95,
  });

  @override
  State<SmoothStaggeredReveal> createState() => _SmoothStaggeredRevealState();
}

class _SmoothStaggeredRevealState extends State<SmoothStaggeredReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuart,
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(curved);
    _slide = Tween<Offset>(
      begin: widget.beginOffset,
      end: Offset.zero,
    ).animate(curved);
    _scale = Tween<double>(
      begin: widget.beginScale,
      end: 1.0,
    ).animate(curved);

    final totalDelay =
        widget.baseDelay + (widget.stepDelay * widget.index.clamp(0, 12));
    Future.delayed(totalDelay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: ScaleTransition(
          scale: _scale,
          child: widget.child,
        ),
      ),
    );
  }
}

