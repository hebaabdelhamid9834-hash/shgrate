import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/screens/common_webview_screen.dart';
import 'package:flutter/material.dart';

class ShortsScreen extends StatelessWidget {
  const ShortsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonWebviewScreen(
      url: '${AppConfig.RAW_BASE_URL}/offers',
      page_name: 'Shgarde Shorts',
    );
  }
}
