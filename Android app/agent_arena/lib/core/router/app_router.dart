import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/fight/fight_arena_screen.dart';
import '../../screens/judge_result/judge_result_screen.dart';
import '../../screens/history/history_screen.dart';
import '../../screens/history_detail/history_detail_screen.dart';
import '../../screens/chaos/chaos_mode_screen.dart';
import '../../screens/profile/profile_screen.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', name: 'home', builder: (_, __) => const HomeScreen()),
    GoRoute(
      path: '/debate/:id',
      name: 'debate',
      builder: (_, state) =>
          FightArenaScreen(debateId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/debate/:id/result',
      name: 'judgeResult',
      builder: (_, state) =>
          JudgeResultScreen(debateId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/history',
      name: 'history',
      builder: (_, __) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/history/:id',
      name: 'historyDetail',
      builder: (_, state) =>
          HistoryDetailScreen(debateId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/chaos',
      name: 'chaos',
      builder: (_, __) => const ChaosModeScreen(),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (_, __) => const ProfileScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    backgroundColor: const Color(0xFF0D0D1A),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(
            'Page not found: ${state.uri}',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => GoRouter.of(context).go('/'),
            child: const Text('Go Home'),
          ),
        ],
      ),
    ),
  ),
);

final appRouterProvider = Provider<GoRouter>((ref) => _router);
