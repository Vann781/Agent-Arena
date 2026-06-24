import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

class SpeechBubble extends StatefulWidget {
  final String text;
  final Color color;
  final bool isLeft;
  final String agentName;

  const SpeechBubble({
    super.key,
    required this.text,
    required this.color,
    this.isLeft = true,
    this.agentName = '',
  });

  @override
  State<SpeechBubble> createState() => _SpeechBubbleState();
}

class _SpeechBubbleState extends State<SpeechBubble> {
  String _displayed = '';
  int _charIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  @override
  void didUpdateWidget(SpeechBubble old) {
    super.didUpdateWidget(old);
    if (old.text != widget.text) {
      _timer?.cancel();
      _displayed = '';
      _charIndex = 0;
      _startTyping();
    }
  }

  void _startTyping() {
    const speed = Duration(milliseconds: 25);
    _timer = Timer.periodic(speed, (_) {
      if (_charIndex < widget.text.length) {
        setState(() => _displayed += widget.text[_charIndex++]);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.color;
    final tailSize = 14.0;

    return Padding(
      padding: EdgeInsets.only(
        left: widget.isLeft ? 0 : 40,
        right: widget.isLeft ? 40 : 0,
      ),
      child: Column(
        crossAxisAlignment: widget.isLeft
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          // Agent name tag
          if (widget.agentName.isNotEmpty)
            Container(
              margin: EdgeInsets.only(
                left: widget.isLeft ? 12 : 0,
                right: widget.isLeft ? 0 : 12,
                bottom: 2,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.3),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Text(
                widget.agentName.toUpperCase(),
                style: TextStyle(
                  color: c,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ),
          // Bubble with tail
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                constraints: const BoxConstraints(maxWidth: 240),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D0D1A).withValues(alpha: 0.92),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  border: Border.all(
                    color: c.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  _displayed,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // Tail
              Positioned(
                bottom: -tailSize + 2,
                left: widget.isLeft ? 20 : null,
                right: widget.isLeft ? null : 20,
                child: CustomPaint(
                  size: Size(tailSize, tailSize),
                  painter: _TailPainter(c, widget.isLeft),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TailPainter extends CustomPainter {
  final Color color;
  final bool left;

  _TailPainter(this.color, this.left);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final path = Path();
    if (left) {
      path.moveTo(0, 0);
      path.lineTo(size.width * 0.6, size.height);
      path.lineTo(size.width, 0);
    } else {
      path.moveTo(size.width, 0);
      path.lineTo(size.width * 0.4, size.height);
      path.lineTo(0, 0);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
