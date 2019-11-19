import 'package:chat_app/bloc/ApplicationBloc.dart';
import 'package:chat_app/models/ChatUserModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/AppConstants.dart';
import '../bloc/BlocBase.dart';
import '../utils/TextStyling.dart';
import 'UserChatScreen.dart';
import '../utils/UtilityFunctions.dart';

class UserListScreen extends StatefulWidget {
  List<ChatUser> contacts;
  UserListScreen(this.contacts);

  @override
  State<StatefulWidget> createState() {
    return UserListScreenState();
  }
}

class UserListScreenState extends State<UserListScreen> {
  ApplicationBloc _applicationBloc;

  Widget headerTitle() {
    return Text(
      AppConstants.USER_LIST_TITLE,
      style: TextStyling.userNameHeaderTextStyle,
    );
  }
  @override
  void initState() {
    super.initState();
    _applicationBloc = BlocProvider.of<ApplicationBloc>(context);
    _applicationBloc.initializePrefs();
  }

  Widget dividerLine() => Divider(color: Colors.black26, height: 36);

  Widget buildUserView() {
    return  ListView.builder(
          itemCount: widget.contacts.length,
          padding: EdgeInsets.only(left: 10,right: 10,top: 10),
          itemBuilder: (context, index) {
            return Column(
              children: <Widget>[
                InkWell(
                  child: Row(
                    children: <Widget>[
                      UtilityFunctions.setProfileImage(60.0, widget.contacts[index].imgUrl),
                      SizedBox(width: 10),
                      Text(widget.contacts[index].name,
                          style: TextStyling.userNameTextStyle)
                    ],
                  ),
                  onTap: () {
                    chatRoomTapped(widget.contacts[index]);
                  },
                ),
                dividerLine()
              ],
            );
          },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  leading: BackButton(color: Colors.black),
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  floating: true,
                  title: headerTitle(),
                )
              ];
            },
            body: buildUserView()),
            );
  }

  Future chatRoomTapped(ChatUser userClicked) async {
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) {
          return BlocProvider(
            bloc: ApplicationBloc(),
            child: UserChatScreen(userClicked),
          );
        }));
  }

}
