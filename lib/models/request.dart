import 'package:app_example/repository/database_creator.dart';

class Request {
int requestId;
String result;
String taskStatus;
bool isActive;

Request(this.requestId, this.result, this.taskStatus, this.isActive);

Request.fromJson(Map<String, dynamic> json){
    this.requestId = json[DatabaseCreator.requestId];
    this.result = json[DatabaseCreator.result];
    this.taskStatus = json[DatabaseCreator.taskStatus];
    this.isActive = json[DatabaseCreator.isActive] == 1;
  }

}