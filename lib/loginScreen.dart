import 'dart:async';

import 'package:chat_app/utils/AppConstants.dart';
import 'package:chat_app/bloc/ApplicationBloc.dart';
import 'package:chat_app/models/ChatUserModel.dart';
import 'package:chat_app/pages/UserListScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:progress_indicator_button/progress_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bloc/BlocBase.dart';

class LoginScreen extends StatefulWidget {
  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {

  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  SharedPreferences prefs;
  ApplicationBloc _applicationBloc;

  bool isLoggedIn = false;
  List<ChatUser> contacts;

  @override
  void initState() {
    super.initState();
    _applicationBloc = BlocProvider.of<ApplicationBloc>(context);
    _applicationBloc.initializePrefs();
    isSignedIn();
  }

  void isSignedIn() async {
    prefs = await SharedPreferences.getInstance();
    isLoggedIn = await googleSignIn.isSignedIn();

    if (isLoggedIn) {
      contacts = await _applicationBloc.getUserList();
      Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) {
            return BlocProvider(
              bloc: ApplicationBloc(),
              child: UserListScreen(contacts),
            );
          }));
    }

  }

  Future<Null> handleSignIn(AnimationController controller) async {
    controller.forward();
    prefs = await SharedPreferences.getInstance();

    GoogleSignInAccount googleUser = await googleSignIn.signIn().catchError((onError) {
      onSignInFail(controller);
    });

    if(googleUser != null) {
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      FirebaseUser firebaseUser = (await firebaseAuth.signInWithCredential(credential)).user;

      if (firebaseUser != null) {
        controller.reverse();
        var response = await _applicationBloc.registerUser(firebaseUser);
        await prefs.setString(AppConstants.KEY_USER_UID, firebaseUser.uid);
        contacts = await _applicationBloc.getUserList();
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) {
              return BlocProvider(
                bloc: ApplicationBloc(),
                child: UserListScreen(contacts),
              );
            }));
      } else {
        onSignInFail(controller);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            AppConstants.APP_TAB_BAR_NAME,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal),),
          leading: IconButton(icon: Icon(Icons.exit_to_app),onPressed: handleLogOutAction,),
        ),
        body:
            Center(
              child: Container(
                height: 60,
                width:  250,
                child: ProgressButton(
                    onPressed: (AnimationController controller) {
                        handleSignIn(controller);
                    },
                    child: Text(
                      AppConstants.LOGIN_BUTTON_TEXT,
                      style: TextStyle(fontSize: 16.0),),
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10.0),
              ),
              ),
            ));
  }

  void onSignInFail(AnimationController controller) {
    controller.reverse();
    Fluttertoast.showToast(msg: "Sign in fail");
  }

  handleLogOutAction() async {
    await googleSignIn.signOut();
    Fluttertoast.showToast(msg: "Sign Out Successful");
  }
}
