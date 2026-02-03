import 'dart:async';

import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/screens/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  PackageInfo _packageInfo = PackageInfo(
    appName: AppConfig.app_name,
    packageName: 'Unknown',
    version: AppConfig.app_version,
    buildNumber: 'Unknown',
  );

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);

    _initPackageInfo();
    _navigateToMain();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }

  Future<void> _initPackageInfo() async {
    try {
      final PackageInfo info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() {
        _packageInfo = info;
      });
    } catch (e) {}
  }

  void _navigateToMain() {
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => Main()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomSplashScreen(
      seconds: 3,
      navigateAfterSeconds: Main(),
      title: Text(
        "V ${AppConfig.app_version}",
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0, color: Colors.white),
      ),
      useLoader: false,
      loadingText: Text(
        AppConfig.copyright_text,
        style: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 13.0,
          color: Colors.white,
        ),
      ),
      image: Image.asset("assets/splash_screen_logo.png"),
      backgroundImage: Image.asset("assets/splash_login_registration_background_image.png"),
      backgroundColor: MyTheme.splash_screen_color,
      photoSize: 60.0,
      backgroundPhotoSize: 140.0,
    );
  }
}

class CustomSplashScreen extends StatefulWidget {
  final int? seconds;
  final Text? title;
  final Color? backgroundColor;
  final TextStyle? styleTextUnderTheLoader;
  final dynamic navigateAfterSeconds;
  final double? photoSize;
  final double? backgroundPhotoSize;
  final dynamic onClick;
  final Color? loaderColor;
  final Image? image;
  final Image? backgroundImage;
  final Text? loadingText;
  final ImageProvider? imageBackground;
  final Gradient? gradientBackground;
  final bool? useLoader;
  final Route? pageRoute;
  final String? routeName;
  final Future<dynamic>? navigateAfterFuture;

  const CustomSplashScreen({
    super.key,
    this.loaderColor,
    this.navigateAfterFuture,
    this.seconds,
    this.photoSize,
    this.backgroundPhotoSize,
    this.pageRoute,
    this.onClick,
    this.navigateAfterSeconds,
    this.title = const Text(''),
    this.backgroundColor = Colors.white,
    this.styleTextUnderTheLoader = const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black),
    this.image,
    this.backgroundImage,
    this.loadingText = const Text(""),
    this.imageBackground,
    this.gradientBackground,
    this.useLoader = true,
    this.routeName,
  });

  @override
  _CustomSplashScreenState createState() => _CustomSplashScreenState();
}

class _CustomSplashScreenState extends State<CustomSplashScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.navigateAfterFuture == null) {
      Timer(Duration(seconds: widget.seconds ?? 3), () {
        if (!mounted) return;
        if (widget.navigateAfterSeconds is Widget) {
          Navigator.of(context).pushReplacement(widget.pageRoute != null ? widget.pageRoute! : MaterialPageRoute(builder: (_) => widget.navigateAfterSeconds));
        } else if (widget.navigateAfterSeconds is String) {
          Navigator.of(context).pushReplacementNamed(widget.navigateAfterSeconds);
        }
      });
    } else {
      widget.navigateAfterFuture!.then((navigateTo) {
        if (!mounted) return;
        if (navigateTo is Widget) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => navigateTo));
        } else if (navigateTo is String) {
          Navigator.of(context).pushReplacementNamed(navigateTo);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InkWell(
        onTap: widget.onClick,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                image: widget.imageBackground == null
                    ? null
                    : DecorationImage(
                        fit: BoxFit.cover,
                        image: widget.imageBackground!,
                      ),
                gradient: widget.gradientBackground,
                color: widget.backgroundColor,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: widget.backgroundPhotoSize,
                  child: Hero(
                    tag: "backgroundImageInSplash",
                    child: Container(child: widget.backgroundImage),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 120.0),
                  child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 60.0),
                            child: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              radius: widget.photoSize,
                              child: Hero(
                                tag: "splashscreenImage",
                                child: Container(child: widget.image),
                              ),
                            ),
                          ),
                          widget.title!,
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                          ),
                          widget.loadingText!
                        ],
                      )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
