import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agent_arena/main.dart';

void main() {
  testWidgets('App renders without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: AgentArenaApp()));
    expect(find.text('Agent Arena'), findsWidgets);
  });
}
