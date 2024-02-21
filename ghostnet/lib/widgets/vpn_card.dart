import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../helpers/prefs.dart';
import '../main.dart';
import '../models/vpn.dart';
import '../services/vpn_engine.dart';

class VpnCard extends StatefulWidget {
  final List<Vpn> vpnList;

  const VpnCard({Key? key, required this.vpnList});

  @override
  _VpnCardState createState() => _VpnCardState();
}

class _VpnCardState extends State<VpnCard> {
  bool showAllVpns = false;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    widget.vpnList.sort((a, b) => a.countryLong.compareTo(b.countryLong));

    return Card(
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            itemCount: showAllVpns
                ? widget.vpnList.length
                : min(widget.vpnList.length, 4),
            itemBuilder: (context, index) {
              final vpn = widget.vpnList[index];
              return InkWell(
                onTap: () {
                  controller.vpn.value = vpn;
                  Pref.vpn = vpn;
                  Get.back();
                  if (controller.vpnState.value == VpnEngine.vpnConnected) {
                    VpnEngine.stopVpn();
                    Future.delayed(
                        Duration(seconds: 2), () => controller.connectToVpn());
                  } else {
                    controller.connectToVpn();
                  }
                },
                child: ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(.5),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(5)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.asset(
                          'assets/flags/${vpn.countryShort.toLowerCase()}.png',
                          height: 40,
                          width: mediaQuery.width * .15,
                          fit: BoxFit.cover),
                    ),
                  ),
                  title: Text(vpn.countryLong),
                  subtitle: Row(
                    children: [
                      Icon(Icons.speed_rounded, color: Colors.blue, size: 20),
                      SizedBox(width: 4),
                      Text(_formatBytes(vpn.speed, 1),
                          style: TextStyle(fontSize: 13))
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(vpn.numVpnSessions.toString(),
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).lightText)),
                      SizedBox(width: 4),
                      Icon(CupertinoIcons.person_3, color: Colors.blue),
                    ],
                  ),
                ),
              );
            },
          ),
          if (widget.vpnList.length > 4)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!showAllVpns)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        showAllVpns = true;
                      });
                    },
                    child: Text(
                      'See More',
                      style: TextStyle(
                          color: Pref.isDarkMode ? Colors.white : Colors.black),
                    ),
                  )
                else
                  TextButton(
                    onPressed: () {
                      setState(() {
                        showAllVpns = false;
                      });
                    },
                    child: Text('Hide'),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  String _formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ['Bps', "Kbps", "Mbps", "Gbps", "Tbps"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }
}
