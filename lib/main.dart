import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'redux/main_redux.dart';
import 'page/main_page.dart';
import 'page/flash_page.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  final store = new Store<MainRedux>(appReducer,initialState: MainRedux(user: null));

  @override
  Widget build(BuildContext context) {
    return StoreProvider<MainRedux>(
      store: store,
      child: MaterialApp(
        title: "WanAndroid",
        theme: ThemeData(
          primarySwatch:Colors.blue,
          primaryColor:Colors.orangeAccent
        ),
        //didn't do localizations delegates
        initialRoute: "flash",
        routes: {
          "flash":(context) => FlashPage(),
          "mainpage":(context) => MainPage()
        },
      ),
    );
  }
}

















