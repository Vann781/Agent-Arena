import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/debate_repository.dart';
import 'api_provider.dart';

class VoteState {
  final bool isLoading;
  final String? error;
  final String? votedAgentId;
  final int? voteCount;

  const VoteState({
    this.isLoading = false,
    this.error,
    this.votedAgentId,
    this.voteCount,
  });

  VoteState copyWith({
    bool? isLoading,
    String? error,
    String? votedAgentId,
    int? voteCount,
  }) => VoteState(
    isLoading: isLoading ?? this.isLoading,
    error: error ?? this.error,
    votedAgentId: votedAgentId ?? this.votedAgentId,
    voteCount: voteCount ?? this.voteCount,
  );
}

class VoteNotifier extends StateNotifier<VoteState> {
  final DebateRepository _repository;

  VoteNotifier(this._repository) : super(const VoteState());

  Future<void> vote(String debateId, String agentId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _repository.vote(debateId, agentId);
      state = state.copyWith(
        isLoading: false,
        votedAgentId: response.agentId,
        voteCount: response.voteCount,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() => state = const VoteState();
}

final voteProvider = StateNotifierProvider<VoteNotifier, VoteState>((ref) {
  final repository = ref.watch(debateRepositoryProvider);
  return VoteNotifier(repository);
});
