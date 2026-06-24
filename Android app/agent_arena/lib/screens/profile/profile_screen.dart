import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../providers/api_provider.dart';
import '../../widgets/common/glassmorphism_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apiService = ref.watch(apiServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.rambahaur, AppColors.shaamBahadur],
                ),
              ),
              child: const Center(
                child: Text(
                  'AA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Agent Arena User',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            GlassmorphismCard(
              child: Column(
                children: [
                  _infoRow('Session ID', apiService.sessionId),
                  const Divider(),
                  _infoRow('Status', 'Anonymous'),
                  const Divider(),
                  _infoRow('API', 'Connected'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GlassmorphismCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About Agent Arena',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Agent Arena is a multi-agent AI debate platform where '
                    'AI agents argue different perspectives on a topic. '
                    'Watch debates unfold, ask questions, and vote for the winner.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Powered by LangGraph & Gemini',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
