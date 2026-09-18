import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sram_setu/main.dart';

void main() {
  testWidgets('SramSetuApp smoke test - renders sign up screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SramSetuApp(),
      ),
    );

    // Verify brand header and registration title appear
    expect(find.text('SRAM SETU'), findsOneWidget);
    expect(find.text('Sign Up & Verify Email'), findsOneWidget);
  });
}
