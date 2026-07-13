import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/branding/brand_assets.dart';
import '../core/storage/local_storage_bootstrap.dart';
import '../core/theme/app_theme.dart';
import '../di/service_locator.dart';
import '../l10n/generated/app_localizations.dart';
import '../presentation/screens/startup/startup_failure_screen.dart';
import 'masrofy_app.dart';

typedef AppBootstrap = Future<void> Function();

typedef AppBuilder = Widget Function(BuildContext context);

enum AppBootstrapStatus { initial, initializing, success, failure }

class AppBootstrapController {
  Future<void>? _activeAttempt;
  AppBootstrapStatus _status = AppBootstrapStatus.initial;

  AppBootstrapStatus get status => _status;

  Future<void> run(AppBootstrap bootstrap) {
    final activeAttempt = _activeAttempt;
    if (activeAttempt != null && _status == AppBootstrapStatus.initializing) {
      return activeAttempt;
    }
    _status = AppBootstrapStatus.initializing;
    final attempt = bootstrap().then(
      (_) {
        _status = AppBootstrapStatus.success;
      },
      onError: (Object error, StackTrace stackTrace) {
        _status = AppBootstrapStatus.failure;
        Error.throwWithStackTrace(error, stackTrace);
      },
    );
    _activeAttempt = attempt;
    return attempt;
  }

  Future<void> retry(AppBootstrap bootstrap) {
    _activeAttempt = null;
    return run(bootstrap);
  }
}

class MasrofyBootstrapApp extends StatefulWidget {
  const MasrofyBootstrapApp({
    super.key,
    this.bootstrap,
    this.appBuilder,
    this.locale,
    this.controller,
  });

  final AppBootstrap? bootstrap;
  final AppBuilder? appBuilder;
  final Locale? locale;
  final AppBootstrapController? controller;

  @override
  State<MasrofyBootstrapApp> createState() => _MasrofyBootstrapAppState();
}

class _MasrofyBootstrapAppState extends State<MasrofyBootstrapApp> {
  late Future<void> _bootstrapFuture;
  late final AppBootstrapController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? AppBootstrapController();
    _bootstrapFuture = _controller.run(_bootstrap);
  }

  Future<void> _bootstrap() {
    final bootstrap = widget.bootstrap ?? _defaultBootstrap;
    return bootstrap();
  }

  void _retry() {
    setState(() {
      _bootstrapFuture = _controller.retry(_bootstrap);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: widget.locale,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      home: FutureBuilder<void>(
        future: _bootstrapFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const _StartupLoadingScreen();
          }

          if (snapshot.hasError) {
            final errorDetails = kDebugMode ? snapshot.error.toString() : null;
            return StartupFailureScreen(
              onRetry: _retry,
              debugDetails: errorDetails,
            );
          }

          return widget.appBuilder?.call(context) ?? const MasrofyApp();
        },
      ),
    );
  }
}

Future<void> _defaultBootstrap() async {
  final storageResult = await LocalStorageBootstrap.initialize();
  await configureDependencies(
    existingInstallation: storageResult.existingInstallation,
  );
}

class _StartupLoadingScreen extends StatelessWidget {
  const _StartupLoadingScreen();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  BrandAssets.primaryLogo,
                  height: 136,
                  fit: BoxFit.contain,
                  semanticLabel: l10n.appName,
                ),
                const SizedBox(height: 24),
                const CircularProgressIndicator(),
                const SizedBox(height: 24),
                Text(
                  l10n.startupLoadingTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.startupLoadingBody,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
