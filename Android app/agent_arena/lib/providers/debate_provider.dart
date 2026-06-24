import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/debate_model.dart';
import '../models/chaos_model.dart';
import '../repositories/debate_repository.dart';
import 'api_provider.dart';

enum DebateStatus { idle, loading, active, error }

class DebateState {
  final DebateStatus status;
  final String? debateId;
  final String? topic;
  final Map<String, String>? sides;
  final List<String>? structure;
  final List<RespondResponse> rounds;
  final int currentRound;
  final bool chaosMode;
  final List<String> agents;
  final String? error;
  final bool isComplete;

  const DebateState({
    this.status = DebateStatus.idle,
    this.debateId,
    this.topic,
    this.sides,
    this.structure,
    this.rounds = const [],
    this.currentRound = 0,
    this.chaosMode = false,
    this.agents = const [],
    this.error,
    this.isComplete = false,
  });

  DebateState copyWith({
    DebateStatus? status,
    String? debateId,
    String? topic,
    Map<String, String>? sides,
    List<String>? structure,
    List<RespondResponse>? rounds,
    int? currentRound,
    bool? chaosMode,
    List<String>? agents,
    String? error,
    bool? isComplete,
  }) => DebateState(
    status: status ?? this.status,
    debateId: debateId ?? this.debateId,
    topic: topic ?? this.topic,
    sides: sides ?? this.sides,
    structure: structure ?? this.structure,
    rounds: rounds ?? this.rounds,
    currentRound: currentRound ?? this.currentRound,
    chaosMode: chaosMode ?? this.chaosMode,
    agents: agents ?? this.agents,
    error: error ?? this.error,
    isComplete: isComplete ?? this.isComplete,
  );
}

class DebateNotifier extends StateNotifier<DebateState> {
  final DebateRepository _repository;

  DebateNotifier(this._repository) : super(const DebateState());

  Future<void> startDebate(
    String topic, {
    int maxRounds = 4,
    bool chaosMode = false,
    List<String>? agents,
  }) async {
    state = state.copyWith(status: DebateStatus.loading, error: null);
    try {
      final response = await _repository.startDebate(
        topic,
        '',
        maxRounds: maxRounds,
        chaosMode: chaosMode,
        agents: agents,
      );
      state = state.copyWith(
        status: DebateStatus.active,
        debateId: response.id,
        topic: response.topic,
        sides: response.sides,
        structure: response.structure,
        chaosMode: response.chaosMode,
        agents: response.agents ?? agents ?? [],
        currentRound: 1,
        isComplete: false,
        rounds: [],
      );
    } catch (e) {
      state = state.copyWith(status: DebateStatus.error, error: e.toString());
    }
  }

  Future<void> advanceRound() async {
    if (state.debateId == null) return;
    state = state.copyWith(status: DebateStatus.loading);
    try {
      final response = await _repository.advanceRound(state.debateId!);
      state = state.copyWith(
        status: DebateStatus.active,
        rounds: [...state.rounds, response],
        currentRound: response.roundNumber,
        isComplete: response.phase == 'completed',
      );
    } catch (e) {
      state = state.copyWith(status: DebateStatus.error, error: e.toString());
    }
  }

  Future<void> askQuestion(String question, {String? targetAgent}) async {
    if (state.debateId == null) return;
    try {
      final response = await _repository.askQuestion(
        state.debateId!,
        question,
        targetAgent: targetAgent,
      );
      state = state.copyWith(
        status: DebateStatus.active,
        rounds: [...state.rounds, response],
        currentRound: response.roundNumber,
        isComplete: response.phase == 'completed',
      );
    } catch (e) {
      state = state.copyWith(status: DebateStatus.error, error: e.toString());
    }
  }

  Future<void> startChaos(ChaosModeRequest request) async {
    state = state.copyWith(status: DebateStatus.loading, error: null);
    try {
      final response = await _repository.startChaos(request);
      state = state.copyWith(
        status: DebateStatus.active,
        debateId: response.id,
        topic: response.topic,
        chaosMode: response.chaosMode,
        agents: response.agents ?? request.agents,
        currentRound: 1,
        isComplete: false,
        rounds: [],
      );
    } catch (e) {
      state = state.copyWith(status: DebateStatus.error, error: e.toString());
    }
  }

  void reset() => state = const DebateState();
}

final debateProvider = StateNotifierProvider<DebateNotifier, DebateState>((
  ref,
) {
  final repository = ref.watch(debateRepositoryProvider);
  return DebateNotifier(repository);
});
