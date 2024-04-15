import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:guime/pages/home_page.dart';
import 'package:guime/services/shared_preferences_helper.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferencesHelper.init();
  SystemChrome.setPreferredOrientations([
    // 画面の向きを縦に固定
    DeviceOrientation.portraitUp,
  ]).then((_) {
    runApp(const ProviderScope(child: MyApp()));
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  final SharedPreferencesHelper sharedPreferencesHelper = SharedPreferencesHelper();

  Future<Locale> _fetchLocale() async {
    final language = await sharedPreferencesHelper.loadSavedLanguage();
    return Locale(language ?? 'ja');
  }

  void _changeLanguage(String languageCode) async {
    await sharedPreferencesHelper.saveLanguage(languageCode);
    Locale? locale = await _fetchLocale();
    setState(() {
      _locale = locale;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchLocale().then((locale) {
      setState(() {
        _locale = locale;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_locale == null) {
      return const CircularProgressIndicator();
    } else {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: _locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('ja'),
        ],
        routes: {
          '/': (context) => HomePage(
                onLanguageChanged: _changeLanguage,
              ),
        },
      );
    }
  }
}
