import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WatchAdThemeDialog extends StatelessWidget {
  final VoidCallback onComplete;

  const WatchAdThemeDialog({Key? key, required this.onComplete})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Change Theme'),
      content: Text('Watch an Ad to Change App Theme.'),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
            onComplete();
          },
          child: Text(
            'Watch Ad',
            style: TextStyle(color: Colors.green),
          ),
        ),
      ],
    );
  }
}
