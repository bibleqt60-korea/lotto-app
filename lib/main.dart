import 'package:flutter/material.dart';

import 'app.dart';
import 'services/app_initializer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppInitializer.instance.initialize();

  runApp(const LottoApp());
}