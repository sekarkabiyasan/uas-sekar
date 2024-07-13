import 'package:flutter/material.dart';
import 'package:phone_mart/settings/theme_settings.dart';

//Membuat global fontStyle

TextStyle fontStyleTitleAppbar(context) {
  double screenWidth = MediaQuery.of(context).size.width;
  if (MediaQuery.of(context).orientation == Orientation.landscape) {
    screenWidth = MediaQuery.of(context).size.height;
  } else {
    screenWidth = MediaQuery.of(context).size.width;
  }
  double baseFontSize = 18.0;
  double scaleFactor = screenWidth / 360;
  double responsiveFontSize = baseFontSize * scaleFactor;
  return TextStyle(
      fontSize: responsiveFontSize,
      fontWeight: FontWeight.w800,
      color: ThemeSettings().primaryColor(context));
}

TextStyle fontStyleTitleH1DefaultColor(context) {
  double screenWidth = MediaQuery.of(context).size.width;
  if (MediaQuery.of(context).orientation == Orientation.landscape) {
    screenWidth = MediaQuery.of(context).size.height;
  } else {
    screenWidth = MediaQuery.of(context).size.width;
  }
  double baseFontSize = 18.0;
  double scaleFactor = screenWidth / 360;
  double responsiveFontSize = baseFontSize * scaleFactor;
  return TextStyle(
      fontSize: responsiveFontSize,
      fontWeight: FontWeight.w800,
      color: ThemeSettings().fontColor(context));
}

TextStyle fontStyleTitleH2DefaultColor(context) {
  double screenWidth = MediaQuery.of(context).size.width;
  if (MediaQuery.of(context).orientation == Orientation.landscape) {
    screenWidth = MediaQuery.of(context).size.height;
  } else {
    screenWidth = MediaQuery.of(context).size.width;
  }
  double baseFontSize = 16.0;
  double scaleFactor = screenWidth / 360;
  double responsiveFontSize = baseFontSize * scaleFactor;
  return TextStyle(
      fontSize: responsiveFontSize,
      fontWeight: FontWeight.w800,
      color: ThemeSettings().fontColor(context));
}

TextStyle fontStyleTitleH3DefaultColor(context) {
  double screenWidth = MediaQuery.of(context).size.width;
  if (MediaQuery.of(context).orientation == Orientation.landscape) {
    screenWidth = MediaQuery.of(context).size.height;
  } else {
    screenWidth = MediaQuery.of(context).size.width;
  }
  double baseFontSize = 14.0;
  double scaleFactor = screenWidth / 360;
  double responsiveFontSize = baseFontSize * scaleFactor;
  return TextStyle(
      fontSize: responsiveFontSize,
      fontWeight: FontWeight.w800,
      color: ThemeSettings().fontColor(context));
}

TextStyle fontStyleTitleH3WhiteColor(context) {
  double screenWidth = MediaQuery.of(context).size.width;
  if (MediaQuery.of(context).orientation == Orientation.landscape) {
    screenWidth = MediaQuery.of(context).size.height;
  } else {
    screenWidth = MediaQuery.of(context).size.width;
  }
  double baseFontSize = 14.0;
  double scaleFactor = screenWidth / 360;
  double responsiveFontSize = baseFontSize * scaleFactor;
  return TextStyle(
      fontSize: responsiveFontSize,
      fontWeight: FontWeight.w800,
      color: Colors.white);
}

TextStyle fontStyleParagraftDefaultColor(context) {
  double screenWidth = MediaQuery.of(context).size.width;
  if (MediaQuery.of(context).orientation == Orientation.landscape) {
    screenWidth = MediaQuery.of(context).size.height;
  } else {
    screenWidth = MediaQuery.of(context).size.width;
  }
  double baseFontSize = 10.0;
  double scaleFactor = screenWidth / 360;
  double responsiveFontSize = baseFontSize * scaleFactor;
  return TextStyle(
      fontSize: responsiveFontSize,
      fontWeight: FontWeight.w500,
      color: ThemeSettings().fontColor(context));
}

TextStyle fontStyleParagraftWhiteColor(context) {
  double screenWidth = MediaQuery.of(context).size.width;
  if (MediaQuery.of(context).orientation == Orientation.landscape) {
    screenWidth = MediaQuery.of(context).size.height;
  } else {
    screenWidth = MediaQuery.of(context).size.width;
  }
  double baseFontSize = 10.0;
  double scaleFactor = screenWidth / 360;
  double responsiveFontSize = baseFontSize * scaleFactor;
  return TextStyle(
      fontSize: responsiveFontSize,
      fontWeight: FontWeight.w500,
      color: Colors.white);
}

