import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

class SpeechBubble extends StatefulWidget {
  final String text;
  final Color color;
  final bool isLeft;

  const SpeechBubble({
    super.key,
    required this.text,
    required this.color,
    this.isLeft = true,
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
    const speed = Duration(milliseconds: 30);
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
    return Container(
      constraints: const BoxConstraints(maxWidth: 260),
      margin: EdgeInsets.only(
        left: widget.isLeft ? 0 : 16,
        right: widget.isLeft ? 16 : 0,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.withValues(alpha: 0.4)),
      ),
      child: Text(
        _displayed,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 13,
          height: 1.4,
        ),
      ),
    );
  }
}
