import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import '../redux/main_redux.dart';
import '../redux/user_reducer.dart';
import '../model/user.dart';
import '../constant/const.dart';
import '../utils/sp.dart';



class FlashPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return FlashPageState();
  }

}

class FlashPageState extends State<FlashPage> {


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 4)).whenComplete((){
      Navigator.pushReplacementNamed(context, "mainpage");
    });
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    initData();
  }

  void initData(){
    int userID;
    String userName;
    Store<MainRedux> store = StoreProvider.of(context);
    SpManager.singleton.getInt(Const.ID).then((id){
      userID = id;
    }).whenComplete((){
      SpManager.singleton.getString(Const.USERNAME).then((name){
        userName = name;
        if(userID != null && userID > 0  && userName!=null && userName.isNotEmpty){
          //proceed dispatch
          store.dispatch(UpdateUserAction(User(userID, userName)));
        }
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Image.network(
      'http://b.hiphotos.baidu.com/image/pic/item/0ff41bd5ad6eddc4802878ba34dbb6fd536633a0.jpg',
      fit: BoxFit.fitHeight,
    );
  }
}













