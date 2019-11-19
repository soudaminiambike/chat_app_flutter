import 'package:chat_app/utils/AppConstants.dart';
import 'package:chat_app/bloc/ApplicationBloc.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/loginScreen.dart';

import 'bloc/BlocBase.dart';

void main() async{
  runApp(MyApp());
}


class MyApp extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}


class MyAppState extends State<MyApp>{

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: AppConstants.APP_TAB_BAR_NAME,
      debugShowCheckedModeBanner: false,
      home: BlocProvider(
          bloc: ApplicationBloc(),
          child: LoginScreen()),
    );
  }

}