TextStyle fontStyleSubtitleDefaultColor(context) {
  double screenWidth = MediaQuery.of(context).size.width;
  if (MediaQuery.of(context).orientation == Orientation.landscape) {
    screenWidth = MediaQuery.of(context).size.height;
  } else {
    screenWidth = MediaQuery.of(context).size.width;
  }
  double baseFontSize = 12.0;
  double scaleFactor = screenWidth / 360;
  double responsiveFontSize = baseFontSize * scaleFactor;
  return TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: ThemeSettings().fontColor(context));
}

TextStyle fontStyleSubtitleSemiBoldDefaultColor(context) {
  double screenWidth = MediaQuery.of(context).size.width;
  if (MediaQuery.of(context).orientation == Orientation.landscape) {
    screenWidth = MediaQuery.of(context).size.height;
  } else {
    screenWidth = MediaQuery.of(context).size.width;
  }
  double baseFontSize = 12.0;
  double scaleFactor = screenWidth / 360;
  double responsiveFontSize = baseFontSize * scaleFactor;
  return TextStyle(
      fontSize: responsiveFontSize,
      fontWeight: FontWeight.w800,
      color: ThemeSettings().fontColor(context));
}

TextStyle fontStyleSubtitleSemiBoldDangerColor(context) {
  double screenWidth = MediaQuery.of(context).size.width;
  if (MediaQuery.of(context).orientation == Orientation.landscape) {
    screenWidth = MediaQuery.of(context).size.height;
  } else {
    screenWidth = MediaQuery.of(context).size.width;
  }
  double baseFontSize = 12.0;
  double scaleFactor = screenWidth / 360;
  double responsiveFontSize = baseFontSize * scaleFactor;
  return TextStyle(
      fontSize: responsiveFontSize,
      fontWeight: FontWeight.w800,
      color: ThemeSettings().errorColor(context));
}

TextStyle fontStyleSubtitleSemiBoldNonColor(context) {
  double screenWidth = MediaQuery.of(context).size.width;
  if (MediaQuery.of(context).orientation == Orientation.landscape) {
    screenWidth = MediaQuery.of(context).size.height;
  } else {
    screenWidth = MediaQuery.of(context).size.width;
  }
  double baseFontSize = 12.0;
  double scaleFactor = screenWidth / 360;
  double responsiveFontSize = baseFontSize * scaleFactor;
  return TextStyle(fontSize: responsiveFontSize, fontWeight: FontWeight.w800);
}

TextStyle fontStyleSubtitleSemiBoldPrimaryColor(context) {
  double screenWidth = MediaQuery.of(context).size.width;
  if (MediaQuery.of(context).orientation == Orientation.landscape) {
    screenWidth = MediaQuery.of(context).size.height;
  } else {
    screenWidth = MediaQuery.of(context).size.width;
  }
  double baseFontSize = 12.0;
  double scaleFactor = screenWidth / 360;
  double responsiveFontSize = baseFontSize * scaleFactor;
  return TextStyle(
      fontSize: responsiveFontSize,
      fontWeight: FontWeight.w800,
      color: ThemeSettings().primaryColor(context));
}

TextStyle fontStyleSubtitleSemiBoldWhiteColor(context) {
  double screenWidth = MediaQuery.of(context).size.width;
  if (MediaQuery.of(context).orientation == Orientation.landscape) {
    screenWidth = MediaQuery.of(context).size.height;
  } else {
    screenWidth = MediaQuery.of(context).size.width;
  }
  double baseFontSize = 12.0;
  double scaleFactor = screenWidth / 360;
  double responsiveFontSize = baseFontSize * scaleFactor;
  return TextStyle(
      fontSize: responsiveFontSize,
      fontWeight: FontWeight.w800,
      color: Colors.white);
}

TextStyle fontStyleParagraftBoldDefaultColor(context) {
  double screenWidth = MediaQuery.of(context).size.width;
  if (MediaQuery.of(context).orientation == Orientation.landscape) {
    screenWidth = MediaQuery.of(context).size.height;
  } else {
    screenWidth = MediaQuery.of(context).size.width;
  }
  double baseFontSize = 10.0;
  double scaleFactor = screenWidth / 360;
  double responsiveFontSize = baseFontSize * scaleFactor;
  return TextStyle(
      fontSize: responsiveFontSize,
      fontWeight: FontWeight.bold,
      color: ThemeSettings().fontColor(context));
}
