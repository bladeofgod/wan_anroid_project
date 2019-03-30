import '../model/user.dart';
import 'package:redux/redux.dart';

//这里使用的combineReducers方法可以将一组操作绑定到一个reducer，虽然这里只有一个操作
//具体 可以查看TypedReducer 的注释

/*
* main redux调用 userReducer后
* 执行combine reducer(真正的reducer) 管理具体的 state 和 action 并调用update方法  返回一个user给上层
*
* */

final UserReducer = combineReducers<User>([TypedReducer<User,UpdateUserAction>(_update)]);


User _update(User user,action){
  user = action.user;
  return user;
}

class UpdateUserAction{
  User user;
  UpdateUserAction(this.user);
}