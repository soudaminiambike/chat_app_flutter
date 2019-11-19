
import 'dart:convert';

ChatData chatDataModelFromJson(Map<dynamic, dynamic> data) => ChatData.fromJson(data);

String chatDataModelToJson(ChatData data) => json.encode(data.toJson());

class ChatData {
  String msg;
  int time;
  String uid;

  ChatData({
    this.msg,
    this.time,
    this.uid
  });

  factory ChatData.fromJson(Map<dynamic, dynamic> json) => ChatData(
    msg: json["msg"],
    time: json["time"],
    uid: json["uid"],
  );

  Map<String, dynamic> toJson() => {
    "msg": msg,
    "time": time,
    "uid": uid,
  };
}
