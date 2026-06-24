class JudgeResultModel {
  final String debateId;
  final String topic;
  final String winner;
  final double scorePro;
  final double scoreCon;
  final List<JudgeRoundModel> rounds;

  JudgeResultModel({
    required this.debateId,
    required this.topic,
    required this.winner,
    required this.scorePro,
    required this.scoreCon,
    required this.rounds,
  });
}

class JudgeRoundModel {
  final int roundNumber;
  final String proArgument;
  final String conArgument;
  final String judgeFeedback;
  final double scorePro;
  final double scoreCon;

  JudgeRoundModel({
    required this.roundNumber,
    required this.proArgument,
    required this.conArgument,
    required this.judgeFeedback,
    required this.scorePro,
    required this.scoreCon,
  });
}
