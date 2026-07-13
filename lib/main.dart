import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'app/masrofy_bootstrap_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _installGlobalErrorHandlers();
  usePathUrlStrategy();

  runApp(const MasrofyBootstrapApp());
}

void _installGlobalErrorHandlers() {
  FlutterError.onError = (details) {
    if (kDebugMode) {
      FlutterError.presentError(details);
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) {
      debugPrint('Unhandled framework error: ${error.runtimeType}');
    }
    return true;
  };

  ErrorWidget.builder = (details) {
    return const ColoredBox(
      color: Colors.white,
      child: Center(
        child: Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
      ),
    );
  };
}
