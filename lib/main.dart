import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:runalyzer_client/pages/api_key/api_key.dart';
import 'package:runalyzer_client/pages/home/home.dart';
import 'package:runalyzer_client/pages/not_found.dart';
import 'package:runalyzer_client/pages/static/static_page.dart';
import 'package:runalyzer_client/utils/auth.dart';
import 'package:runalyzer_client/utils/utils.dart';
import 'package:timezone/browser.dart';

void main() async {
  initializeTimeZone();

  runApp(const RunalyzerApp());
}

class RunalyzerApp extends StatelessWidget {

  const RunalyzerApp({super.key});

  @override
  Widget build(BuildContext context) => GetMaterialApp(
    debugShowCheckedModeBanner: false,
    themeMode: ThemeMode.dark,
    theme: ThemeData.dark().copyWith(
      primaryColor: RunalyzerColors.INQUEST_RED,
      textTheme: GoogleFonts.ptSerifTextTheme(ThemeData.dark().textTheme)
    ),
    navigatorObservers: [FlutterSmartDialog.observer],
    builder: FlutterSmartDialog.init(),
    initialBinding: _RunalyzerBinding(),
    initialRoute: RunalyzerLinks.HOME,
    unknownRoute: GetPage(name: "/404", page: () => const NotFoundPage()),
    getPages: [
      GetPage(name: RunalyzerLinks.API_KEY, page: () => ApiKeyPage()),
      GetPage(name: RunalyzerLinks.HOME, page: () => HomePage(), middlewares: [AuthMiddleware()]),
      GetPage(name: RunalyzerLinks.STATIC, page: () => StaticPage(), middlewares: [AuthMiddleware()])
    ],
  );
}

class _RunalyzerBinding implements Bindings {
  @override
  void dependencies() {
  }
}