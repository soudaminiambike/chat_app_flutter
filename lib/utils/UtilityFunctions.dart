import 'package:flutter/cupertino.dart';
import 'package:jiffy/jiffy.dart';

import 'AppConstants.dart';

class UtilityFunctions{

  static setProfileImage(double size, String imgUrl) {
    var img = imgUrl == null ? AssetImage(AppConstants.DEFAULT_IMG_PATH) : NetworkImage(imgUrl);
    return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
                fit: BoxFit.cover,
                image: img
            )));
  }

  static String createChatId (String uid1, String uid2){
    return "${uid1}_$uid2";
  }

  static String getChatMessageName (String uid){
    return "${DateTime.now().millisecondsSinceEpoch.toString()}_$uid";
  }

  static String getDisplayDateTime (int miliSec) {
    DateTime time = new DateTime.fromMillisecondsSinceEpoch(miliSec);
    DateTime currentTime = DateTime.now();
    if(time.day == currentTime.day && time.month == currentTime.month && time.year == currentTime.year){
      return "${time.hour}:${time.minute}";
    } else {
      return Jiffy([time.year, time.month, time.day]).format("MMM do");
    }
  }
}