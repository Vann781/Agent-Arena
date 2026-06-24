import 'api_service.dart';

class DebateApiService {
  final ApiService _api;

  DebateApiService(this._api);

  String get sessionId => _api.sessionId;

  Future<Map<String, dynamic>> startDebate(
    String topic,
    String description, {
    int maxRounds = 3,
  }) async {
    final response = await _api.post(
      '/api/debate/start',
      data: {
        'topic': topic,
        'description': description,
        'max_rounds': maxRounds,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getDebate(String debateId) async {
    final response = await _api.get('/api/debate/$debateId');
    return response.data;
  }

  Future<Map<String, dynamic>> nextRound(String debateId) async {
    final response = await _api.post(
      '/api/debate/next-round',
      data: {'debate_id': debateId},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> vote(String debateId, String choice) async {
    final response = await _api.post(
      '/api/debate/vote',
      data: {
        'debate_id': debateId,
        'session_id': _api.sessionId,
        'choice': choice,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> voteResults(String debateId) async {
    final response = await _api.get('/api/debate/$debateId/results');
    return response.data;
  }

  Future<List<dynamic>> getHistory({int limit = 20}) async {
    final response = await _api.get(
      '/api/history',
      queryParams: {'limit': limit},
    );
    return response.data as List;
  }

  Future<Map<String, dynamic>> getHistoryDetail(String debateId) async {
    final response = await _api.get('/api/history/$debateId');
    return response.data;
  }
}
