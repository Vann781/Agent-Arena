import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/debate_api_service.dart';
import '../repositories/debate_repository.dart';
import '../repositories/history_repository.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final debateApiServiceProvider = Provider<DebateApiService>(
  (ref) => DebateApiService(ref.watch(apiServiceProvider)),
);

final debateRepositoryProvider = Provider<DebateRepository>(
  (ref) => DebateRepository(ref.watch(debateApiServiceProvider)),
);

final historyRepositoryProvider = Provider<HistoryRepository>(
  (ref) => HistoryRepository(ref.watch(debateApiServiceProvider)),
);
