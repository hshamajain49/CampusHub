import 'package:flutter/material.dart';

/// Wraps a list item with a fade + slide-up entry animation, delayed
/// slightly per index — creates a "staggered" cascading effect.
class FadeSlideIn extends StatefulWidget {
  final int index;
  final Widget child;
  const FadeSlideIn({super.key, required this.index, required this.child});

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;

    // Only the first screenful cascades in; items revealed later by
    // scrolling (or with animations disabled) appear immediately.
    final position = Scrollable.maybeOf(context)?.position;
    final scrolled =
        position != null && position.hasPixels && position.pixels > 0;
    if (scrolled || MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
      return;
    }

    // Cap the delay so long lists don't feel sluggish to appear.
    final delay = Duration(milliseconds: 45 * widget.index.clamp(0, 8));
    Future.delayed(delay, () {
      if (mounted) _controller.forward();
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
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
