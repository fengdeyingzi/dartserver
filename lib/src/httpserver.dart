//http_server包要通过Pub下载
library simple_http_server;

import 'dart:convert';
import 'dart:io';

typedef RequestHandler = Future<void> Function(HttpRequest request);
typedef HandleRouter = bool Function(HttpRequest request);

class HTTPServer {
  Map<String, RequestHandler> map_post = new Map();
  Map<String, RequestHandler> map_get = new Map();
  Map<String, RequestHandler> map_delete = new Map();
  Map<String, RequestHandler> map_put = new Map();
  Map<String, RequestHandler> map_options = new Map();
  Map<String, RequestHandler> map_head = new Map();
  Map<String, RequestHandler> map_patch = new Map();
  Map<String, String> map_static = new Map();
  HttpServer? httpServer;
  RequestHandler? _noRoute;
  HandleRouter? _router;

  Future<void> handlePost(HttpRequest request) async {
    // var myStringStorage = await utf8.decoder.bind(request).join();
    // print(request.contentLength);
    String url = getUrl(request.uri.toString());
    if (map_post[url] != null) {
      await map_post[url]!.call(request);
    } else {
      print("未知的路由：" + url);
      _noRoute?.call(request);
    }
  }

  Future<void> handleGet(HttpRequest request) async {
    // var myStringStorage = await utf8.decoder.bind(request).join();
    // print(request.contentLength);
    String url = getUrl(request.uri.toString());
    if (map_get[url] != null) {
      await map_get[url]?.call(request);
    } else if (await handleStatic(request)) {
    } else {
      print("未知的路由：" + url);
      _noRoute?.call(request);
    }
  }

  Future<bool> handleStatic(HttpRequest request) async {
    String url = getUrl(request.uri.toString());
    var listkey = map_static.keys;
    for (var key in listkey) {
      var value = map_static[key];
      if (url.startsWith(key)) {
        Directory dir = Directory(value!);
        File file = File(dir.path + url.substring(key.length));
        if(!file.existsSync()){
          return false;
        }
        // print("读取文件 "+file.path);
        request.response.headers.contentType = ContentType("application", "octet-stream");

         // 使用File.openRead逐块读取文件
          var bytes = await file.readAsBytes();
          // print("文件长度："+bytes.length.toString());
          
          await request.response.addStream(file.openRead());
        
        return true;
      }
     }
    
    return false;
  }

  Future<void> handleDelete(HttpRequest request) async {
    // var myStringStorage = await utf8.decoder.bind(request).join();
    // print(request.contentLength);
    String url = getUrl(request.uri.toString());
    if (map_delete[url] != null) {
      await map_delete[url]?.call(request);
    } else {
      print("未知的路由：" + url);
      _noRoute?.call(request);
    }
  }

  Future<void> handlePut(HttpRequest request) async {
    // var myStringStorage = await utf8.decoder.bind(request).join();
    // print(request.contentLength);
    String url = getUrl(request.uri.toString());
    if (map_put[url] != null) {
      await map_put[url]?.call(request);
    } else {
      print("未知的路由：" + url);
      _noRoute?.call(request);
    }
  }

  Future<void> handleOptions(HttpRequest request) async {
    // var myStringStorage = await utf8.decoder.bind(request).join();
    // print(request.contentLength);
    String url = getUrl(request.uri.toString());
    if (map_options[url] != null) {
      await map_options[url]?.call(request);
    } else {
      print("未知的路由：" + url);
      _noRoute?.call(request);
    }
  }

  Future<void> handleHead(HttpRequest request) async {
    String url = getUrl(request.uri.toString());
    if (map_head[url] != null) {
      await map_head[url]?.call(request);
    } else {
      print("未知的路由：" + url);
      _noRoute?.call(request);
    }
  }

  Future<void> handlePatch(HttpRequest request) async {
    // var myStringStorage = await utf8.decoder.bind(request).join();
    // print(request.contentLength);
    String url = getUrl(request.uri.toString());
    if (map_patch[url] != null) {
      await map_patch[url]?.call(request);
    } else {
      print("未知的路由：" + url);
      _noRoute?.call(request);
    }
  }

  void POST(String localUrl, RequestHandler handler) {
    map_post[localUrl] = handler;
  }

  void GET(String localUrl, RequestHandler handler) {
    map_get[localUrl] = handler;
  }

  bool handleRouter(HttpRequest request) {
    return true;
  }

  void Static(String localUrl, String path) {
    map_static[localUrl] = path;
  }

  Future<void> handleNoRoute(HttpRequest request) async {
    request.response
      //获取和设置内容类型（报头）
      ..headers.contentType =
          new ContentType("application", "json", charset: "utf-8");
    // ..headers.add("test", "fengdeyingzi");
    request.response.write(json.encode({"code": 404, "msg": "404 Not Found"}));
  }

  //设置前置处理
  void Use(HandleRouter handleRouter) {
    _router = handleRouter;
  }

  //设置位置路由页面
  void NoRoute(RequestHandler handler) {
    _noRoute = handler;
  }

  void _handleRequest(HttpRequest request) async {
    if (_router == null) {
          _router = handleRouter;
        }
        if (_noRoute == null) {
          _noRoute = handleNoRoute;
        }

        if (_router!.call(request)) {
          if (request.method == "POST") {
            handlePost(request);
          } else if (request.method == "GET") {
            await handleGet(request);
          } else if (request.method == "DELETE") {
            handleDelete(request);
          } else if (request.method == "PUT") {
            handlePut(request);
          } else if (request.method == "OPTIONS") {
            handleOptions(request);
          } else if (request.method == "HEAD") {
            handleHead(request);
          } else if (request.method == "PATCH") {
            handlePatch(request);
          }
        }
        //结束与客户端连接
        request.response.close();
  }

  void Run(int port) {
    HttpServer.bind(InternetAddress.anyIPv4, port).then((server) {
      httpServer = server;
      server.listen((request) {
        _handleRequest(request);
      });
    });
  }

  void Stop() {
    if (httpServer != null) {
      httpServer!.close();
      httpServer = null;
    }
  }

/**
	 * 解析出url参数中的键值对
	 * 如 "index.jsp?Action=del&id=123"，解析出Action:del,id:123存入map中
	 * @param URL  url地址
	 * @return  url请求参数部分
	 */
  Map<String, String> URLRequest(String URL) {
    Map<String, String> mapRequest = new Map<String, String>();

    var list_param = URL.split('&');
    for (var item_param in list_param) {
      var param = item_param.split('=');
      if (param.length == 2) mapRequest[param[0]] = param[1];
    }

    return mapRequest;
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
