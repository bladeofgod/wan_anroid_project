import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../model/knowledge_system.dart';
import '../../net/dio_manager.dart';
import '../../utils/common.dart';
import '../../utils/textsize.dart';
import '../../widget/page_widget.dart';
import '../../page/knowledge/knowledge_detail_page.dart';


class KnowledgePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return KnowledgePageState();
  }

}
//automatic... 保活
class KnowledgePageState extends State<KnowledgePage> with AutomaticKeepAliveClientMixin {

  RefreshController refreshController;
  List<KnowledgeSystem> datas = List();
  PageStateController pageStateController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    refreshController = RefreshController();
    pageStateController = PageStateController();
    getList();

  }

  void onRefresh(bool up){
    if(up){
      getList();
    }
  }

  void getList(){
    DioManager.singleton.get("tree/json").then((result){
      refreshController.sendBack(true, RefreshStatus.idle);
      if(result != null){
        pageStateController.changeState(PageState.LoadSuccess);
        setState(() {
          datas.clear();
          List<KnowledgeSystem> knowledges = KnowledgeSystem.parseList(result.data);
          datas.addAll(knowledges);
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
      child: SmartRefresher(
        controller: refreshController,
        enablePullDown: true,
        enablePullUp: false,
        onRefresh: onRefresh,
        child: ListView.builder(itemBuilder: (BuildContext context,int index){
          var data = datas[index];
          return buildItem(data);
        },itemCount: datas.length,),
      ),
    );
  }

  Widget buildItem(KnowledgeSystem data){
    return GestureDetector(
      onTap: (){
        CommonUtil.push(context, KnowledgeDetailPage(knowledgeSystem: data));
      },
      child: Card(
        margin: EdgeInsets.all(5),
        child: Container(
          padding: EdgeInsets.all(10),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      data.name,
                      style: TextStyle(
                        fontSize:TextSizeConst.middleTextSize,
                        color:Colors.grey
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Text(
                        parseDetail(data.children),
                        style: TextStyle(
                          color:Colors.grey,
                          fontSize:TextSizeConst.smallTextSize
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.keyboard_arrow_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String parseDetail(List<KnowledgeSystem> children){
    StringBuffer stringBuffer = StringBuffer();
    for(var item in children){
      stringBuffer.write(item.name + "   ");
    }
    return stringBuffer.toString();
  }


  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}




















