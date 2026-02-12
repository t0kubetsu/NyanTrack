import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Import only the widgets we can test, not the main() function
// which depends on dart:ui for image loading
import 'package:nyancat/main.dart' show SecurityErrorApp;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SecurityErrorApp', () {
    testWidgets('Displays security issues correctly',
            (WidgetTester tester) async {
          await tester.pumpWidget(
            const SecurityErrorApp(
              issues: ['Device is jailbroken', 'Running on emulator/simulator'],
            ),
          );

          // Check that the main title is displayed
          expect(find.text('Security Issue Detected'), findsOneWidget);

          // Check that the subtitle is displayed
          expect(find.text('This app cannot run on rooted/jailbroken devices or emulators.'), findsOneWidget);

          // Check that "Details:" header is displayed
          expect(find.text('Details:'), findsOneWidget);

          // Check that the issues are displayed with "- " prefix
          expect(find.text('- Device is jailbroken'), findsOneWidget);
          expect(find.text('- Running on emulator/simulator'), findsOneWidget);

          // Check that the exit button is displayed
          expect(find.text('Exit App'), findsOneWidget);

          // Verify the icon is present
          expect(find.byIcon(Icons.security), findsOneWidget);
        });

    testWidgets('Displays empty state when no issues',
            (WidgetTester tester) async {
          await tester.pumpWidget(
            const SecurityErrorApp(
              issues: [],
            ),
          );

          // Check that the main title is still displayed
          expect(find.text('Security Issue Detected'), findsOneWidget);

          // Check that "Details:" is NOT displayed when no issues
          expect(find.text('Details:'), findsNothing);

          // Exit button should still be present
          expect(find.text('Exit App'), findsOneWidget);
        });

    testWidgets('Exit button is tappable',
            (WidgetTester tester) async {
          await tester.pumpWidget(
            const SecurityErrorApp(
              issues: ['Device is jailbroken'],
            ),
          );

          // Find the exit button
          final exitButton = find.text('Exit App');
          expect(exitButton, findsOneWidget);

          // Verify it's an ElevatedButton
          final button = tester.widget<ElevatedButton>(
            find.ancestor(
              of: exitButton,
              matching: find.byType(ElevatedButton),
            ),
          );
          expect(button.onPressed, isNotNull);
        });

    testWidgets('Displays multiple issues correctly',
            (WidgetTester tester) async {
          await tester.pumpWidget(
            const SecurityErrorApp(
              issues: [
                'Device is jailbroken',
                'Running on emulator/simulator',
                'App installed on external storage',
                'Device is proxied',
              ],
            ),
          );

          // Verify all issues are displayed
          expect(find.text('- Device is jailbroken'), findsOneWidget);
          expect(find.text('- Running on emulator/simulator'), findsOneWidget);
          expect(find.text('- App installed on external storage'), findsOneWidget);
          expect(find.text('- Device is proxied'), findsOneWidget);
        });
  });
}