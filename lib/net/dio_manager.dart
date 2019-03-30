import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import '../utils/event_bus.dart';
import '../event/error_event.dart';
import '../utils/cookie_util.dart';
import 'dart:convert';
import '../model/base_data.dart';



class DioManager{
  Dio _dio;

  DioManager._internal(){
    _dio = new Dio(
      Options(
        baseUrl: "https://www.wanandroid.com/",
        connectTimeout: 10000,
        receiveTimeout: 3000
      )
    );

    CookieUtil.getCookiePath().then((path){
      _dio.cookieJar = PersistCookieJar(dir: path);
    });

    _dio.interceptor.response.onError = (DioError e){
      //when request occur a error , do something
      EventUtil.eventBus.fire(e);
      return e;
    };

  }

  static DioManager singleton = DioManager._internal();

  factory DioManager() => singleton;

  get dio{
    return _dio;
  }

  Future<ResultData> get(url,{data,options,cancelToken})async{
    Response response;
    ResultData resultData;

    try{
      response = await dio.get(
        url,
        data : data,
        options : options,
        cancelToken : cancelToken
      );

      resultData = ResultData.fromJson(
        response.data is String ? json.decode(response.data) : response.data
      );
      if(resultData.errorCode < 0){
        EventUtil.eventBus.fire(ErrorEvent(resultData.errorCode,resultData.errorMsg));
        resultData = null;
      }

    }on DioError catch(e){
      if(CancelToken.isCancel(e)){
        print('get请求取消! ' + e.message);
      }
      print('get请求取消! ' + "$e");
    }
    return resultData;

  }

  Future<Response> getNormal(url,{data,options,cancelToken})async{
    Response response;
    try{
      response = await _dio.get(
        url,
        data: data,
        options: options,
        cancelToken: cancelToken
      );
    }on DioError catch(e){
      if(CancelToken.isCancel(e)){
        print('get请求取消! ' + e.message);
      }
      print('get请求取消! ' + "$e");
    }
    return response;
  }

  Future<ResultData> post(url,{data,options,cancelToken}) async{
    Response response;
    ResultData resultData;

    try{
      response = await _dio.get(
        url,
        data: data,
        options: options,
        cancelToken: cancelToken
      );

      resultData = ResultData.fromJson(
        response.data is String ? json.decode(response.data) : response.data
      );

      if(resultData.errorCode<0){
        EventUtil.eventBus.fire(ErrorEvent(resultData.errorCode,resultData.errorMsg));
        resultData = null;
      }

    }on DioError catch(e){
      if (CancelToken.isCancel(e)) {
      print('post请求取消! ' + e.message);
    }
    print('post请求发生错误：$e');
    }
    return resultData;

  }

  Future<Response> postNormal(url,{data,options,cancelToken})async{

    Response response;
    try{
      response = await _dio.get(
        url,
        data: data,
        options: options,
        cancelToken: cancelToken
      );
    } on DioError catch (e) {
      if (CancelToken.isCancel(e)) {
        print('post请求取消! ' + e.message);
      }
      print('post请求发生错误：$e');
    }
    return response;

  }




}


















