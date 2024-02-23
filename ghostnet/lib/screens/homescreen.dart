import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:overseas/apis/apis.dart';
import 'package:overseas/models/ip_details.dart';
import 'package:overseas/models/network_data.dart';
import 'package:overseas/screens/settings.dart';
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
          Positioned(
              child: Image.asset(
            height: 500,
            'assets/flags/world.png',
            fit: BoxFit.cover,
          )),
          Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: 100,
                  ),

                  StreamBuilder<VpnStatus?>(
                      initialData: VpnStatus(),
                      stream: VpnEngine.vpnStatusSnapshot(),
                      builder: (context, snapshot) => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              //download
                              HomeCard(
                                  title: '${snapshot.data?.byteIn ?? '0 kbps'}',
                                  subtitle: 'DOWNLOAD',
                                  icon: CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.lightGreen,
                                    child: Icon(Icons.arrow_downward_rounded,
                                        size: 30, color: Colors.white),
                                  )),

                              //upload
                              HomeCard(
                                  title:
                                      '${snapshot.data?.byteOut ?? '0 kbps'}',
                                  subtitle: 'UPLOAD',
                                  icon: CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.blue,
                                    child: Icon(Icons.arrow_upward_rounded,
                                        size: 30, color: Colors.white),
                                  )),
                            ],
                          )),
                  // Obx(() => _vpnButton()),
                  _vpnButton(),

                  Padding(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
                      child: _changeLocation(context)),
                ]),
          ),
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
            child: InkWell(
              onTap: () {
                _controller.connectToVpn();
              },
              borderRadius: BorderRadius.circular(100),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _controller.getButtonColor.withOpacity(.1)),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _controller.getButtonColor.withOpacity(.2)),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _controller.getButtonColor.withOpacity(.3)),
                    child: Container(
                      width: mediaQuery.height * .14,
                      height: mediaQuery.height * .14,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _controller.getButtonColor),
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
                  ),
                ),
              ),
            ),
          ),

          //connection status label
          Container(
            margin: EdgeInsets.only(
                top: mediaQuery.height * .015, bottom: mediaQuery.height * .02),
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            decoration: BoxDecoration(
                color: Colors.blue, borderRadius: BorderRadius.circular(15)),
            child: Text(
              _controller.vpnState.value == VpnEngine.vpnDisconnected
                  ? 'Not Connected'
                  : _controller.vpnState.replaceAll('_', ' ').toUpperCase(),
              style: TextStyle(fontSize: 12.5, color: Colors.white),
            ),
          ),

          //count down timer
          Obx(() => CountDownTimer(
              startTimer:
                  _controller.vpnState.value == VpnEngine.vpnConnected)),
        ],
      );

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
