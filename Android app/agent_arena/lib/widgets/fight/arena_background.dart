import 'package:flutter/material.dart';

class ArenaBackground extends StatelessWidget {
  const ArenaBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A0E21), Color(0xFF1A0A2E), Color(0xFF0A0E21)],
        ),
      ),
      child: CustomPaint(painter: _ArenaPainter(), size: Size.infinite),
    );
  }
}

class _ArenaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF7C4DFF).withValues(alpha: 0.06)
      ..strokeWidth = 1;

    // Grid lines
    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Center circle
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      80,
      Paint()
        ..color = const Color(0xFF7C4DFF).withValues(alpha: 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
