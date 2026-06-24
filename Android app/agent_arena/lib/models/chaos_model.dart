class ChaosModel {
  final String id;
  final String topic;
  final String description;
  final int maxRounds;
  final String status;

  ChaosModel({
    required this.id,
    required this.topic,
    required this.description,
    required this.maxRounds,
    required this.status,
  });

  factory ChaosModel.fromJson(Map<String, dynamic> json) => ChaosModel(
    id: json['id'] as String,
    topic: json['topic'] as String,
    description: json['description'] as String? ?? '',
    maxRounds: json['max_rounds'] as int? ?? 3,
    status: json['status'] as String? ?? 'in_progress',
  );
}

class ChaosModeRequest {
  final String topic;
  final List<String> agents;
  final int maxRounds;

  ChaosModeRequest({
    required this.topic,
    required this.agents,
    required this.maxRounds,
  });
}
