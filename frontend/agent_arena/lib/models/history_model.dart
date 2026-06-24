import 'debate_model.dart';

class DebateSummary {
  final String id;
  final String topic;
  final String? winner;
  final int totalVotes;
  final String status;
  final String createdAt;

  DebateSummary({
    required this.id,
    required this.topic,
    this.winner,
    this.totalVotes = 0,
    required this.status,
    required this.createdAt,
  });

  factory DebateSummary.fromJson(Map<String, dynamic> json) => DebateSummary(
    id: json['id'] as String,
    topic: json['topic'] as String,
    winner: json['winner'] as String?,
    totalVotes: json['total_votes'] as int? ?? 0,
    status: json['status'] as String? ?? 'in_progress',
    createdAt: json['created_at'] as String? ?? '',
  );
}

class DebateDetailResponse {
  final String id;
  final String topic;
  final String description;
  final int maxRounds;
  final int currentRound;
  final String status;
  final String? winner;
  final String createdAt;
  final bool chaosMode;
  final JudgeResult? judgeResult;
  final Map<String, int> voteCount;
  final List<Map<String, dynamic>> rounds;

  DebateDetailResponse({
    required this.id,
    required this.topic,
    required this.description,
    required this.maxRounds,
    required this.currentRound,
    required this.status,
    this.winner,
    required this.createdAt,
    this.chaosMode = false,
    this.judgeResult,
    this.voteCount = const {},
    required this.rounds,
  });

  factory DebateDetailResponse.fromDebate(
    DebateModel debate, {
    Map<String, int> voteCount = const {},
  }) {
    JudgeResult? judgeResult;
    if (debate.winner != null && debate.rounds.isNotEmpty) {
      judgeResult = JudgeResult(
        winner: debate.winner!,
        scores: {
          'Pro':
              debate.rounds.map((r) => r.scorePro).reduce((a, b) => a + b) /
              debate.rounds.length,
          'Con':
              debate.rounds.map((r) => r.scoreCon).reduce((a, b) => a + b) /
              debate.rounds.length,
        },
        explanation: debate.rounds.last.judgeFeedback,
        feedback: {},
      );
    }
    final roundMaps = debate.rounds
        .map(
          (r) => {
            'responses': [
              {
                'agent_id': 'Pro',
                'side': 'pro',
                'response': r.proArgument,
                'reasoning_path': <String>[],
              },
              {
                'agent_id': 'Con',
                'side': 'con',
                'response': r.conArgument,
                'reasoning_path': <String>[],
              },
            ],
            'judge_feedback': r.judgeFeedback,
            'score_pro': r.scorePro,
            'score_con': r.scoreCon,
          },
        )
        .toList();

    return DebateDetailResponse(
      id: debate.id,
      topic: debate.topic,
      description: debate.description,
      maxRounds: debate.maxRounds,
      currentRound: debate.currentRound,
      status: debate.status,
      winner: debate.winner,
      createdAt: debate.createdAt,
      chaosMode: false,
      judgeResult: judgeResult,
      voteCount: voteCount,
      rounds: roundMaps,
    );
  }
}

class JudgeResult {
  final String winner;
  final Map<String, double> scores;
  final String explanation;
  final Map<String, String> feedback;

  JudgeResult({
    required this.winner,
    required this.scores,
    required this.explanation,
    this.feedback = const {},
  });
}

class PaginatedHistory {
  final List<DebateSummary> debates;
  final int total;

  PaginatedHistory({required this.debates, required this.total});
}
