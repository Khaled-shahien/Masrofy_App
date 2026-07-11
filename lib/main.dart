import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'app/masrofy_app.dart';
import 'core/storage/local_storage_bootstrap.dart';
import 'di/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  await LocalStorageBootstrap.initialize();
  await configureDependencies();

  runApp(const MasrofyApp());
}
