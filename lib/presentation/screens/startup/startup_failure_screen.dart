import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/branding/brand_assets.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../widgets/empty_state.dart';

class StartupFailureScreen extends StatelessWidget {
  const StartupFailureScreen({
    required this.onRetry,
    this.debugDetails,
    super.key,
  });

  final VoidCallback onRetry;
  final String? debugDetails;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  BrandAssets.primaryLogo,
                  height: 120,
                  fit: BoxFit.contain,
                  semanticLabel: l10n.appName,
                ),
                const SizedBox(height: 24),
                EmptyState(
                  icon: Icons.cloud_off_outlined,
                  title: l10n.startupFailureTitle,
                  body: l10n.startupFailureBody,
                  action: FilledButton(
                    onPressed: onRetry,
                    child: Text(l10n.commonRetry),
                  ),
                ),
                if (kDebugMode && debugDetails != null) ...[
                  const SizedBox(height: 24),
                  Text(
                    debugDetails!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
