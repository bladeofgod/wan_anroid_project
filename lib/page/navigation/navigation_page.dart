import 'package:flutter/material.dart';
import '../../model/category.dart';
import '../../net/dio_manager.dart';
import '../../page/web_page.dart';
import '../../utils/common.dart';
import '../../utils/textsize.dart';
import '../../widget/page_widget.dart';


class NavigationPage extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return NavigationPageState();
  }

}

class NavigationPageState extends State<NavigationPage>
  with AutomaticKeepAliveClientMixin{

  int selectPos = 0;
  List<Category> datas = List();
  PageStateController pageStateController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pageStateController = PageStateController();
    getList();
  }

  void getList(){
    DioManager.singleton.get("navi/json").then((result){
      if(result != null){
        pageStateController.changeState(PageState.LoadSuccess);
        setState(() {
          datas.clear();
          List<Category> list = Category.parseList(result.data);
          datas.addAll(list);
        });
      }else{
        pageStateController.changeState(PageState.LoadFail);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return PageWidget(
      reloadData: (){
        getList();
      },
      controller: pageStateController,
      child: Row(
        children: <Widget>[
          //左侧栏
          Expanded(
            flex: 1,
            child: ListView.builder(
              itemCount: datas.length,
              itemBuilder: (context,index){
                return buildItem(index);
              },
            ),
          ),
          //右侧数据栏
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.topLeft,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    //header title
                    Center(
                    child: Padding(padding: EdgeInsets.fromLTRB(0, 5, 0, 15),
                    child: Text(
                      datas.length >0 ? datas[selectPos].name : "",
                      style: TextStyle(
                        fontSize: TextSizeConst.middleTextSize,
                        color:Colors.blueGrey
                      ),
                    ),),),
                    // tag
                    Align(
                      alignment: Alignment.topLeft,
                      child: datas.length > 0 ? Wrap(
                        spacing: 8,//主轴间距
                        runSpacing: 2,//交叉轴间距  详情见注释
                        children: buildTagItem(datas[selectPos]),
                      ) : Container(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> buildTagItem(Category category){
    List<Widget> widgets= List();
    for(Navigation navigation in category.articles){
      Widget item = RaisedButton(
        color: Colors.orangeAccent.withAlpha(100),
        elevation: 0.0,
        highlightElevation: 0.0,
        onPressed: (){
          CommonUtil.push(context, WebPage(title: navigation.title,url: navigation.link,));
        },
        child: Text(
          '${navigation.title}',
          style: TextStyle(color: Colors.deepOrangeAccent),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      );
      widgets.add(item);
    }
    return widgets;
  }

  Widget buildItem(int index){
    Category category = datas[index];
    return InkWell(
      onTap: (){
        setState(() {
          selectPos = index;
        });
      },
      child: Container(
        alignment: Alignment.center,
        color: selectPos == index ? Colors.white : Colors.grey.withAlpha(100),
        padding: EdgeInsets.all(10),
        child: Text(
          category.name,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selectPos == index? Colors.orangeAccent : Colors.black
          ),
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

















