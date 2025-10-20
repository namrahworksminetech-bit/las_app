import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CLoader extends StatelessWidget {
  const CLoader({super.key});
  @override
  Widget build(BuildContext context) => Center(child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [const CircularProgressIndicator(), const SizedBox(height: 12), Text('loading'.tr)],
  ));
}
