// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/route_manager.dart';
// import 'package:ghostnet/screens/homescreen.dart';
// import '../helpers/ad_helper.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(Duration(milliseconds: 1500), () {
//       //exit full-screen
//       SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

//       AdHelper.precacheInterstitialAd();
//       AdHelper.precacheNativeAd();

//       //navigate to home
//       Get.off(() => GhostHome());
//       // Navigator.pushReplacement(
//       //     context, MaterialPageRoute(builder: (_) => HomeScreen()));
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//           child: Image.asset(
//         'assets/images/logo.png',
//         fit: BoxFit.cover,
//       )),
//     );
//   }
// }
