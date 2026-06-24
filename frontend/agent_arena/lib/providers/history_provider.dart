import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/history_model.dart';
import '../repositories/history_repository.dart';
import 'api_provider.dart';

class HistoryState {
  final List<DebateSummary> debates;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int total;
  final String? statusFilter;
  final bool hasMore;

  const HistoryState({
    this.debates = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.total = 0,
    this.statusFilter,
    this.hasMore = true,
  });

  HistoryState copyWith({
    List<DebateSummary>? debates,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? total,
    String? statusFilter,
    bool? hasMore,
  }) => HistoryState(
    debates: debates ?? this.debates,
    isLoading: isLoading ?? this.isLoading,
    error: error ?? this.error,
    currentPage: currentPage ?? this.currentPage,
    total: total ?? this.total,
    statusFilter: statusFilter ?? this.statusFilter,
    hasMore: hasMore ?? this.hasMore,
  );
}

class HistoryNotifier extends StateNotifier<HistoryState> {
  final HistoryRepository _repository;

  HistoryNotifier(this._repository) : super(const HistoryState());

  Future<void> loadHistory({bool refresh = false}) async {
    if (state.isLoading) return;
    if (!refresh && !state.hasMore) return;

    state = state.copyWith(
      isLoading: true,
      error: null,
      debates: refresh ? [] : state.debates,
      currentPage: refresh ? 1 : state.currentPage,
    );

    try {
      final response = await _repository.getHistory(
        page: state.currentPage,
        status: state.statusFilter,
      );
      state = state.copyWith(
        isLoading: false,
        debates: refresh
            ? response.debates
            : [...state.debates, ...response.debates],
        total: response.total,
        hasMore:
            state.debates.length + response.debates.length < response.total,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(currentPage: state.currentPage + 1);
    await loadHistory();
  }

  void setStatusFilter(String? status) {
    state = state.copyWith(statusFilter: status);
    loadHistory(refresh: true);
  }
}

final historyProvider = StateNotifierProvider<HistoryNotifier, HistoryState>((
  ref,
) {
  final repository = ref.watch(historyRepositoryProvider);
  return HistoryNotifier(repository);
});

final debateDetailProvider =
    FutureProvider.family<DebateDetailResponse, String>((ref, id) async {
      final repository = ref.watch(historyRepositoryProvider);
      return repository.getDebateDetail(id);
    });
