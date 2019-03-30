import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../net/dio_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import '../model/user.dart';
import '../redux/main_redux.dart';
import '../redux/user_reducer.dart';
import '../utils/const.dart';
import '../utils/sp.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> with TickerProviderStateMixin {


  Color colorRegular = Color(0xFFFF786E);
  Color colorLight = Color(0xFFFF978F);
  Color colorInput = Color(0x40FFFFFF);
  Color colorWhite = Colors.white;

  TextStyle defaultTextStyle =
      TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16);

  BorderRadius radius = BorderRadius.all(Radius.circular(21));

  AnimationController animationController;
  Animation buttonLengthAnimation;

  TextEditingController accountController = new TextEditingController();
  TextEditingController pwdController = new TextEditingController();

  bool isLogin = false;

  Store _store;
  Store get store => _store;

  void showTips(String msg) {
    Fluttertoast.showToast(msg: msg);
  }

  void login() async {
    String account = accountController.text.toString();
    String pwd = pwdController.text.toString();
    if (account.isEmpty || pwd.isEmpty) {
      isLogin = false;
      Fluttertoast.showToast(msg: "账号密码不能为空");
      return;
    }
    playAnimate(isLogin);

    DioManager.singleton
        .post("user/json",
            data: FormData.from({
              "username": account,
              "password": pwd,
            }))
        .then((result) {
      if (result != null) {
        var id = result.data["id"];
        var username = result.data["username"];
        SpManager.singleton.save(Const.ID, id);
        SpManager.singleton.save(Const.USERNAME, username);
        //派发动作，动作会触发更新user状态
        store.dispatch(UpdateUserAction(User(id, username)));
        isLogin = true;
      }
    });
  }

  playAnimate(bool isLogin) async {
    if (isLogin) {
      await animationController.forward();
    } else {
      await animationController.forward();
      await animationController.reverse();
    }

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1500));

    buttonLengthAnimation = new Tween<double>(
      //使用补间动画， 定义 开始到结束的宽度变化
      begin: 312.0,
      end: 42.0,
    ).animate(
        //curved 动画变化过程中是非线性的
        new CurvedAnimation(
            /*
          * 这里的interval 是动画间隔的控制，这里我翻译一下 注释中举的例子：
          * 假设一个6秒的动画，当interval 设置为 begin:0.5 ,end:1.0 时，
          * 实际上动画变成了一个延迟了3秒，且时长3秒的动画
          * 大家可以自己理解
          * */
            parent: animationController,
            curve: new Interval(0.0, 0.250)))
      ..addListener(() {
        //添加对动画执行过程的监听
        if (buttonLengthAnimation.isCompleted) {
          if (isLogin) {
            Fluttertoast.showToast(msg: "登陆成功");
            Navigator.of(context).pop();
          } else {
            showTips('登录失败');
          }
        }
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [colorLight, colorRegular],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter)),
        child: Column(
          children: <Widget>[
            Container(
              margin:
                  EdgeInsets.only(top: 110, bottom: 39, left: 24, right: 24),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(21)),
                  color: colorInput),
              child: TextField(
                controller: accountController,
                decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 15, vertical: 9),
                    border: InputBorder.none,
                    hintText: '请输入账号',
                    hintStyle: TextStyle(color: Colors.white, fontSize: 16),
                    labelStyle: TextStyle(color: Colors.black, fontSize: 16)),
                maxLines: 1,
                cursorColor: colorRegular,
                keyboardType: TextInputType.phone,
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 30, left: 24, right: 24),
              decoration:
                  BoxDecoration(borderRadius: radius, color: colorInput),
              child: TextField(
                controller: pwdController,
                decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 15, vertical: 9),
                    border: InputBorder.none,
                    hintText: "输入密码",
                    hintStyle: TextStyle(color: Colors.white, fontSize: 16),
                    labelStyle: TextStyle(color: Colors.black, fontSize: 16)),
                maxLines: 1,
                cursorColor: colorRegular,
                keyboardType: TextInputType.number,
                obscureText: true,
              ),
            ),
            InkWell(
              onTap: login,
              child: Container(
                margin: EdgeInsets.only(top: 30),
                height: 42,
                width: buttonLengthAnimation.value,
                decoration:
                    BoxDecoration(borderRadius: radius, color: colorWhite),
                alignment: Alignment.center,
                child: buttonLengthAnimation.value > 75
                    ? new Text(
                        "立即登录",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: colorRegular),
                      )
                    : CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(colorRegular),
                        strokeWidth: 2,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    // TODO: implement dispose
    super.dispose();
  }
}
