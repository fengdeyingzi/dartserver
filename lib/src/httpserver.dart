//http_server包要通过Pub下载
library simple_http_server;

import 'dart:convert';
import 'dart:io';
// import 'dart:mirrors' if (dart.librarys.flu) 'web.dart';

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
  Map<String, String> map_staticfile = new Map();
  Map<String, String> map_api = new Map();
  Map<String, String> map_type = new Map();
  HttpServer? httpServer;
  RequestHandler? _noRoute;
  HandleRouter? _router;

  String _getStringInsideQuotes(String input) {
    int startIndex = input.indexOf('\''); // 查找第一个引号的索引
    if (startIndex == -1) return ''; // 如果没有找到，引号内的字符串为空

    int endIndex = input.indexOf('\'', startIndex + 1); // 查找第二个引号
    if (endIndex == -1) return ''; // 如果没有找到第二个引号，引号内的字符串为空

    return input.substring(startIndex + 1, endIndex); // 返回引号内的字符串
  }

  String _getFunctionName(dynamic request) {
    // #ifdef SWAGGER
/*    InstanceMirror mirr = reflect(request);
    return _getStringInsideQuotes(mirr.reflectee.toString());*/
    // #else
    return '';
    // #endif

  }

  Future<void> handlePost(HttpRequest request) async {
    // var myStringStorage = await utf8.decoder.bind(request).join();
    // print(request.contentLength);
    try {
      String url = getUrl(request.uri.toString());
      if (map_post[url] != null) {
        await map_post[url]!.call(request);
      } else {
        print("未知的路由：${request.method}" + url);
        await _noRoute?.call(request);
      }
    } catch (e, trace) {
      print(e.toString());
      print(trace.toString());
    }
  }

  Future<void> handleGet(HttpRequest request) async {
    // var myStringStorage = await utf8.decoder.bind(request).join();
    // print(request.contentLength);
    try {
      String url = getUrl(request.uri.toString());
      if (map_get[url] != null) {
        await map_get[url]?.call(request);
      } else if (await handleStaticFile(request)) {
      } else if (await handleStatic(request)) {
      } else {
        print("未知的路由：${request.method}" + url);
        await _noRoute?.call(request);
      }
    } catch (e, trace) {
      print(e.toString());
      print(trace.toString());
    }
  }

  String _getContentType(String fileName) {
    // 获取文件扩展名
    final extension = fileName.split('.').last.toLowerCase();

    // 根据扩展名返回相应的 Content-Type
    switch (extension) {
      case 'html':
        return 'text/html';
      case 'css':
        return 'text/css';
      case 'js':
        return 'application/javascript';
      case 'json':
        return 'application/json';
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'gif':
        return 'image/gif';
      case 'txt':
        return 'text/plain';
      case 'pdf':
        return 'application/pdf';
      case 'xml':
        return 'application/xml';
      default:
        return 'application/octet-stream'; // 默认类型
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
        if (!file.existsSync()) {
          file = File(dir.path + Uri.decodeComponent(url.substring(key.length)));
          if(!file.existsSync())
            return false;
        }
        // print("读取文件 "+file.path);
        request.response.headers.contentType =
            ContentType.parse(_getContentType(file.path));

        // 使用File.openRead逐块读取文件
        // var bytes = await file.readAsBytes();
        // print("文件长度："+bytes.length.toString());

        await request.response.addStream(file.openRead());

        return true;
      }
    }

    return false;
  }

  Future<bool> handleStaticFile(HttpRequest request) async {
    String url = getUrl(request.uri.toString());
    var listKey = map_staticfile.keys.toList();
    for (var key in listKey) {
      var value = map_staticfile[key];
      if (url == key) {
        File file = File(value!);
        if (!file.existsSync()) {
          return false;
        }
        request.response.headers.contentType =
            ContentType.parse(_getContentType(file.path));

        // 使用File.openRead逐块读取文件
        // var bytes = await file.readAsBytes();
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
      print("未知的路由：${request.method}" + url);
      await _noRoute?.call(request);
    }
  }

  Future<void> handlePut(HttpRequest request) async {
    // var myStringStorage = await utf8.decoder.bind(request).join();
    // print(request.contentLength);
    String url = getUrl(request.uri.toString());
    if (map_put[url] != null) {
      await map_put[url]?.call(request);
    } else {
      print("未知的路由：${request.method}" + url);
      await _noRoute?.call(request);
    }
  }

  Future<void> handleOptions(HttpRequest request) async {
    // var myStringStorage = await utf8.decoder.bind(request).join();
    // print(request.contentLength);
    String url = getUrl(request.uri.toString());
    if (map_options[url] != null) {
      await map_options[url]?.call(request);
    } else {
      print("未知的路由：${request.method}" + url);
      await _noRoute?.call(request);
    }
  }

  Future<void> handleHead(HttpRequest request) async {
    String url = getUrl(request.uri.toString());
    if (map_head[url] != null) {
      await map_head[url]?.call(request);
    } else {
      print("未知的路由：${request.method}" + url);
      await _noRoute?.call(request);
    }
  }

  Future<void> handlePatch(HttpRequest request) async {
    // var myStringStorage = await utf8.decoder.bind(request).join();
    // print(request.contentLength);
    String url = getUrl(request.uri.toString());
    if (map_patch[url] != null) {
      await map_patch[url]?.call(request);
    } else {
      print("未知的路由：${request.method}" + url);
      await _noRoute?.call(request);
    }
  }

  void POST(String localUrl, RequestHandler handler) {
    map_api[localUrl] = _getFunctionName(handler);
    map_type[localUrl] = "POST";
    map_post[localUrl] = handler;
  }

  void GET(String localUrl, RequestHandler handler) {
    map_api[localUrl] = _getFunctionName(handler);
    map_type[localUrl] = "GET";
    map_get[localUrl] = handler;
  }

  bool handleRouter(HttpRequest request) {
    return true;
  }

  void Static(String localUrl, String path) {
    map_static[localUrl] = path;
  }

  void StaticFile(String localUrl, String filename) {
    map_staticfile[localUrl] = filename;
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
        await handlePost(request);
      } else if (request.method == "GET") {
        await handleGet(request);
      } else if (request.method == "DELETE") {
        await handleDelete(request);
      } else if (request.method == "PUT") {
        await handlePut(request);
      } else if (request.method == "OPTIONS") {
        await handleOptions(request);
      } else if (request.method == "HEAD") {
        await handleHead(request);
      } else if (request.method == "PATCH") {
        await handlePatch(request);
      }
    }
    //结束与客户端连接
    request.response.close();
  }

  Future<void> Run(int port) async{
    HttpServer server = await HttpServer.bind(InternetAddress.anyIPv4, port);
    httpServer = server;
      server.listen((request) {
        _handleRequest(request);
      });
  }

  Future<void> RunSSL(int port, String cert, String key) async{
     // 创建一个 SecurityContext 对象
  var context = SecurityContext();

  // 加载证书和私钥文件
  context.useCertificateChain(cert); // 'cert.pem'
  context.usePrivateKey(key); // 'key.pem'

  // 创建一个 HTTPS 服务器
  var server = await HttpServer.bindSecure(
    InternetAddress.anyIPv4,
    port, // HTTPS 默认端口
    context,
  );
    httpServer = server;
      server.listen((request) {
        _handleRequest(request);
      });
  }

  Future<void> Stop() async {
    if (httpServer != null) {
      await httpServer!.close();
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
