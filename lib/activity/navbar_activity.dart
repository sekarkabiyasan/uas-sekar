import 'package:flutter/material.dart';
import 'package:phone_mart/activity/myproduct_activity.dart';
import 'package:phone_mart/activity/home_activity.dart';
import 'package:phone_mart/activity/order_tabbar.dart';
import 'package:phone_mart/activity/profile_activity.dart';
import 'package:phone_mart/settings/theme_settings.dart';
import 'package:phone_mart/style/font_style.dart';

class NavbarActivity extends StatefulWidget {
  const NavbarActivity({super.key});

  @override
  State<NavbarActivity> createState() => _NavbarActivityState();
}

class _NavbarActivityState extends State<NavbarActivity> {
  int screenindex = 0;
  final screen = [
    const HomeActivity(),
    const MyProduct(),
    const OrderTabbar(),
    const ProfileActivity(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screen[screenindex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: ThemeSettings().backgroundGrey(context),
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: const Icon(Icons.phone_android_rounded),
              label: "Explore",
              backgroundColor: ThemeSettings().backgroundGrey(context)),
          BottomNavigationBarItem(
              icon: const Icon(Icons.my_library_books),
              label: "Produk saya",
              backgroundColor: ThemeSettings().backgroundGrey(context)),
          BottomNavigationBarItem(
              icon: const Icon(Icons.shopping_bag_outlined),
              label: "Order",
              backgroundColor: ThemeSettings().backgroundGrey(context)),
          BottomNavigationBarItem(
              icon: const Icon(Icons.person),
              label: "Profile",
              backgroundColor: ThemeSettings().backgroundGrey(context)),
        ],
        unselectedItemColor: Colors.grey,
        selectedItemColor: ThemeSettings().primaryColor(context),
        elevation: 0,
        showUnselectedLabels: true,
        unselectedLabelStyle: fontStyleParagraftBoldDefaultColor(context),
        selectedLabelStyle: fontStyleParagraftBoldDefaultColor(context),
        currentIndex: screenindex,
        onTap: (value) {
          setState(() {
            screenindex = value;
          });
        },
      ),
    );
  }
}
