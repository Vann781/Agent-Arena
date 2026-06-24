import 'package:flutter_test/flutter_test.dart';

import 'package:agent_arena/main.dart';

void main() {
  testWidgets('App builds without error', (WidgetTester tester) async {
    await tester.pumpWidget(const AgentArenaApp());
    expect(find.byType(AgentArenaApp), findsOneWidget);
  });
}
