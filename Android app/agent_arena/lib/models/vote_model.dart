class VoteModel {
  final String id;
  final String debateId;
  final String sessionId;
  final String choice;
  final String createdAt;

  VoteModel({
    required this.id,
    required this.debateId,
    required this.sessionId,
    required this.choice,
    required this.createdAt,
  });

  factory VoteModel.fromJson(Map<String, dynamic> json) => VoteModel(
    id: json['id'] as String,
    debateId: json['debate_id'] as String,
    sessionId: json['session_id'] as String,
    choice: json['choice'] as String,
    createdAt: json['created_at'] as String? ?? '',
  );
}

class VoteResultsModel {
  final String debateId;
  final int pro;
  final int con;
  final int total;

  VoteResultsModel({
    required this.debateId,
    required this.pro,
    required this.con,
    required this.total,
  });

  factory VoteResultsModel.fromJson(Map<String, dynamic> json) =>
      VoteResultsModel(
        debateId: json['debate_id'] as String,
        pro: json['pro'] as int? ?? 0,
        con: json['con'] as int? ?? 0,
        total: json['total'] as int? ?? 0,
      );
}

class VoteResponse {
  final String agentId;
  final int voteCount;

  VoteResponse({required this.agentId, required this.voteCount});
}
