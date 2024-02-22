import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overseas/helpers/ad_helper.dart';
import 'package:overseas/helpers/config.dart';
import 'package:overseas/helpers/prefs.dart';
import 'package:overseas/widgets/change_theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          children: [
            Icon(
              Icons.sunny,
              color: Pref.isDarkMode ? null : Colors.yellow,
            ),
            Switch(
              activeColor: Pref.isDarkMode ? Colors.white : Color(0xff131321),
              value: Pref.isDarkMode,
              onChanged: (bool value) {
                //loads rewarded ad
                if (Config.hideAds) {
                  Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                  Pref.isDarkMode = value;
                  return;
                }
                Get.dialog(WatchAdThemeDialog(onComplete: () {
                  //watch ad to gain reward(change theme)
                  AdHelper.showRewardedAd(onComplete: () {
                    Get.changeThemeMode(
                        value ? ThemeMode.dark : ThemeMode.light);
                    Pref.isDarkMode = value;
                  });
                }));
              },
            ),
            Icon(
              Icons.nightlight_round,
              color: Pref.isDarkMode ? Colors.white : null,
            ),
          ],
        ),
      ),
    );
  }
}
