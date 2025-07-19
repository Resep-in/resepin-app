import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:resepin/pages/home_page.dart';
import 'package:resepin/pages/profile_page.dart';
import 'package:resepin/pages/scan_page.dart';
import 'package:resepin/theme/appColors.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<PersistentTabConfig> _tabs(BuildContext context) => [
      PersistentTabConfig(
        screen: HomePage(),
        item: ItemConfig(
          icon: Icon(Icons.home),
          title: 'Home',
          iconSize: 32,
          activeColorSecondary: AppColors.primary,
          activeForegroundColor: AppColors.primary,
          inactiveBackgroundColor: Colors.black,
          inactiveForegroundColor: Colors.black
        ),
      ),
      PersistentTabConfig(
        screen: ScanPage(),
        item: ItemConfig(
          icon: Icon(Icons.camera_alt),
          title: 'Scan',
          iconSize: 32,
          activeColorSecondary: AppColors.primary,
          activeForegroundColor: AppColors.primary,
          inactiveBackgroundColor: Colors.black,
          inactiveForegroundColor: Colors.black,
        ),
      ),
      PersistentTabConfig(
        screen: ProfilePage(),
        item: ItemConfig(
          icon: Icon(Icons.person),
          title: 'Profile',
          iconSize: 32,
          activeColorSecondary: AppColors.primary,
          activeForegroundColor: AppColors.primary,
          inactiveBackgroundColor: Colors.black,
          inactiveForegroundColor: Colors.black,
        ),
      ),
    ];

    return PersistentTabView(
      tabs: _tabs(context),
      navBarBuilder: (navBarConfig) => Style1BottomNavBar(
        navBarConfig: navBarConfig,
      ),
    );
  }
}