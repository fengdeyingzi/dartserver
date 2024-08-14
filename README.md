[English](README-EN.md) | 简体中文

# DartServer
用dart编写的一个精简的http服务器，使用方法类似golang的gin框架

## 简单使用例子
example/dartserver_example.dart
```dart
  //创建一个 http 服务
  HTTPServer server = new HTTPServer();
  ServerController controller = new ServerController();
  //示例GET接口
  server.GET("/api/testApi", controller.TestApi);
  //示例POST接口
  server.POST("/api/postTest", controller.PostTest);
  //定义一个静态文件的路由
  server.StaticFile("/.gitignore", ".gitignore");
  //定义一个文件夹路由
  server.Static("/test", "./test");
  print("开始启动服务 http://127.0.0.1:8081");
  //启动服务
  server.Run(8081);
```