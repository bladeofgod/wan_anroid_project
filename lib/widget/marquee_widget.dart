import 'dart:async';
import 'package:flutter/material.dart';

//跑马灯效果  参考 https://github.com/baoolong/MarqueeWidget/blob/master/lib/marquee_flutter.dart

//tab page 标题使用的此处， 虽然跑马灯，但是并没有效果， 因为widget内部做了判断，字体长度大于200 才会有效果，具体见代码

class MarqueeWidget extends StatefulWidget{

  var width = 200.0;
  var height = 20.0;
  TextStyle style;
  String text;

  MarqueeWidget({this.width,this.height,@required this.text,style})
      : style = style == null ? TextStyle(fontSize: 16) : style;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MarqueeWidgetState();
  }

}

class MarqueeWidgetState extends State<MarqueeWidget> {

  var controller = ScrollController();
  double position = 0.0;
  Timer timer;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    timer = Timer.periodic(Duration(milliseconds: 100), (timer){
      double pixels = controller.position.pixels;
      double maxScrollExtent = controller.position.maxScrollExtent;
      if(pixels + 3.0 >= maxScrollExtent){
        position = 0;
        controller.jumpTo(position);
      }
      position +=3.0;
      controller.animateTo(position, duration: Duration(milliseconds: 90), curve: Curves.linear);
    });
  }

  Widget getStartEndWidget(){
    return Container(
      width: widget.width,
    );
  }

  Widget getCenterWidget(){
    return Align(
      alignment: Alignment.center,
      child: Text(
        widget.text,
        maxLines: 1,
        textAlign: TextAlign.center,
        style: widget.style,
      ),
    );
  }

  double getCenterWidgetWidth(){
    return widget.text.length * widget.style.fontSize;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(
      child: getCenterWidgetWidth() > widget.width ?
            ListView(
              physics: new NeverScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              controller: controller,
              children: <Widget>[
                getStartEndWidget(),
                getCenterWidget(),
                getStartEndWidget()
              ],
            ) : Text(widget.text,maxLines: 1,style: widget.style,),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    timer.cancel();
  }
}


















