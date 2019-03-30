import 'package:flutter/material.dart';
import '../constant/tab_name.dart';
import '../widget/title_bar.dart';
import '../utils/common.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:redux/redux.dart';
import '../redux/main_redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../net/dio_manager.dart';
import '../utils/sp.dart';
import '../constant/const.dart';
import '../redux/user_reducer.dart';
import '../utils/textsize.dart';
import '../page/web_page.dart';
import '../page/home/collection_page.dart';
import '../page/login_page.dart';
import '../page/home/home_page.dart';
import '../page/knowledge/knowledge_page.dart';
import '../page/navigation/navigation_page.dart';
import '../page/project/project_page.dart';
import '../page/home/search_page.dart';


//这里我省略了国际化

class MainPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MainPageState();
  }
}

class MainPageState extends State<MainPage> {

  var appBarTitles;
  int tabIndex=0;
  var pageController = PageController(initialPage: 0,keepPage: true);
  DateTime lastPressedAt; // 上次点击时间

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    /*
    * event bus about load
    * */
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    appBarTitles = [
      TabName.TAB_NAME_1,TabName.TAB_NAME_2,TabName.TAB_NAME_3,TabName.TAB_NAME_4
    ];
    //will pop 可以对子部件进行 实现后退键监听 其他功能可以百度
    return WillPopScope(
      child: Scaffold(
        appBar: TitleBar(
          isShowBack: true,
          leftButton: Builder(builder: (context){
            return IconButton(
            icon: Icon(Icons.menu,color: Colors.white,),
            onPressed: (){
              Scaffold.of(context).openDrawer();
      });
      }),
      title: appBarTitles[tabIndex],
      righthBtnList: <Widget>[
        TitleBar.iconButton(
          icon:Icons.search,
          color:Colors.white,
          press: (){
            CommonUtil.push(context, SearchPage());
          },
        )
      ],
        ),
        drawer: Drawer(
          child: drawerChild(),
        ),
        body: PageView(
          physics: NeverScrollableScrollPhysics(),
          controller: pageController,
          children: <Widget>[
            HomePage(),
            KnowledgePage(),
            NavigationPage(),
            ProjectPage(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: tabIndex,
          type: BottomNavigationBarType.fixed,
          fixedColor: Colors.lightBlueAccent,
          onTap: (index)=>tap(index),
          items: [
            BottomNavigationBarItem(
              title:Text(appBarTitles[0]),icon: Icon(Icons.home)
            ),
            BottomNavigationBarItem(
              title: Text(appBarTitles[1]),icon: Icon(Icons.theaters)
            ),
            BottomNavigationBarItem(
              title: Text(appBarTitles[2]),icon: Icon(Icons.navigation)
            ),
            BottomNavigationBarItem(
              title: Text(appBarTitles[3]),icon: Icon(Icons.print)
            ),
          ],
        ),
      ),
      onWillPop: ()async{
        //判断当前点击和上一次时间差 具体可见 .difference注释
        if(lastPressedAt == null || DateTime.now().difference(lastPressedAt) > Duration(seconds: 2)){
          //两次点击间隔超过2秒则重新计时
          lastPressedAt = DateTime.now();
          Fluttertoast.showToast(msg: '再点击一次可退出应用');
          return false;
        }
        return true;
      },
    );
  }

  tap(int index){
    setState(() {
      tabIndex = index;
      pageController.jumpToPage(index);
    });
  }
  //获取用户状态，详情可百度 flutter redux 类似observer
  Store _store;

  Widget drawerChild(){
    return Column(
      children: <Widget>[
        ClipPath(
          clipper: ArcClipper(),
          child: CachedNetworkImage(
            fit: BoxFit.fill,
            width: double.infinity,
            height: 200,
            imageUrl: "http://t2.hddhhn.com/uploads/tu/201612/98/st93.png",
            placeholder: ImageIcon(
              AssetImage("assets/logo.png"),
              size: 100,
            ),
            errorWidget: Icon(Icons.info_outline),
          ),
        ),
        SizedBox(
          width: 0,
          height: 5,
        ),
        menuItem('收藏',Icons.collections,(){
          CommonUtil.isLogin().then((isLogin){
            if(isLogin){
              CommonUtil.push(context, CollectionPage());       //待完成
            }else{
              Fluttertoast.showToast(msg: "请先登录您的账号");
              CommonUtil.push(context, LoginPage());         //待完成
            }
          });
        }),
        menuItem("关于我们",Icons.people,(){
          CommonUtil.push(context, WebPage(title:"关于我们",url: "http://www.wanandroid.com/about"));
        }),
        StoreBuilder<MainRedux>(
          builder: (context,store){
            _store = store;
            return Offstage(
              offstage: store.state.user == null,
              child: Container(
                margin: EdgeInsets.only(top: 20),
                width: 200,
                child: RaisedButton(
                  color: Colors.lightBlueAccent,
                  onPressed: (){
                    CommonUtil.showCommitOptionDialog(
                        context, "提示", "确定要退出吗？", ["确定","取消"], (index){
                          if(index ==0){
                            logout(context);
                          }
                    },bgColorList: [Colors.black26, Colors.white]);
                  },
                  child: Text('退出',style: TextStyle(color: Colors.white),),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void logout(BuildContext context){
    DioManager.singleton.get("user/logout/json").then((result){
      if(result != null){
        Fluttertoast.showToast(msg: "退出成功");
        SpManager.singleton.save(Const.ID, -1);
        SpManager.singleton.save(Const.USERNAME, "");
        //通过redux更新用户状态
        _store.dispatch(UpdateUserAction(null));
        Navigator.pop(context);
      }
    });

  }


  Widget menuItem(String text,IconData icon,Function() tap){
    return InkWell(
      onTap: tap,
      child: Container(
        padding: EdgeInsets.all(10),
        child: Row(
          children: <Widget>[
            Icon(icon,color: Colors.black,),
            Padding(
              padding: EdgeInsets.only(left: 15),
              child: Text(
                text,
                style: TextStyle(
                  color:Colors.grey,
                  fontSize:TextSizeConst.smallTextSize
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }





}

//drawer中裁剪出带贝塞尔曲线的header
class ArcClipper extends CustomClipper<Path>{
  @override
  Path getClip(Size size) {
    // TODO: implement getClip
    var path = Path();
    path.lineTo(0,0);
    path.lineTo(0, size.height - 30); //贝塞尔曲线 左侧开始点
    var firtsControlPoint = Offset(size.width / 2,size.height);//贝塞尔曲线 最低点
    var firstEndPoint = Offset(size.width,size.height - 30);//贝塞尔曲线 右侧结束点
    path.quadraticBezierTo(firtsControlPoint.dx, firtsControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);//绘制被萨尔曲线
    path.lineTo(size.width, size.height-30);
    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    // TODO: implement shouldReclip
    return false;
  }

}



















