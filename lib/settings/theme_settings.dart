import 'package:flutter/material.dart';

//Membuat global tema

class ThemeSettings {
  Color cardColorGrey(context) {
    return const Color(0xffF5F5F5);
  }

  Color errorColor(context) {
    return const Color(0xffEB6F6F);
  }

  Color greyOutline(context) {
    return const Color(0xffE3E3E3);
  }

  Color cardColorGreyDark(context) {
    return const Color(0xffE1E0E6);
  }

  Color fontColor(context) {
    return const Color(0xff4B4B4B);
  }

  Color primaryColor(context) {
    return Theme.of(context).primaryColor;
  }

  Color buttonColor(context) {
    return Theme.of(context).primaryColor;
  }

  Color cardColors(context) {
    return Theme.of(context).cardColor;
  }

  Color accentCardColors(context) {
    return Theme.of(context).colorScheme.background;
  }

  Color backgroundGrey(context) {
    return Theme.of(context).hoverColor;
  }

  Color unselectedWidget(context) {
    return Theme.of(context).unselectedWidgetColor;
  }
}
