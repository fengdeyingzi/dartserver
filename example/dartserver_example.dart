import 'package:dartserver/dartserver.dart';
import 'server_controller.dart';

void main() {
  //创建一个http服务
  HTTPServer server = new HTTPServer();
  ServerController controller = new ServerController();
  //添加路由
  server.GET("/api/testApi", controller.TestApi);
  server.POST("/api/postTest", controller.PostTest);
  print("开始启动服务 http://127.0.0.1:8081");
  //启动服务
  server.Run(8081);
}
