import 'package:flutter/material.dart';

import '../../../core/branding/brand_assets.dart';
import '../../../core/theme/app_design_tokens.dart';
import '../../../core/theme/masrofy_theme_extension.dart';
import '../../../l10n/generated/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    required this.onFinished,
    this.previewMode = false,
    super.key,
  });

  final Future<void> Function() onFinished;
  final bool previewMode;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  var _pageIndex = 0;
  var _isFinishing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pages = _pages(l10n);
    final isLast = _pageIndex == pages.length - 1;
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final padding = responsivePagePadding(constraints);
            return Padding(
              padding: EdgeInsets.fromLTRB(
                padding.left,
                AppSpacing.md,
                padding.right,
                AppSpacing.md,
              ),
              child: Column(
                children: [
                  _OnboardingHeader(
                    onSkip: _isFinishing ? null : _finish,
                    showSkip: !widget.previewMode && !isLast,
                  ),
                  Expanded(
                    child: PageView.builder(
                      key: const ValueKey('onboarding-page-view'),
                      controller: _controller,
                      onPageChanged: (index) {
                        setState(() => _pageIndex = index);
                      },
                      itemCount: pages.length,
                      itemBuilder: (context, index) {
                        return _OnboardingPageView(page: pages[index]);
                      },
                    ),
                  ),
                  _PageIndicators(
                    count: pages.length,
                    selectedIndex: _pageIndex,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pageIndex == 0 || _isFinishing
                              ? null
                              : () => _goToPage(
                                  _pageIndex - 1,
                                  disableAnimations: disableAnimations,
                                ),
                          icon: const Icon(Icons.arrow_back),
                          label: Text(l10n.onboardingBack),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: FilledButton.icon(
                          key: ValueKey(
                            isLast
                                ? 'onboarding-get-started'
                                : 'onboarding-next',
                          ),
                          onPressed: _isFinishing
                              ? null
                              : isLast
                              ? _finish
                              : () => _goToPage(
                                  _pageIndex + 1,
                                  disableAnimations: disableAnimations,
                                ),
                          icon: Icon(
                            isLast
                                ? Icons.check_circle_outline
                                : Icons.arrow_forward,
                          ),
                          label: Text(
                            isLast
                                ? widget.previewMode
                                      ? l10n.commonConfirm
                                      : l10n.onboardingGetStarted
                                : l10n.onboardingNext,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: padding.bottom),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _goToPage(
    int index, {
    required bool disableAnimations,
  }) {
    if (disableAnimations) {
      _controller.jumpToPage(index);
      return Future<void>.value();
    }
    return _controller.animateToPage(
      index,
      duration: AppDurations.standard,
      curve: AppCurves.standard,
    );
  }

  Future<void> _finish() async {
    if (_isFinishing) {
      return;
    }
    setState(() => _isFinishing = true);
    await widget.onFinished();
  }

  List<_OnboardingPage> _pages(AppLocalizations l10n) {
    return [
      _OnboardingPage(
        icon: Icons.account_balance_wallet_outlined,
        title: l10n.onboardingWelcomeTitle,
        body: l10n.onboardingWelcomeBody,
      ),
      _OnboardingPage(
        icon: Icons.query_stats_outlined,
        title: l10n.onboardingBudgetsTitle,
        body: l10n.onboardingBudgetsBody,
      ),
      _OnboardingPage(
        icon: Icons.privacy_tip_outlined,
        title: l10n.onboardingPrivacyTitle,
        body: l10n.onboardingPrivacyBody,
      ),
      _OnboardingPage(
        icon: Icons.backup_outlined,
        title: l10n.onboardingBackupTitle,
        body: l10n.onboardingBackupBody,
      ),
    ];
  }
}

class _OnboardingHeader extends StatelessWidget {
  const _OnboardingHeader({
    required this.onSkip,
    required this.showSkip,
  });

  final VoidCallback? onSkip;
  final bool showSkip;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Image.asset(
          BrandAssets.primaryLogo,
          height: 64,
          width: 120,
          fit: BoxFit.contain,
          semanticLabel: l10n.appName,
        ),
        const Spacer(),
        if (showSkip)
          TextButton(
            key: const ValueKey('onboarding-skip'),
            onPressed: onSkip,
            child: Text(l10n.onboardingSkip),
          ),
      ],
    );
  }
}

class _OnboardingPageView extends StatelessWidget {
  const _OnboardingPageView({required this.page});

  final _OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MasrofyThemeExtension>()!;
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 380;
        final iconContainerSize = compact ? 108.0 : 132.0;
        final iconSize = compact ? 48.0 : 58.0;
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.elevatedSurface,
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.cardBorder),
                      ),
                      child: SizedBox.square(
                        dimension: iconContainerSize,
                        child: Icon(
                          page.icon,
                          size: iconSize,
                          color: colorScheme.primary,
                          semanticLabel: page.title,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: compact ? AppSpacing.md : AppSpacing.xl,
                    ),
                    Semantics(
                      header: true,
                      child: Text(
                        page.title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      page.body,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PageIndicators extends StatelessWidget {
  const _PageIndicators({
    required this.count,
    required this.selectedIndex,
  });

  final int count;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Semantics(
      label: l10n.onboardingPageIndicator(selectedIndex + 1, count),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var index = 0; index < count; index++)
            AnimatedContainer(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : AppDurations.fast,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: selectedIndex == index ? 26 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: selectedIndex == index
                    ? colorScheme.primary
                    : colorScheme.outlineVariant,
                borderRadius: AppRadii.pill,
              ),
            ),
        ],
      ),
    );
  }
}

class _OnboardingPage {
  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}
