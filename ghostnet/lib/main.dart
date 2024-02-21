import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'helpers/ad_helper.dart';
import 'helpers/config.dart';
import 'helpers/prefs.dart';
import 'screens/splash.dart';

late Size mediaQuery;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  await Firebase.initializeApp();
  await Config.initConfig();
  await Pref.initializeHive();
  await AdHelper.initAds();
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
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Overseas VPN',
      home: SplashScreen(),
      theme:
          ThemeData(appBarTheme: AppBarTheme(centerTitle: true, elevation: 3)),
      themeMode: Pref.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      darkTheme: ThemeData(
          brightness: Brightness.dark,
          appBarTheme: AppBarTheme(centerTitle: true, elevation: 3)),
      debugShowCheckedModeBanner: true,
    );
  }
}

extension AppTheme on ThemeData {
  Color get lightText => Pref.isDarkMode ? Colors.white70 : Colors.black54;
  Color get bottomNav => Pref.isDarkMode ? Colors.white12 : Colors.blue;
}
