import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ghostnet/screens/homescreen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'firebase_options.dart';
import 'helpers/ad_helper.dart';
import 'helpers/config.dart';
import 'helpers/prefs.dart';
import 'screens/splash.dart';

late Size mediaQuery;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  MobileAds.instance.initialize();
  await Firebase.initializeApp();
  await Config.initConfig();
  await Pref.initializeHive();
  await AdHelper.initAds();
  AdHelper.precacheNativeAd();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  mediaQuery = MediaQueryData.fromView(WidgetsBinding.instance.window).size;
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((v) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Brightness platformBrightness = MediaQuery.of(context).platformBrightness;

    return GetMaterialApp(
      title: 'GhostNet',
      home: GhostHome(),
      theme:
          ThemeData(appBarTheme: AppBarTheme(centerTitle: true, elevation: 3)),
      themeMode: Pref.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      darkTheme: ThemeData(
          brightness: Brightness.dark,
          appBarTheme: AppBarTheme(centerTitle: true, elevation: 3)),
      debugShowCheckedModeBanner: false,
    );
  }
}

extension AppTheme on ThemeData {
  Color get backgroundColour => Pref.isDarkMode
      ? Color.fromARGB(255, 28, 28, 48)
      : Color.fromARGB(255, 194, 200, 222);
  Color get primaryColour =>
      Pref.isDarkMode ? Color(0xFFDCE2FA) : Color(0xff131321);
  Color get lightText =>
      Pref.isDarkMode ? Color(0xFFDCE2FA) : Color(0xff131321);
  Color get bottomNav =>
      Pref.isDarkMode ? Color(0xff23203f) : Color(0xff23203f);
}
