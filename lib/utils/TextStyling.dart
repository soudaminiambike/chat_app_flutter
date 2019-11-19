import 'dart:ui';

import 'package:flutter/material.dart';

import 'AppConstants.dart';

class TextStyling {
  static final TextStyle displayTimeTextStyle = TextStyle(
      fontFamily: AppConstants.FONT_NAME,
      fontSize: 11.0,
      color: Colors.black45);
  static final TextStyle displayMessageTextStyle = TextStyle(
      fontFamily: AppConstants.FONT_NAME, fontSize: 14.0, color: Colors.black);
  static final TextStyle userNameTextStyle = TextStyle(
      fontFamily: AppConstants.FONT_NAME,
      fontSize: 16.0,
      color: Colors.black45);
  static final TextStyle headerTitleTextStyle = TextStyle(
      fontFamily: AppConstants.FONT_NAME,
      fontSize: 35.0,
      fontWeight: FontWeight.bold,
      color: Colors.black);
  static final TextStyle userNameHeaderTextStyle =  TextStyle(
      fontFamily: AppConstants.FONT_NAME,
      fontSize: 22.0,
      fontWeight: FontWeight.bold,
      color: Colors.black);
}
