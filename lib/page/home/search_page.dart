import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../db/db.dart';
import '../../model/hotword.dart';
import '../../net/dio_manager.dart';
import '../../page/home/search_result_page.dart';
import '../../utils/common.dart';
import '../../utils/textsize.dart';
import '../../widget/icon_text_widget.dart';


class SearchPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SearchPageState();
  }

}

class SearchPageState extends State<SearchPage> {

  TextEditingController controller;
  List<HotWord> hotWords = List();
  List<Map> histories = List();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = TextEditingController();

    getHistory();//search history
    getHotWord();

  }

  void getHistory(){
    DbManager.singleton.getHistory().then((list){
      setState(() {
        histories.clear();
        histories.addAll(list);
      });
    });
  }

  void getHotWord(){
    DioManager.singleton.get("hotkey/json").then((result){
      if(result != null){
        List<HotWord> datas = HotWord.parseList(result.data);
        setState(() {
          hotWords.clear();
          hotWords.addAll(datas);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          titleBar(context),//标题搜索栏

          //热词搜索 以及搜索历史等 均由list 构造
          Expanded(
            flex: 1,//这里可以理解为 weight
            child: ListView.builder(
              itemCount: histories.length +1,//加1 需要额外画 热词 和历史记录
              itemBuilder: (context,index){
                if(index == 0){
                  return Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        //热词搜索 tag
                        Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Text(
                            '搜索热词',
                            textAlign: TextAlign.left,
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                        hotWords.length > 0
                            ? Wrap(
                          spacing: 5,
                          runSpacing: 5,
                          children: buildWrapItem(),
                        ) : SizedBox(),
                        //历史记录 区域
                        Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '历史记录',
                                  style: TextStyle(color: Colors.black38),
                                ),
                              ),
                              InkWell(
                                child: Padding(padding: EdgeInsets.all(5),
                                child: Text(
                                  '清空',
                                  style: TextStyle(color: Colors.black38),
                                ),),
                                onTap: (){
                                  DbManager.singleton.clear().then((_){
                                    // _ 类似占位符，就是没有返回值
                                    getHistory();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }else{
                  return buildHistoryItem(histories[index - 1]);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget titleBar(BuildContext context){
    return Container(
      //这里返回的是status bar的 高度， top: statusBar .top height
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      color: Colors.white,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: (){
              Navigator.of(context).pop();
            },
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.fromLTRB(6, 0, 6, 0),
              decoration: BoxDecoration(
                borderRadius:BorderRadius.circular(5.0),
                border:Border.all(color: Colors.grey)
              ),
              child: IconTextWidget(icon: 
                  Icon(Icons.search,size: 20,color: Colors.black,),
                  text: TextField(
                    controller: controller,
                    keyboardType: TextInputType.text,
                    autofocus: false,
                    obscureText: false,
                    style: TextStyle(
                      fontSize:TextSizeConst.smallTextSize,
                      color:Colors.black38
                    ),
                    decoration: InputDecoration(
                      hintText:"请输入搜索关键词",
                      contentPadding:EdgeInsets.all(6.0),
                      border:InputBorder.none
                    ),
                  )),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: SizedBox(
              width: 60,
              height: 30,
              child: RaisedButton(
                elevation: 0,
                highlightElevation: 0,
                color: Colors.green,
                child: Text(
                  '搜索',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color:Colors.white,
                    fontSize:12
                  ),
                  maxLines: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:BorderRadius.circular(30)
                ),
                onPressed: (){
                  var key = controller.text.toString();
                  if(key.isEmpty){
                    Fluttertoast.showToast(msg: "请输入关键词");
                    return;
                  }
                  gotoResultPage(key);
                  controller.text='';
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  buildWrapItem(){
    List<Widget> items = List();
    for(var hotword in hotWords){
      Widget item = InkWell(
        onTap: (){
          gotoResultPage(hotword.name);
        },
        child: Container(
          constraints: BoxConstraints(
            minHeight: 30,
          ),
          padding: EdgeInsets.fromLTRB(8, 5, 8, 5),
          decoration: BoxDecoration(
            borderRadius:BorderRadius.all(Radius.circular(5)),
            color:Colors.grey.withAlpha(100)
          ),
          child: Text(
            hotword.name,
            style: TextStyle(
              color: Colors.deepOrange,
              fontSize:TextSizeConst.smallTextSize
            ),
          ),
        ),
      );
      items.add(item);
    }
    return items;
  }

  Widget buildHistoryItem(Map history){
    var name = history['name'];
    return InkWell(
      onTap: (){
        gotoResultPage(name);
      },
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.android,
              color: Colors.red,
            ),
            Expanded(
              flex: 1,
              child: Padding(padding: EdgeInsets.only(left: 20),
              child: Text(name,textAlign: TextAlign.start,),),
            ),
          ],
        ),
      ),
    );
  }

  gotoResultPage(String name) async{
    var b = await DbManager.singleton.hasSameData(name);
    if(!b){
      DbManager.singleton.save(name);
    }
    CommonUtil.push(context, SearchResultPage(keyWord: name,)).then((_){
      getHistory();//当返回时，刷新一下 历史记录
    });
  }

}













