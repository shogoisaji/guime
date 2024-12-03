import 'dart:async';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:guime/pages/home_page.dart';
import 'package:guime/services/shared_preferences_helper.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferencesHelper.init();

  Future<void> initializeATT() async {
    /// ATTの許可
    final status = await AppTrackingTransparency.trackingAuthorizationStatus;
    if (status == TrackingStatus.notDetermined) {
      /// milliseconds: 200 -> could not display ATT permission.
      await Future.delayed(const Duration(milliseconds: 500));
      await AppTrackingTransparency.requestTrackingAuthorization();
    }
  }

  await (
    /// 縦固定
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]),

    /// システムUIを上部に表示
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge),

    /// admobを初期化
    MobileAds.instance.initialize(),

    /// 起動時の通知とATTのポップアップ
    initializeATT(),
  ).wait;

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  final SharedPreferencesHelper sharedPreferencesHelper =
      SharedPreferencesHelper();

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
