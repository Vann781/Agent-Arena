import 'package:flutter/material.dart';

class AnimatedGradientText extends StatefulWidget {
  final String text;
  final List<Color> colors;
  final double fontSize;
  final FontWeight fontWeight;

  const AnimatedGradientText({
    super.key,
    required this.text,
    required this.colors,
    this.fontSize = 32,
    this.fontWeight = FontWeight.bold,
  });

  @override
  State<AnimatedGradientText> createState() => _AnimatedGradientTextState();
}

class _AnimatedGradientTextState extends State<AnimatedGradientText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: widget.colors,
            stops: [
              _controller.value - 0.2,
              _controller.value,
              _controller.value + 0.2,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            widget.text,
            style: TextStyle(
              fontSize: widget.fontSize,
              fontWeight: widget.fontWeight,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
