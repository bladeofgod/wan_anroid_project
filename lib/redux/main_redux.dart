import '../model/user.dart';
import 'user_reducer.dart';

/*
*  state : main redux
*
*  通过调用app reducer() 返回 初始化的state： main redux
*  main redux 内的user 通过 user reducer 来初始化
*
* */
class MainRedux{
  User user;
  MainRedux({this.user});
}


MainRedux appReducer(MainRedux state,dynamic action){
  return MainRedux(user: UserReducer(state.user,action));
}