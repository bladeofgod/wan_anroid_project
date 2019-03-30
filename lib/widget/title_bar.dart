import 'package:flutter/material.dart';
import 'marquee_widget.dart';

class TitleBar extends StatefulWidget implements PreferredSizeWidget{
  bool isShowBack = true;
  String title = '';
  Widget leftButton;
  List<Widget> righthBtnList;

  TitleBar({this.leftButton,this.isShowBack = true,this.title,this.righthBtnList});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return TitleBarState();
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(56.0);

  static Widget textButton({String text = '',Color color = Colors.white,Function() press}){
    return InkWell(
      child: Padding(padding: EdgeInsets.all(2),
      child: Text(
        text,
        style: TextStyle(color: color),
      ),),
      onTap: press,
    );
  }

  //拱外部构建widget
  static Widget iconButton({IconData  icon,Color color=Colors.white,Function() press}){
    return IconButton(
      padding: EdgeInsets.all(2),
      icon: Icon(icon,color: color,),
      onPressed: press,
    );
  }


}

class TitleBarState extends State<TitleBar> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: BoxDecoration(
        gradient:LinearGradient(
          begin:Alignment.centerLeft,
          end: Alignment.centerRight,
          colors:[Color(0xbf46be39), Color(0xff46be39)],
        ),
      ),
      child: Stack(
        children: <Widget>[
          //整个title bar 分为水平三部分 分别是下面三个widget
          //判断是否显示返回键
          Offstage(
            offstage: !widget.isShowBack,
            child: Container(
              alignment: Alignment.centerLeft,
              child: widget.leftButton == null
                    ? IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: (){
                  Navigator.of(context).pop();
                },
                color: Colors.white,
              ):widget.leftButton,
            ),
          ),
          //标题
          Container(
            margin: EdgeInsets.symmetric(horizontal: 45),
            child: Center(
              child: MarqueeWidget(text: widget.title,height: 56,width: MediaQuery.of(context).size.width-90,
                                style: TextStyle(fontSize: 18,color: Colors.white),),
            ),
          ),
          //右侧
          Positioned(
            right: 0,
            height: 56,
            child: Container(
              child: widget.righthBtnList != null ? Row(children: widget.righthBtnList,) : null,
            ),
          ),
        ],
      ),
    );
  }
}


























