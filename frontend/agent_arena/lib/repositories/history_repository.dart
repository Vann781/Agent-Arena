import '../models/debate_model.dart';
import '../models/history_model.dart';
import '../services/debate_api_service.dart';

class HistoryRepository {
  final DebateApiService _api;

  HistoryRepository(this._api);

  Future<PaginatedHistory> getHistory({
    int page = 1,
    String? status,
    int limit = 20,
  }) async {
    final rawList = await _api.getHistory(limit: limit);
    final debates = rawList
        .map((json) => DebateSummary.fromJson(json as Map<String, dynamic>))
        .toList();
    return PaginatedHistory(debates: debates, total: debates.length);
  }

  Future<DebateDetailResponse> getDebateDetail(String debateId) async {
    final data = await _api.getHistoryDetail(debateId);
    final debate = DebateModel.fromJson(data);
    return DebateDetailResponse.fromDebate(debate);
  }
}
