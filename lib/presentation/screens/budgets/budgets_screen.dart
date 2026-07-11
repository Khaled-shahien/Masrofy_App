import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../widgets/empty_state.dart';

class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return EmptyState(
      icon: Icons.savings_outlined,
      title: l10n.budgetsEmptyTitle,
      body: l10n.budgetsEmptyBody,
    );
  }
}
