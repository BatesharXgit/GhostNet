import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lottie/lottie.dart';

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
        appBar: AppBar(
          title: Text('Servers (${_controller.vpnList.length})'),
        ),
        bottomNavigationBar:
            _adController.ad != null && _adController.adLoaded.isTrue
                ? SafeArea(
                    child: SizedBox(
                        height: 85, child: AdWidget(ad: _adController.ad!)))
                : null,
        // floatingActionButton: Padding(
        //   padding: const EdgeInsets.only(bottom: 10, right: 10),
        //   child: FloatingActionButton(
        //       onPressed: () => _controller.getVpnData(),
        //       child: Icon(CupertinoIcons.refresh)),
        // ),
        body: _controller.isLoading.value
            ? _loadingWidget()
            : _controller.vpnList.isEmpty
                ? _noVPNFound()
                : _vpnData(),
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
          'VPNs Not Found! 😔',
          style: TextStyle(
              fontSize: 18, color: Colors.black54, fontWeight: FontWeight.bold),
        ),
      );
}
