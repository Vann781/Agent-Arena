import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

class QuestionInput extends StatefulWidget {
  final void Function(String question, String? targetAgent) onSubmitted;

  const QuestionInput({super.key, required this.onSubmitted});

  @override
  State<QuestionInput> createState() => _QuestionInputState();
}

class _QuestionInputState extends State<QuestionInput> {
  final _controller = TextEditingController();
  String? _targetAgent;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSubmitted(text, _targetAgent);
    _controller.clear();
    setState(() => _targetAgent = null);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ask a Question',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Type your question for the agents...',
              border: InputBorder.none,
              filled: false,
            ),
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              DropdownButton<String?>(
                value: _targetAgent,
                hint: const Text(
                  'All agents',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
                dropdownColor: AppColors.surface,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                ),
                underline: const SizedBox(),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('All agents'),
                  ),
                  const DropdownMenuItem(
                    value: 'agent_a',
                    child: Text('Agent A'),
                  ),
                  const DropdownMenuItem(
                    value: 'agent_b',
                    child: Text('Agent B'),
                  ),
                ],
                onChanged: (v) => setState(() => _targetAgent = v),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.send, color: AppColors.rambahaur),
                onPressed: _submit,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
