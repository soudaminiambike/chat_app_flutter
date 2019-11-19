// To parse this JSON data, do
//
//     final chatDataModel = chatDataModelFromJson(jsonString);

import 'dart:convert';

ChatUserModel chatDataModelFromJson(Map<String, dynamic> data) => ChatUserModel.fromData(data);

String chatDataModelToJson(ChatUserModel data) => json.encode(data.toJson());

class ChatUserModel {
  Map<String, ChatUser> chatUsers;

  ChatUserModel({
    this.chatUsers,
  });

  factory ChatUserModel.fromData(Map<dynamic, dynamic> json) => ChatUserModel(
    chatUsers: Map.from(json["chatUsers"]).map((k, v) => MapEntry<String, ChatUser>(k, ChatUser.fromJson(v))),
  );

  Map<String, dynamic> toJson() => {
    "chatUsers": Map.from(chatUsers).map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
  };
}

class ChatUser {
  String imgUrl;
  String name;
  String uid;

  ChatUser({
    this.imgUrl,
    this.name,
    this.uid
  });

  factory ChatUser.fromJson(Map<dynamic, dynamic> json) => ChatUser(
    imgUrl: json["imgUrl"],
    name: json["name"],
    uid: json["uid"],
  );

  Map<String, dynamic> toJson() => {
    "imgUrl": imgUrl,
    "name": name,
    "uid": uid,
  };
}
