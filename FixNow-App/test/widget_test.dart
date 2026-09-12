import 'package:flutter_test/flutter_test.dart';

import 'package:fixnow_app/main.dart';

void main() {
  testWidgets('App launches and shows splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const FixNowApp());

    expect(find.text('FixNow'), findsOneWidget);
  });
}
