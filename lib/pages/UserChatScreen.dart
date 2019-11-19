import 'package:chat_app/utils/AppConstants.dart';
import 'package:chat_app/bloc/ApplicationBloc.dart';
import 'package:chat_app/models/ChatDataModel.dart';
import 'package:chat_app/utils/TextStyling.dart';
import 'package:chat_app/utils/UtilityFunctions.dart';
//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/AppConstants.dart';
import '../bloc/BlocBase.dart';
import '../models/ChatUserModel.dart';

class UserChatScreen extends StatefulWidget {
  ChatUser user;

  UserChatScreen(this.user);

  @override
  State<StatefulWidget> createState() => UserChatScreenState();
}

class UserChatScreenState extends State<UserChatScreen> {

  ApplicationBloc _applicationBloc;
  double screenWidth;
  double screenHeight;
  final TextEditingController inputTextController = new TextEditingController();
  List<ChatData> messageList;
  String chatId;
  ScrollController listViewScrollController;
  bool canPaginate = true;


  @override
  void initState() {
    super.initState();
    _applicationBloc = BlocProvider.of<ApplicationBloc>(context);
    retriveData();
    listViewScrollController = ScrollController();
    listViewScrollController.addListener(_scrollListener);
  }

  Widget headerTitle() {
    return Row(
      children: <Widget>[
        BackButton(),
        SizedBox(width: 10),
        UtilityFunctions.setProfileImage(50.0, widget.user.imgUrl),
        SizedBox(width: 10),
        Text(
          widget.user.name,
          style: TextStyling.userNameHeaderTextStyle,
        )
      ],
    );
  }

  Widget buildMessageField(int index){
    return Container(
        width: screenWidth,
        alignment: _applicationBloc.isMyMsg(messageList[index])
            ? Alignment.topRight
            : Alignment.topLeft,
        child: Container(
          padding: EdgeInsets.only(
              left:10, right:5, top:5, bottom:3),
          decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(3.0)),
          child:
              ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: 200.0,
                    maxWidth: 200.0,
                    minHeight: 25.0,
                    maxHeight: 150.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(messageList[index].msg,style: TextStyling.displayMessageTextStyle),
                      SizedBox(height: 10),
                      Align(alignment:Alignment.bottomRight,child: Text(UtilityFunctions.getDisplayDateTime(messageList[index].time),style: TextStyling.displayTimeTextStyle,))
          ])
        )));
  }

  Widget buildChatView() {
    return StreamBuilder(
        stream: _applicationBloc.getChat,
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData)
            return Container(
                height: 400, child: Center(child: CircularProgressIndicator()));

          messageList = snapshot.data;

          //multiples of 15 will hit the query again
          canPaginate = messageList.length != 0 && messageList.length % 15 == 0;

          return messageList.length == 0
              ? Center(child: Text(AppConstants.NO_CHATS_AVAILABLE))
              : ListView.builder(
                  controller:listViewScrollController,
                  itemCount: messageList.length,
                  reverse: true,
                  padding: EdgeInsets.only(left: 10, right: 10, top: 20),
                  itemBuilder: (context, index) {
                    return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          buildMessageField(index),
                          SizedBox(height: 10)
                        ]);
                  },
                );
        });
  }

  Widget buildMessageComposer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 40.0),
      child: new TextField(
        controller: inputTextController,
        maxLines: 3,
        minLines: 1,
        decoration: new InputDecoration(
          hintText:AppConstants.SEND_MESSAGE_TEXT,
          suffixIcon: IconButton(
              icon: Icon(Icons.send),
              color: Colors.blue,
              onPressed: () {
                handleSubmitted();
              }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top :40.0),
        child: Column(
          children: <Widget>[
            headerTitle(),
            Expanded(child: buildChatView()),
            buildMessageComposer()
          ],
        ),
      ),
    );
  }

  void handleSubmitted() {
    _applicationBloc.sendMessage(inputTextController.text.trim(), chatId);
    WidgetsBinding.instance.addPostFrameCallback((_) => inputTextController.clear());
  }

  void retriveData() async {
    await _applicationBloc.initializePrefs();
    if (chatId == null) {
      chatId = await _applicationBloc.getChatId(widget.user.uid, _applicationBloc.getOwnUid());
    }
    _applicationBloc.loadChat(chatId);
  }

  _scrollListener() {
    if (listViewScrollController.offset >= listViewScrollController.position.maxScrollExtent
        && listViewScrollController.position.axisDirection == AxisDirection.up
        && !listViewScrollController.position.outOfRange
        && canPaginate) {
      _applicationBloc.loadChat(chatId);
    }
  }
}
