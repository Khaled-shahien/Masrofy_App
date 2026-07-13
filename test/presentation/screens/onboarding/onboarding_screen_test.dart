import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masrofy/core/theme/app_theme.dart';
import 'package:masrofy/l10n/generated/app_localizations.dart';
import 'package:masrofy/presentation/screens/onboarding/onboarding_screen.dart';

void main() {
  testWidgets('walks through onboarding and finishes', (tester) async {
    var finished = false;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light(),
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: OnboardingScreen(
            onFinished: () async {
              finished = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Welcome to Masrofy'), findsOneWidget);

    for (var index = 0; index < 3; index++) {
      await tester.tap(find.byKey(const ValueKey('onboarding-next')));
      await tester.pumpAndSettle();
    }

    expect(find.text('Backup and export'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('onboarding-get-started')));
    await tester.pumpAndSettle();

    expect(finished, isTrue);
  });
}
