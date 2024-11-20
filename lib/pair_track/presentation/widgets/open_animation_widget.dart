import 'package:flutter/material.dart';

class OpenAnimationWidget extends StatefulWidget {
  final Widget child;
  final double endWidth;
  final Duration duration;

  const OpenAnimationWidget({
    super.key,
    required this.child,
    this.endWidth = 473,
    this.duration = const Duration(seconds: 1),
  });

  @override
  _OpenAnimationWidgetState createState() => _OpenAnimationWidgetState();
}

class _OpenAnimationWidgetState extends State<OpenAnimationWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _widthAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _widthAnimation = Tween<double>(begin: 0, end: widget.endWidth).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _widthAnimation,
        builder: (context, child) {
          return SizedBox(
            width: _widthAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}