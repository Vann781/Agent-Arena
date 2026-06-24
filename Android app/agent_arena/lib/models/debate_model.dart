class DebateModel {
  final String id;
  final String topic;
  final String description;
  final int maxRounds;
  final int currentRound;
  final List<DebateRoundModel> rounds;
  final String status;
  final String? winner;
  final String createdAt;
  final String updatedAt;
  final Map<String, String>? sides;
  final List<String>? structure;
  final bool chaosMode;
  final List<String>? agents;

  DebateModel({
    required this.id,
    required this.topic,
    required this.description,
    required this.maxRounds,
    required this.currentRound,
    required this.rounds,
    required this.status,
    this.winner,
    required this.createdAt,
    required this.updatedAt,
    this.sides,
    this.structure,
    this.chaosMode = false,
    this.agents,
  });

  factory DebateModel.fromJson(Map<String, dynamic> json) => DebateModel(
    id: (json['id'] ?? json['debate_id']) as String,
    topic: json['topic'] as String,
    description: json['description'] as String? ?? '',
    maxRounds: json['max_rounds'] as int? ?? 3,
    currentRound: json['current_round'] as int? ?? 0,
    rounds:
        (json['rounds'] as List?)
            ?.map((r) => DebateRoundModel.fromJson(r))
            .toList() ??
        [],
    status: json['status'] as String? ?? 'in_progress',
    winner: json['winner'] as String?,
    createdAt: json['created_at'] as String? ?? '',
    updatedAt: json['updated_at'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'topic': topic,
    'description': description,
    'max_rounds': maxRounds,
    'current_round': currentRound,
    'rounds': rounds.map((r) => r.toJson()).toList(),
    'status': status,
    'winner': winner,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'chaos_mode': chaosMode,
    'agents': agents,
  };

  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
}

class DebateRoundModel {
  final int roundNumber;
  final String proArgument;
  final String proTone;
  final String conArgument;
  final String conTone;
  final String judgeFeedback;
  final double scorePro;
  final double scoreCon;

  DebateRoundModel({
    required this.roundNumber,
    required this.proArgument,
    this.proTone = 'serious',
    required this.conArgument,
    this.conTone = 'serious',
    required this.judgeFeedback,
    required this.scorePro,
    required this.scoreCon,
  });

  factory DebateRoundModel.fromJson(Map<String, dynamic> json) =>
      DebateRoundModel(
        roundNumber: json['round_number'] as int? ?? 0,
        proArgument: json['pro_argument'] as String? ?? '',
        proTone: json['pro_tone'] as String? ?? 'serious',
        conArgument: json['con_argument'] as String? ?? '',
        conTone: json['con_tone'] as String? ?? 'serious',
        judgeFeedback: json['judge_feedback'] as String? ?? '',
        scorePro: (json['score_pro'] as num?)?.toDouble() ?? 0.0,
        scoreCon: (json['score_con'] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
    'round_number': roundNumber,
    'pro_argument': proArgument,
    'pro_tone': proTone,
    'con_argument': conArgument,
    'con_tone': conTone,
    'judge_feedback': judgeFeedback,
    'score_pro': scorePro,
    'score_con': scoreCon,
  };
}

class AgentResponse {
  final String agentId;
  final String side;
  final String response;
  final String tone;
  final List<String> reasoningPath;

  AgentResponse({
    required this.agentId,
    required this.side,
    required this.response,
    this.tone = 'serious',
    this.reasoningPath = const [],
  });
}

class RespondResponse {
  final int roundNumber;
  final String phase;
  final List<AgentResponse> responses;
  final String judgeFeedback;
  final double scorePro;
  final double scoreCon;

  RespondResponse({
    required this.roundNumber,
    required this.phase,
    this.responses = const [],
    this.judgeFeedback = '',
    this.scorePro = 0,
    this.scoreCon = 0,
  });
}
