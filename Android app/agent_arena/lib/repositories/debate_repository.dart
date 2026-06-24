import '../models/debate_model.dart';
import '../models/vote_model.dart';
import '../models/chaos_model.dart';
import '../services/debate_api_service.dart';

class DebateRepository {
  final DebateApiService _api;

  DebateRepository(this._api);

  Future<DebateModel> startDebate(
    String topic,
    String description, {
    int maxRounds = 3,
    bool chaosMode = false,
    List<String>? agents,
  }) async {
    final data = await _api.startDebate(
      topic,
      description,
      maxRounds: maxRounds,
    );
    final debate = DebateModel.fromJson(data);
    return DebateModel(
      id: debate.id,
      topic: debate.topic,
      description: description,
      maxRounds: maxRounds,
      currentRound: 0,
      rounds: [],
      status: debate.status,
      createdAt: debate.createdAt,
      updatedAt: debate.updatedAt,
      chaosMode: chaosMode,
      agents: agents,
    );
  }

  Future<DebateModel> getDebate(String debateId) async {
    final data = await _api.getDebate(debateId);
    return DebateModel.fromJson(data);
  }

  Future<RespondResponse> advanceRound(String debateId) async {
    final data = await _api.nextRound(debateId);
    final roundsList = data['rounds'] as List? ?? [];
    final lastRound = roundsList.isNotEmpty
        ? roundsList.last as Map<String, dynamic>
        : null;
    return RespondResponse(
      roundNumber: (data['current_round'] as int?) ?? 0,
      phase: data['status'] as String? ?? 'in_progress',
      responses: lastRound != null
          ? [
              AgentResponse(
                agentId: 'pro',
                side: 'pro',
                response: lastRound['pro_argument'] as String? ?? '',
                tone: lastRound['pro_tone'] as String? ?? 'serious',
              ),
              AgentResponse(
                agentId: 'con',
                side: 'con',
                response: lastRound['con_argument'] as String? ?? '',
                tone: lastRound['con_tone'] as String? ?? 'serious',
              ),
            ]
          : [],
      judgeFeedback: lastRound?['judge_feedback'] as String? ?? '',
      scorePro: ((lastRound?['score_pro'] as num?) ?? 0).toDouble(),
      scoreCon: ((lastRound?['score_con'] as num?) ?? 0).toDouble(),
    );
  }

  Future<RespondResponse> askQuestion(
    String debateId,
    String question, {
    String? targetAgent,
  }) async {
    return advanceRound(debateId);
  }

  Future<VoteResponse> vote(String debateId, String agentId) async {
    await _api.vote(debateId, agentId);
    final results = await _api.voteResults(debateId);
    final count = agentId == 'pro' ? results['pro'] : results['con'];
    return VoteResponse(agentId: agentId, voteCount: (count as int?) ?? 0);
  }

  Future<DebateModel> startChaos(ChaosModeRequest request) async {
    return startDebate(
      request.topic,
      'Chaos mode debate',
      maxRounds: request.maxRounds,
      chaosMode: true,
      agents: request.agents,
    );
  }

  Future<VoteResultsModel> getResults(String debateId) async {
    final data = await _api.voteResults(debateId);
    return VoteResultsModel.fromJson(data);
  }
}
