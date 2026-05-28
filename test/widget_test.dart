import 'package:bug_out/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Home screen launches', (WidgetTester tester) async {
    await tester.pumpWidget(const BugOutApp());
    expect(find.text('BUG OUT'), findsOneWidget);
    expect(find.text('开始游戏'), findsOneWidget);
    expect(find.text('动效展示'), findsOneWidget);
  });

  testWidgets('Game screen launches from home', (WidgetTester tester) async {
    await tester.pumpWidget(const BugOutApp());
    await tester.tap(find.text('开始游戏'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('开始游戏'), findsWidgets);
  });
}
