import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../model/article.dart';
import '../../model/base_data.dart';
import '../../model/base_list_data.dart';
import '../../net/dio_manager.dart';
import '../../widget/collection_article_widget.dart';
import '../../widget/page_widget.dart';
import '../../widget/title_bar.dart';


class CollectionPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return CollectionPageState();
  }

}

class CollectionPageState extends State<CollectionPage> {

  RefreshController refreshController;
  PageStateController pageStateController;
  List<Article> articles = List();
  int pageIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    refreshController = RefreshController();
    pageStateController = PageStateController();
    getList(true);
  }

  void _onRefresh(bool up) {
    if (up) {
      pageIndex = 0;
      getList(true);
    } else {
      pageIndex++;
      getList(false);
    }
  }

  void getList(bool isRefresh){
    DioManager.singleton
        .get("lg/collect/list/${pageIndex}/json")
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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: TitleBar(
        isShowBack: true,
        title: "我的收藏",
      ),
      body: PageWidget(
        controller: pageStateController,
        reloadData: () {
          getList(true);
        },
        child: SmartRefresher(
            controller: refreshController,
            enablePullDown: true,
            enablePullUp: true,
            onRefresh: _onRefresh,
            child: ListView.builder(
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  return CollectionArticleWidget(articles[index]);
                })),
      ),
    );
  }
}













