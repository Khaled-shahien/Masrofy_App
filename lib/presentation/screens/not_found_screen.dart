import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../widgets/empty_state.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: EmptyState(
        icon: Icons.error_outline,
        title: l10n.notFoundTitle,
        body: l10n.notFoundBody,
      ),
    );
  }
}
