import 'dart:async';

import 'package:chat_app/bloc/BlocBase.dart';
import 'package:chat_app/models/ChatDataModel.dart';
import 'package:chat_app/models/ChatUserModel.dart';
import 'package:chat_app/utils/UtilityFunctions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/AppConstants.dart';

class ApplicationBloc extends BlocBase {

  final StreamController <List<ChatData>> _messagesListController = new StreamController<List<ChatData>>();

  Stream<List<ChatData>> get getChat => _messagesListController.stream;

  SharedPreferences prefs;

  //to compare last received message
  var lastMessageTime = DateTime.now().millisecondsSinceEpoch;

  final databaseReference = FirebaseDatabase.instance.reference();

  List<ChatData> chatMsgs = List();

  Future initializePrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  String getOwnUid() {
    return prefs.getString(AppConstants.KEY_USER_UID);
  }

  Future<List<ChatUser>> getUserList() async {
    var snapshot = await databaseReference.once();
    var data = snapshot.value as Map;
    return ChatUserModel.fromData(data).chatUsers.values.where((user)=> user.uid != getOwnUid()).toList();
 }

  Future registerUser(FirebaseUser firebaseUser) {
   return databaseReference.child(AppConstants.DATABASE_CHAT_USER_TABLE).child(firebaseUser.uid).set({
     AppConstants.KEY_USER_NAME: firebaseUser.displayName,
     AppConstants.KEY_USER_IMAGE: firebaseUser.photoUrl,
     AppConstants.KEY_USER_UID: firebaseUser.uid,
   });
   }

  void sendMessage (String inputText, String chatUid) async {
    int time = DateTime.now().millisecondsSinceEpoch;
    await databaseReference.child(AppConstants.DATABASE_CHAT_MESSAGE_TABLE).child(chatUid).child(UtilityFunctions.getChatMessageName(getOwnUid())).set({
      AppConstants.DATABASE_MESSAGE_KEY: inputText,
      AppConstants.DATABASE_TIME_STAMP: time,
      AppConstants.KEY_USER_UID: prefs.getString(AppConstants.KEY_USER_UID),
    });

    this.chatMsgs.insert(0, ChatData(msg: inputText, time: time, uid: prefs.getString(AppConstants.KEY_USER_UID)));
  _messagesListController.sink.add(this.chatMsgs);
  }


  void loadChat(String chatUid ) async {
    final DatabaseReference databaseReference1 = databaseReference.child(AppConstants.DATABASE_CHAT_MESSAGE_TABLE).child(chatUid);
    final Query query = databaseReference1.orderByChild(AppConstants.DATABASE_TIME_STAMP).endAt(lastMessageTime).limitToLast(AppConstants.PAGINATION_COUNT);
    var data = await query.once();
    List<ChatData> chatMsgList = List();

    if(data.value != null){
      var chatDataMap = data.value as Map;

      for (String key in chatDataMap.keys) {
        ChatData chatData = ChatData.fromJson(chatDataMap[key]);
        chatMsgList.add(chatData);
      }
      // as end at allows equal to subtracting one 1 milisec
      if (chatMsgList.length > 0) {
        chatMsgList.sort((msg1, msg2)=> msg2.time-msg1.time);
        lastMessageTime = chatMsgList.last.time - 1;
      }
    }
    this.chatMsgs.addAll(chatMsgList);
    _messagesListController.sink.add(this.chatMsgs);
  }

  Future<String> getChatId (String uid1, String uid2) async {
    String chatId1 = UtilityFunctions.createChatId(uid1, uid2);
    String chatId2 = UtilityFunctions.createChatId(uid2, uid1);
    var data = await databaseReference.child(AppConstants.DATABASE_CHAT_MESSAGE_TABLE).once();
    Map items = data.value as Map;
    return items.containsKey(chatId1) ? chatId1 : chatId2;
  }

  bool isMyMsg(ChatData data) {
    return data.uid == getOwnUid();
  }

  @override
  void dispose() {
    _messagesListController.close();
  }

}