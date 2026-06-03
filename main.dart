import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app.dart';
import 'core/security/security_service.dart';
import 'core/database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ═══════════════════════════════════════
  // SECURITY: Prevent Screenshots & Screen Recording
  // ═══════════════════════════════════════
  await SystemChannels.platform.invokeMethod(
    'SystemChrome.setEnabledSystemUIMode',
    {'overlays': ['top', 'bottom']},
  );

  // Force portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize database
  await DatabaseHelper.instance.database;

  // Initialize security service
  await SecurityService.instance.initialize();

  runApp(
    const ProviderScope(
      child: LegalOfficeApp(),
    ),
  );
}
