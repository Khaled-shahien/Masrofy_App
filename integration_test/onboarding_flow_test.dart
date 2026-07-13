import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:masrofy/core/theme/app_theme.dart';
import 'package:masrofy/l10n/generated/app_localizations.dart';
import 'package:masrofy/presentation/screens/onboarding/onboarding_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('onboarding skip completes the first-run flow', (tester) async {
    var completed = false;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light(),
        home: OnboardingScreen(
          onFinished: () async {
            completed = true;
          },
        ),
      ),
    );

    expect(find.text('Welcome to Masrofy'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('onboarding-skip')));
    await tester.pumpAndSettle();

    expect(completed, isTrue);
  });
}
