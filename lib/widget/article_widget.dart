import 'package:flutter/material.dart';
import '../model/article.dart';
import '../net/dio_manager.dart';
import '../page/web_page.dart';
import '../utils/common.dart';
import '../utils/textsize.dart';
import 'package:flutter_html/flutter_html.dart';
import '../page/web_page.dart';


class ArticleWidget extends StatefulWidget{

  Article article;

  ArticleWidget({this.article});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ArticleWidgetState();
  }

}

class ArticleWidgetState extends State<ArticleWidget> {

  Article article;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    article = widget.article;
    return GestureDetector(
      onTap: (){
        String title = "";
        if(! isHighLight(article.title)){
          title = article.title;
        }else{
          title = article.title
              .replaceAll("<em class='highlight'>", "")
              .replaceAll("</em>", "");
        }
        CommonUtil.push(context, WebPage(title: title,url: article.link,));
      },
      child: Card(
        margin: EdgeInsets.all(5),
        child: Container(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(
                    Icons.android,
                    color: Colors.blue,
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(padding: EdgeInsets.only(left: 10),
                          child: Text(
                            '${article.author}',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              color:Colors.grey,
                              fontSize:TextSizeConst.smallTextSize
                            ),
                          ),),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${article.chapterName}/${article.superChapterName}',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        color:Colors.blue,
                        fontSize: TextSizeConst.smallTextSize
                      ),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: !isHighLight(article.title)
                              ? Text(
                            '${article.title}',
                            style: TextStyle(color: Colors.grey,fontSize: TextSizeConst.middleTextSize),
                    ) :Html(data: article.title,),),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //是否需要高亮
  bool isHighLight(String title){
    RegExp exp = new RegExp(r"<em class='highlight'>([\s\S]*?)</em>");
    return exp.hasMatch(title);
  }

  collect(){
    String url = "";
    if(!article.collect){
      url = "lg/collect/${article.id}/json";
    }else{
      url = "lg/uncollect_originId/${article.id}/json";
    }

    CommonUtil.showLoadingDialog(context);
    DioManager.singleton.post(url).whenComplete((){
      Navigator.pop(context);
    }).then((result){
      if(result!=null){
        setState(() {
          article.collect = ! article.collect;
        });
      }
    });

  }

}

















