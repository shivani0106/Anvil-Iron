import 'package:flutter_test/flutter_test.dart';
import 'package:iron_works_app/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const IronWorksApp());
    expect(find.text('Hello, Mikul'), findsOneWidget);
  });
}
