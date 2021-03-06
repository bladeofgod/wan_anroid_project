import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../model/article.dart';
import '../../model/base_list_data.dart';
import '../../net/dio_manager.dart';
import '../../widget/article_widget.dart';
import '../../widget/title_bar.dart';
import '../../widget/page_widget.dart';


class SearchResultPage extends StatefulWidget{

  String keyWord;

  SearchResultPage({this.keyWord});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SearchResultPageState();
  }

}

class SearchResultPageState extends State<SearchResultPage> {

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
  void onRefresh(bool up){
    if(up){
      pageIndex = 0;
      getList(up);
    }else{
      pageIndex++;
      getList(up);
    }
  }

  void getList(bool isRefresh){

    DioManager.singleton
        .get("article/query/${pageIndex}/json",
              data: FormData.from({"k":widget.keyWord}))
        .then((result){
          refreshController.sendBack(isRefresh, RefreshStatus.idle);
          print(result.toString());
          print("result outside");
          if(result != null){
            print("result is not null");
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
        title: widget.keyWord,
      ),
      body: PageWidget(
        reloadData: (){
          getList(true);
        },
        controller: pageStateController,
        child: SmartRefresher(
          controller: refreshController,
          enablePullDown: true,
          enablePullUp: true,
          onRefresh: onRefresh,
          child: ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context,index){
              return ArticleWidget(article: articles[index],);
            },
          ),
        ),
      ),
    );
  }
}
















