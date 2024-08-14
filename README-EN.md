English | [简体中文](README.md)

# DartServer
A streamlined HTTP server written in Dart, with usage methods similar to Golang's Gin framework

## Simple usage example
example/dartserver_example.dart
```dart
//Create an HTTP service
HTTPServer server = new HTTPServer();
ServerController controller = new ServerController();
//Example GET interface
server.GET("/api/testApi",  controller.TestApi);
//Example POST interface
server.POST("/api/postTest",  controller.PostTest);
//Define a route for a static file
server.StaticFile("/.gitignore", ".gitignore");
//Define a folder route
server.Static("/test", "./test");
Print (Start Starting Service) http://127.0.0.1:8081 ");
//Start service
server.Run(8081);
```
