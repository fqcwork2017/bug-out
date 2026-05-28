import 'package:bug_out/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Bug Out app launches', (WidgetTester tester) async {
    await tester.pumpWidget(const BugOutApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('BUG OUT'), findsOneWidget);
    expect(find.text('开始游戏'), findsOneWidget);
  });
}
