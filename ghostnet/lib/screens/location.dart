import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../controllers/location_controller.dart';
import '../controllers/native_ad_controller.dart';
import '../helpers/ad_helper.dart';
import '../main.dart';
import '../models/vpn.dart';
import '../widgets/vpn_card.dart';

class LocationScreen extends StatelessWidget {
  LocationScreen({Key? key});

  final _controller = LocationController();
  final _adController = NativeAdController();

  @override
  Widget build(BuildContext context) {
    if (_controller.vpnList.isEmpty) _controller.getVpnData();

    _adController.ad = AdHelper.loadNativeAd(adController: _adController);

    return Obx(
      () => Scaffold(
        // appBar: AppBar(
        //   centerTitle: false,
        //   forceMaterialTransparency: true,
        //   title: Text(
        //     'Servers (${_controller.vpnList.length})',
        //     style: GoogleFonts.orbitron(fontSize: 18),
        //   ),
        // ),
        backgroundColor: Theme.of(context).backgroundColour,
        bottomNavigationBar:
            _adController.ad != null && _adController.adLoaded.isTrue
                ? SafeArea(
                    child: SizedBox(
                        height: 85, child: AdWidget(ad: _adController.ad!)))
                : null,
        body: Stack(
          children: [
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(3.141592653589793),
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/dot.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Column(
              children: [
                Container(
                  height: mediaQuery.height * 0.12,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                  width: mediaQuery.width,
                  child: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: mediaQuery.width * .04),
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 40, 10, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Servers (${_controller.vpnList.length})',
                                  style: GoogleFonts.orbitron(fontSize: 18),
                                ),
                              ],
                            ),
                          )),
                    ),
                  ),
                ),
                Expanded(
                  child: _controller.isLoading.value
                      ? _loadingWidget()
                      : _controller.vpnList.isEmpty
                          ? _noVPNFound()
                          : _vpnData(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _vpnData() {
    _controller.vpnList.sort((a, b) => a.countryLong.compareTo(b.countryLong));

    final groupedVpnList = _groupVpnsByCountry(_controller.vpnList);

    return RefreshIndicator(
      onRefresh: () => _controller.getVpnData(),
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.only(
            top: mediaQuery.height * .015,
            bottom: mediaQuery.height * .1,
            left: mediaQuery.width * .04,
            right: mediaQuery.width * .04),
        itemCount: groupedVpnList.length,
        itemBuilder: (context, index) {
          return VpnCard(vpnList: groupedVpnList[index]);
        },
      ),
    );
  }

  List<List<Vpn>> _groupVpnsByCountry(List<Vpn> vpnList) {
    Map<String, List<Vpn>> groupedVpns = {};

    for (var vpn in vpnList) {
      if (!groupedVpns.containsKey(vpn.countryLong)) {
        groupedVpns[vpn.countryLong] = [];
      }
      groupedVpns[vpn.countryLong]!.add(vpn);
    }

    return groupedVpns.values.toList();
  }

  Widget _loadingWidget() => SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: CircularProgressIndicator(),
      ));

  Widget _noVPNFound() => Center(
        child: Text(
          'OOPs, No VPN Found',
          style: TextStyle(
              fontSize: 18, color: Colors.black54, fontWeight: FontWeight.bold),
        ),
      );
}