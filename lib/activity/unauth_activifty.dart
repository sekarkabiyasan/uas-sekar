import 'package:flutter/material.dart';
import 'package:phone_mart/activity/auth/login_activity.dart';
import 'package:phone_mart/activity/auth/register_activity.dart';
import 'package:phone_mart/settings/app_settings.dart';
import 'package:phone_mart/settings/theme_settings.dart';
import 'package:phone_mart/style/font_style.dart';

Widget unAuth(BuildContext context) {
  bool isPotrait = MediaQuery.of(context).orientation == Orientation.landscape
      ? false
      : true;
  return SafeArea(
      child: Padding(
    padding: EdgeInsets.all(ScreenSetting().paddingScreen),
    child: Flex(
      direction: isPotrait ? Axis.vertical : Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        isPotrait
            ? Image.asset(
                "${AssetsSetting().imagePath}unauth.png",
                height: MediaQuery.of(context).size.height * 0.5,
              )
            : Image.asset(
                "${AssetsSetting().imagePath}unauth.png",
                width: MediaQuery.of(context).size.width * 0.5,
              ),
        Expanded(
          child: Column(
            mainAxisAlignment:
                isPotrait ? MainAxisAlignment.end : MainAxisAlignment.center,
            children: [
              Text(
                "Mohon login terlebih dahulu untuk akses modul ini",
                style: fontStyleTitleH2DefaultColor(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                      child: ElevatedButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterAcitvity(),
                        )),
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // <-- Radius
                        ),
                        elevation: 0,
                        backgroundColor:
                            ThemeSettings().cardColorGreyDark(context)),
                    child: Text(
                      "Daftar",
                      style: fontStyleSubtitleSemiBoldDefaultColor(context),
                    ),
                  )),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      child: ElevatedButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginActivity(),
                        )),
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // <-- Radius
                        ),
                        elevation: 0,
                        backgroundColor: ThemeSettings().primaryColor(context)),
                    child: Text(
                      "Masuk",
                      style: fontStyleSubtitleSemiBoldWhiteColor(context),
                    ),
                  )),
                ],
              )
            ],
          ),
        )
      ],
    ),
  ));
}
