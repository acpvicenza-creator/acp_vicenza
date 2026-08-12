import 'package:flutter_test/flutter_test.dart';
import 'package:acp_vicenza/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // ACPVicenzaApp ko load karein
    await tester.pumpWidget(const ACPVicenzaApp());
  });
}