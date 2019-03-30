import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter/material.dart';
import '../../model/article.dart';
import '../../model/base_list_data.dart';
import '../../model/knowledge_system.dart';
import '../../net/dio_manager.dart';
import '../../widget/article_widget.dart';
import '../../widget/page_widget.dart';
import '../../widget/title_bar.dart';

class KnowledgeDetailPage extends StatefulWidget{

  KnowledgeSystem knowledgeSystem;

  KnowledgeDetailPage({@required this.knowledgeSystem});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return KnowledgeDetailPageState();
  }

}
//当你想使用tab时，需要 single ticker provider...
class KnowledgeDetailPageState extends State<KnowledgeDetailPage>
    with SingleTickerProviderStateMixin{

  TabController tabController;
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: widget.knowledgeSystem.children.length, vsync: this,initialIndex: 0);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: TitleBar(
        isShowBack: true,
        title: widget.knowledgeSystem.name,
      ),
      body: Column(
        children: <Widget>[
          TabBar(
            indicatorColor: Colors.orangeAccent,
            controller: tabController,
            isScrollable: true,
            tabs: parseTabs(),
          ),
          Expanded(
            flex: 1,
            child: TabBarView(
              controller: tabController,
              children: parsePages(),
            ),
          ),
        ],
      ),
    );
  }


  List<Widget> parseTabs(){
    List<Widget> widgetList =List();
    var children = widget.knowledgeSystem.children;
    for(KnowledgeSystem item in children){
      var tab =  Tab(
        text: item.name,
      );
      widgetList.add(tab);
    }
    return widgetList;
  }

  List<KnowledgeSingleTabPage> parsePages(){
    List<KnowledgeSingleTabPage> list = List();
    var children = widget.knowledgeSystem.children;
    for(KnowledgeSystem item in children){
      var page =KnowledgeSingleTabPage(cid: item.id,);
      list.add(page);
    }
    return list;
  }



}

//单个tab page
class KnowledgeSingleTabPage extends StatefulWidget{

  int cid;

  KnowledgeSingleTabPage({@required this.cid});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return KnowledgeSingleTabPageState();
  }

}

class KnowledgeSingleTabPageState extends State<KnowledgeSingleTabPage> with AutomaticKeepAliveClientMixin {

  int pageIndex = 0;
  List<Article> articles = List();
  RefreshController refreshController;
  PageStateController pageStateController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    refreshController = RefreshController();
    pageStateController = PageStateController();

    getList(true);

  }

  void getList(bool isRefresh){
    DioManager.singleton.get("article/list/${pageIndex}/json?cid=${widget.cid}")
        .then((result){
          refreshController.sendBack(isRefresh, RefreshStatus.idle);
          if(result != null){
            pageStateController.changeState(PageState.LoadSuccess);
            var listData = BaseListData.fromJson(result.data);
            if(pageIndex == 0){
              articles.clear();
            }
            if(listData.hasNoMore){
              refreshController.sendBack(false, RefreshStatus.noMore);
            }
            setState(() {
              articles.addAll(Article.parseList(listData.datas));
            });
          }else{
            pageStateController.changeState(PageState.LoadFail);
          }
    });
  }

  void onRefresh(bool up){
    if(up){
      pageIndex = 0;
      getList(true);
    }else{
      pageIndex++;
      getList(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return PageWidget(
      controller: pageStateController,
      reloadData: (){
        getList(true);
      },
      child: SmartRefresher(
        controller: refreshController,
        enablePullDown: true,
        enablePullUp: true,
        onRefresh: onRefresh,
        child: ListView.builder(itemBuilder: (context,index){
          return ArticleWidget(article: articles[index],);
        },itemCount: articles.length,),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

















