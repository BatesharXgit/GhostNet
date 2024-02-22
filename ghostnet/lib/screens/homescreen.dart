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
    final ipData = IPDetails.fromJson({}).obs;
    APIs.getIPDetails(ipData: ipData);

    ///Add listener to update vpn state
    VpnEngine.vpnStageSnapshot().listen((event) {
      _controller.vpnState.value = event;
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.settings),
          onPressed: () => Get.to(SettingsPage()),
        ),
        forceMaterialTransparency: true,
        title: Text('GhostNet', style: GoogleFonts.orbitron(fontSize: 20)),
      ),

      //body
      body: SingleChildScrollView(
        child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //country flag
                      HomeCard(
                          title: _controller.vpn.value.countryLong.isEmpty
                              ? 'Country'
                              : _controller.vpn.value.countryLong,
                          subtitle: 'Pro',
                          icon: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.blue,
                            child: _controller.vpn.value.countryLong.isEmpty
                                ? Icon(Icons.vpn_lock_rounded,
                                    size: 30, color: Colors.white)
                                : null,
                            backgroundImage: _controller
                                    .vpn.value.countryLong.isEmpty
                                ? null
                                : AssetImage(
                                    'assets/flags/${_controller.vpn.value.countryShort.toLowerCase()}.png'),
                          )),

                      //ping time
                      HomeCard(
                          title: _controller.vpn.value.countryLong.isEmpty
                              ? '100 ms'
                              : '${_controller.vpn.value.ping} ms',
                          subtitle: 'PING',
                          icon: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.orange,
                            child: Icon(Icons.equalizer_rounded,
                                size: 30, color: Colors.white),
                          )),
                    ],
                  ),
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
                                title: '${snapshot.data?.byteOut ?? '0 kbps'}',
                                subtitle: 'UPLOAD',
                                icon: CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.blue,
                                  child: Icon(Icons.arrow_upward_rounded,
                                      size: 30, color: Colors.white),
                                )),
                          ],
                        )),
                Obx(() => _vpnButton()),
                Padding(
                    padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: _changeLocation(context)),
                ListView.builder(
                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.only(
                      left: mediaQuery.width * .04,
                      right: mediaQuery.width * .04,
                      top: mediaQuery.height * .01,
                      bottom: mediaQuery.height * .1),
                  itemCount: 5, // Number of items in your list
                  itemBuilder: (context, index) {
                    switch (index) {
                      case 0:
                        return Obx(() => NetworkCard(
                              data: NetworkData(
                                title: 'IP Address',
                                subtitle: ipData.value.query,
                                icon: Icon(
                                  CupertinoIcons.location_solid,
                                  color: Colors.blue,
                                ),
                              ),
                            ));
                      case 1:
                        return Obx(() => NetworkCard(
                              data: NetworkData(
                                title: 'Internet Provider',
                                subtitle: ipData.value.isp,
                                icon: Icon(
                                  Icons.business,
                                  color: Colors.orange,
                                ),
                              ),
                            ));
                      case 2:
                        return Obx(() => NetworkCard(
                              data: NetworkData(
                                title: 'Location',
                                subtitle: ipData.value.country.isEmpty
                                    ? 'Fetching ...'
                                    : '${ipData.value.city}, ${ipData.value.regionName}, ${ipData.value.country}',
                                icon: Icon(
                                  CupertinoIcons.location,
                                  color: Colors.pink,
                                ),
                              ),
                            ));
                      case 3:
                        return Obx(() => NetworkCard(
                              data: NetworkData(
                                title: 'Pin-code',
                                subtitle: ipData.value.zip,
                                icon: Icon(
                                  CupertinoIcons.location_solid,
                                  color: Colors.cyan,
                                ),
                              ),
                            ));
                      case 4:
                        return Obx(() => NetworkCard(
                              data: NetworkData(
                                title: 'Timezone',
                                subtitle: ipData.value.timezone,
                                icon: Icon(
                                  CupertinoIcons.time,
                                  color: Colors.green,
                                ),
                              ),
                            ));
                      default:
                        return SizedBox.shrink();
                    }
                  },
                ),
              ]),
        ),
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

  //bottom nav to change location
  Widget _changeLocation(BuildContext context) => SafeArea(
          child: Semantics(
        button: true,
        child: InkWell(
          onTap: () => Get.to(() => LocationScreen()),
          child: Container(
              color: Theme.of(context).bottomNav,
              padding: EdgeInsets.symmetric(horizontal: mediaQuery.width * .04),
              height: 60,
              child: Row(
                children: [
                  //icon
                  Icon(CupertinoIcons.globe, color: Colors.white, size: 28),

                  //for adding some space
                  SizedBox(width: 10),

                  //text
                  Text(
                    'Change Location',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  ),

                  //for covering available spacing
                  Spacer(),

                  //icon
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.keyboard_arrow_right_rounded,
                        color: Colors.blue, size: 26),
                  )
                ],
              )),
        ),
      ));
}
