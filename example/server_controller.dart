

import 'dart:convert';
import 'dart:io';

import '../lib/src/controller.dart';

class ServerController extends Controller{

  Future<void> TestApi(HttpRequest request)async{
    //将文件和目录清单发送到客户端
          print("收到请求:${request.method} url:${request.uri}");
          //HttpResponse对象用于返回客户端
          String url = getUrl(request.uri.toString());
          request.response
            //获取和设置内容类型（报头）
            ..headers.contentType =
                new ContentType("application", "json", charset: "utf-8");
            // ..headers.add("test", "fengdeyingzi");

          //通过调用Object.toString将Object转换为一个字符串并转成对应编码发送到客户端
       
            request.response
                .write(json.encode({"code": 200, "msg": "这是一个测试API接口 "+url})); 
  }

  Future<void> PostTest(HttpRequest request) async {
    request.response
            //获取和设置内容类型（报头）
            ..headers.contentType =
                new ContentType("application", "json", charset: "utf-8");
    request.response
                .write(json.encode({"code": 200, "msg": "POST接口调用成功"})); 
  }

  //获取url
  getUrl(String uri) {
    for (int i = 0; i < uri.length; i++) {
      if (uri[i] == "?") {
        return uri.substring(0, i);
      }
    }
    return uri;
  }

}