import 'package:flutter/material.dart';

class ArenaBackground extends StatelessWidget {
  const ArenaBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, 0.3),
          radius: 1.2,
          colors: [Color(0xFF1A1A3E), Color(0xFF0D0D1A), Color(0xFF05050D)],
        ),
      ),
      child: CustomPaint(painter: _ArenaPainter(), size: Size.infinite),
    );
  }
}

class _ArenaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Stage floor — perspective trapezoid
    final floorPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF2A2A4A).withValues(alpha: 0.3),
          const Color(0xFF1A1A2E).withValues(alpha: 0.6),
        ],
      ).createShader(Rect.fromLTWH(0, h * 0.7, w, h * 0.3));

    final floorPath = Path()
      ..moveTo(w * 0.1, h * 0.7)
      ..lineTo(w * 0.9, h * 0.7)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(floorPath, floorPaint);

    // Floor outline
    final outlinePaint = Paint()
      ..color = const Color(0xFF3A3A5A).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(floorPath, outlinePaint);

    // VS text in center
    final vsText = "VS";
    final vsBuilder = TextPainter(
      text: TextSpan(
        text: vsText,
        style: TextStyle(
          fontSize: 72,
          fontWeight: FontWeight.w900,
          color: const Color(0xFFFFCC00).withValues(alpha: 0.12),
          letterSpacing: 12,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    vsBuilder.layout();
    vsBuilder.paint(
      canvas,
      Offset(w / 2 - vsBuilder.width / 2, h * 0.35 - vsBuilder.height / 2),
    );

    // Left banner (Rambahaur - yellow)
    _drawBanner(canvas, 0, h * 0.15, h * 0.4, const Color(0xFFFFCC00), 'R');

    // Right banner (Shaam Bahadur - magenta)
    _drawBanner(
      canvas,
      w - 10,
      h * 0.15,
      h * 0.4,
      const Color(0xFFFF0055),
      'S',
      right: true,
    );
  }

  void _drawBanner(
    Canvas canvas,
    double x,
    double y,
    double height,
    Color color,
    String initial, {
    bool right = false,
  }) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    const width = 6.0;

    final r = Rect.fromLTWH(right ? x - width : x, y, width, height);
    canvas.drawRect(r, paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: initial,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: color.withValues(alpha: 0.25),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(right ? x - width - textPainter.width - 4 : x + width + 4, y + 8),
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
