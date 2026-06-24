import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';
import '../../providers/history_provider.dart';
import '../../widgets/history/debate_list_tile.dart';
import '../../widgets/history/history_filter_bar.dart';
import '../../widgets/common/app_error_widget.dart';
import '../../widgets/common/shimmer_loading.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(
      () => ref.read(historyProvider.notifier).loadHistory(refresh: true),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(historyProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Debate History')),
      body: Column(
        children: [
          HistoryFilterBar(
            currentFilter: historyState.statusFilter,
            onFilterChanged: (v) =>
                ref.read(historyProvider.notifier).setStatusFilter(v),
          ),
          Expanded(
            child: historyState.isLoading && historyState.debates.isEmpty
                ? const ShimmerLoading(itemCount: 5)
                : historyState.error != null && historyState.debates.isEmpty
                ? AppErrorWidget(
                    message: historyState.error!,
                    onRetry: () => ref
                        .read(historyProvider.notifier)
                        .loadHistory(refresh: true),
                  )
                : historyState.debates.isEmpty
                ? const Center(
                    child: Text(
                      'No debates yet',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => ref
                        .read(historyProvider.notifier)
                        .loadHistory(refresh: true),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(top: 8, bottom: 24),
                      itemCount:
                          historyState.debates.length +
                          (historyState.isLoading ? 1 : 0),
                      itemBuilder: (_, i) {
                        if (i >= historyState.debates.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.rambahaur,
                                ),
                              ),
                            ),
                          );
                        }
                        final debate = historyState.debates[i];
                        return DebateListTile(
                          debate: debate,
                          onTap: () => context.push('/history/${debate.id}'),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
