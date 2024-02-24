import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:overseas/controllers/home_controller.dart';
import 'package:overseas/services/vpn_engine.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

final _controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    VpnEngine.vpnStageSnapshot().listen((event) {
      _controller.vpnState.value = event;
    });
    
    return const Placeholder();
  }
}