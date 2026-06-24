class ApiConstants {
  ApiConstants._();
  static const String baseUrl = "https://agent-arena-9qpw.onrender.com";
  static const String sessionIdHeader = 'X-Session-Id';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 300);
  static const String startDebate = '/api/debate/start';
  static const String nextRound = '/api/debate/next-round';
  static String debateStatus(String id) => '/api/debate/$id';
  static String debateResults(String id) => '/api/debate/$id/results';
  static const String vote = '/api/debate/vote';
  static const String history = '/api/history';
  static String historyDetail(String id) => '/api/history/$id';
}
