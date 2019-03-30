import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../model/base_list_data.dart';
import '../../model/project.dart';
import '../../net/dio_manager.dart';
import '../../page/web_page.dart';
import '../../utils/common.dart';
import '../../utils/textsize.dart';
import '../../widget/page_widget.dart';


class ProjectListPage extends StatefulWidget{

  int cid = 0;

  ProjectListPage({@required this.cid});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ProjectListPageState();
  }

}

class ProjectListPageState extends State<ProjectListPage> with AutomaticKeepAliveClientMixin {

  int pageIndex = 1;
  RefreshController refreshController;
  PageStateController pageStateController;
  List<Project> projects = List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    refreshController = RefreshController();
    pageStateController = PageStateController();

    getList(true);
  }
  void getList(bool isRefresh){
    DioManager.singleton
        .get("project/list/${pageIndex}/json?cid=${widget.cid}")
        .then((result){
          refreshController.sendBack(isRefresh, RefreshStatus.idle);
          if(result != null){
            pageStateController.changeState(PageState.LoadSuccess);
            var baseListData =BaseListData.fromJson(result.data);
            if(pageIndex == 1){
              projects.clear();
            }
            if(baseListData.hasNoMore){
              refreshController.sendBack(false, RefreshStatus.noMore);
            }
            setState(() {
              projects.addAll(Project.parseList(baseListData.datas));
            });
          }else{
            pageStateController.changeState(PageState.LoadFail);
          }
    });
  }

  void onRefresh(bool up){
    if(up){
      pageIndex = 1;
      getList(up);
    }else{
      pageIndex++;
      getList(up);
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
        enablePullUp: true,
        enablePullDown: true,
        onRefresh: onRefresh,
        child: ListView.builder(
          itemCount: projects.length,
          itemBuilder: (context,index){
            return buildItem(projects[index]);
          },
        ),
      ),
    );
  }

  Widget buildItem(Project item){
    return GestureDetector(
      onTap: (){
        CommonUtil.push(context, WebPage(
          title: item.title,
          url: item.link,
        ));
      },
      child: Card(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Row(
            children: <Widget>[
              CachedNetworkImage(
                fit: BoxFit.fill,
                width: 100,
                height: 200,
                imageUrl: item.envelopePic,
                placeholder: ImageIcon(AssetImage("assets/logo.png"),size: 100,),
                errorWidget: Icon(Icons.info_outline),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.only(left: 10),
                  alignment: Alignment.topLeft,
                  height: 200,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.android,
                            color: Colors.green,
                          ),
                          Expanded(
                            flex: 1,
                            child: Padding(padding: EdgeInsets.only(left: 10),
                            child: Text(
                              '${item.title}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                color:Colors.grey,
                                fontSize:TextSizeConst.middleTextSize,
                              ),
                            ),),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 15),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Text(
                                '${item.author}',
                                maxLines: 1,
                                style: TextStyle(color: Colors.black54),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              item.niceDate,
                              style: TextStyle(
                                color:Colors.black,
                                fontSize: TextSizeConst.minTextSize,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(padding: EdgeInsets.only(top: 10),
                          child: Text(
                            item.desc,
                            maxLines: 6,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.black),
                          ),),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}















