import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:overseas/apis/apis.dart';
import 'package:overseas/helpers/ad_helper.dart';
import 'package:overseas/helpers/config.dart';
import 'package:overseas/helpers/prefs.dart';
import 'package:overseas/models/ip_details.dart';
import 'package:overseas/models/network_data.dart';
import 'package:overseas/screens/network_test.dart';
import 'package:overseas/screens/settings.dart';
import 'package:overseas/widgets/change_theme.dart';
import 'package:overseas/widgets/network_card.dart';
import '../controllers/home_controller.dart';
import '../main.dart';
import '../models/vpn_status.dart';
import '../services/vpn_engine.dart';
import '../widgets/count_down_timer.dart';
import '../widgets/home_card.dart';
import 'location.dart';

class GhostHome extends StatelessWidget {
  GhostHome({super.key});

  final _controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    ///Add listener to update vpn state
    VpnEngine.vpnStageSnapshot().listen((event) {
      _controller.vpnState.value = event;
    });

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColour,
      //body
      body: Stack(
        children: [
          Image.asset(
            'assets/flags/world.png',
            fit: BoxFit.cover,
            height: 400,
          ),
          Center(
            child: Column(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: 100,
                  ),
                  Switch(
                    value: Pref.isDarkMode,
                    onChanged: (bool value) {
                      //loads rewarded ad
                      if (Config.hideAds) {
                        Get.changeThemeMode(
                            value ? ThemeMode.dark : ThemeMode.light);
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
                  //connection status label
                  Text(
                    _controller.vpnState.value == VpnEngine.vpnDisconnected
                        ? 'Not Connected'
                        : _controller.vpnState
                            .replaceAll('_', ' ')
                            .toUpperCase(),
                    style: GoogleFonts.kanit(
                      color: Theme.of(context).backgroundColour,
                      fontSize: 16,
                    ),
                  ),

                  //count down timer
                  Obx(() => CountDownTimer(
                      startTimer: _controller.vpnState.value ==
                          VpnEngine.vpnConnected)),

                  Padding(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
                      child: _changeLocation(context)),

                  // Obx(() => _vpnButton()),
                ]),
          ),
          Positioned(bottom: -310, left: 0, right: 0, child: _vpnButton()),
          Positioned(
            bottom: 0,
            child: Container(
              height: mediaQuery.height * 0.22,
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              width: mediaQuery.width,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: mediaQuery.height * 0.22,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: StreamBuilder<VpnStatus?>(
                      initialData: VpnStatus(),
                      stream: VpnEngine.vpnStatusSnapshot(),
                      builder: (context, snapshot) => Padding(
                        padding: const EdgeInsets.fromLTRB(0, 24, 0, 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            //download
                            Container(
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.lightGreen,
                                    child: Icon(Icons.arrow_downward_rounded,
                                        size: 30, color: Colors.white),
                                  ),
                                  SizedBox(
                                    height: 12,
                                  ),
                                  Text(
                                    '${snapshot.data?.byteIn ?? '0 kbps'}',
                                    style: GoogleFonts.kanit(
                                      color: Theme.of(context).primaryColour,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    'Download',
                                    style: GoogleFonts.kanit(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  )
                                ],
                              ),
                            ),

                            Container(
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.blue,
                                    child: Icon(Icons.arrow_upward_rounded,
                                        size: 30, color: Colors.white),
                                  ),
                                  SizedBox(
                                    height: 12,
                                  ),
                                  Text(
                                    '${snapshot.data?.byteOut ?? '0 kbps'}',
                                    style: GoogleFonts.kanit(
                                      color: Theme.of(context).primaryColour,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    'Download',
                                    style: GoogleFonts.kanit(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(bottom: 120, left: 0, right: 0, child: _mainVPNButton())
        ],
      ),
    );
  }

  //vpn button
  Widget _vpnButton() => Column(
        children: [
          //button
          Semantics(
            button: true,
            child: Container(
              padding: EdgeInsets.all(34),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _controller.getButtonColor.withOpacity(.1)),
              child: Container(
                padding: EdgeInsets.all(34),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _controller.getButtonColor.withOpacity(.2)),
                child: Container(
                  padding: EdgeInsets.all(34),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _controller.getButtonColor.withOpacity(.3)),
                  child: Container(
                    padding: EdgeInsets.all(34),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _controller.getButtonColor.withOpacity(.4)),
                    child: Container(
                      padding: EdgeInsets.all(34),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _controller.getButtonColor.withOpacity(.5)),
                      child: Container(
                        width: mediaQuery.height * .8,
                        height: mediaQuery.height * .8,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _controller.getButtonColor),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );

  Widget _mainVPNButton() {
    return InkWell(
      onTap: () {
        _controller.connectToVpn();
      },
      child: Container(
        width: mediaQuery.height * .14,
        height: mediaQuery.height * .14,
        decoration: BoxDecoration(
            shape: BoxShape.circle, color: _controller.getButtonColor),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //icon
            Icon(
              Icons.power_settings_new,
              size: 28,
              color: Colors.white,
            ),

            SizedBox(height: 4),

            //text
            Text(
              _controller.getButtonText,
              style: TextStyle(
                  fontSize: 12.5,
                  color: Colors.white,
                  fontWeight: FontWeight.w500),
            )
          ],
        ),
      ),
    );
  }

  Widget _changeLocation(BuildContext context) => SafeArea(
          child: Semantics(
        button: true,
        child: InkWell(
          onTap: () => Get.to(() => LocationScreen()),
          child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).bottomNav,
                  borderRadius: BorderRadius.circular(30)),
              padding: EdgeInsets.symmetric(horizontal: mediaQuery.width * .04),
              height: 60,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.blue,
                    child: _controller.vpn.value.countryLong.isEmpty
                        ? Icon(Icons.vpn_lock_rounded,
                            size: 30, color: Colors.white)
                        : null,
                    backgroundImage: _controller.vpn.value.countryLong.isEmpty
                        ? null
                        : AssetImage(
                            'assets/flags/${_controller.vpn.value.countryShort.toLowerCase()}.png'),
                  ),

                  //for adding some space
                  SizedBox(width: 10),

                  //text
                  Text(
                    _controller.vpn.value.countryLong.isEmpty
                        ? 'Country'
                        : _controller.vpn.value.countryLong,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  ),

                  //for covering available spacing
                  Spacer(),
                  Icon(Icons.equalizer_rounded, size: 26, color: Colors.white),
                  Text(
                    _controller.vpn.value.countryLong.isEmpty
                        ? '100 ms'
                        : '${_controller.vpn.value.ping} ms',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  //icon
                  Icon(Icons.keyboard_arrow_right_rounded,
                      color: Colors.white, size: 26)
                ],
              )),
        ),
      ));
}
