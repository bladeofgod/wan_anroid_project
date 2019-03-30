import 'package:flutter/material.dart';
import '../../model/base_data.dart';
import '../../model/project_sort.dart';
import '../../net/dio_manager.dart';
import '../../widget/load_fail_widget.dart';
import '../../widget/async_snapshot_widget.dart';
import '../../page/project/project_list_page.dart';


class ProjectPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ProjectPageState();
  }

}

class ProjectPageState extends State<ProjectPage>
  with AutomaticKeepAliveClientMixin,SingleTickerProviderStateMixin{

  TabController tabController;
  List<ProjectSort> sorts = List();


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    /*
  * FB 根据 future的异步方法 所处的不同状态，返回不同的widget
  *
  * 具体状态 由snapshot 查看;
  *
  * 当gettags 异步方法执行时， 时间轴上的状态会以snapshot 形式传给 buildFuture 方法 见参数
  * buildFuture根据 snapshot 的不同状态，显示不同的widget
  * 这里将一个方法传给 AsyncSnapshotWidget 当 async snapshot 的状态为成功时，调用该方法以对数据进行处理
  *
  * */
    return FutureBuilder(builder: buildFuture,future: getTags(),);
  }

  Widget buildFuture(BuildContext context, AsyncSnapshot snapshot){

    return AsyncSnapshotWidget(
      snapshot: snapshot,
      successWidget: (snapshot){
        ResultData resultData = snapshot.data;
        if(resultData != null){
          List<ProjectSort> list = ProjectSort.parseList(resultData.data);
          sorts.clear();
          sorts.addAll(list);
          if(tabController  == null){
            tabController = TabController(length: sorts.length, vsync: this,initialIndex: 0);
          }
          return Column(
            children: <Widget>[
              //顶部tab
              TabBar(
                indicatorColor: Colors.blue,
                controller: tabController,
                isScrollable: true,
                tabs:parseTabs(),
              ),
              //content
              Expanded(
                flex: 1,
                child: TabBarView(
                  controller: tabController,
                  children: parsePages(),
                ),
              ),
            ],
          );
        }else{
          return LoadFailWidget(
            onTap: (){

            },
          );
        }
      },
    );

  }

  Future getTags() async{
    return DioManager.singleton.get("project/tree/json");
  }

  List<Widget> parseTabs(){
    List<Widget> widgets = List();
    for(ProjectSort item in sorts){
      var tab = Tab(
        text: item.name,
      );
      widgets.add(tab);
    }
    return widgets;
  }

  parsePages(){
    List<ProjectListPage> pages = List();
    for(ProjectSort item in sorts){
      var page = ProjectListPage(cid: item.id,);
      pages.add(page);
    }
    return pages;
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}