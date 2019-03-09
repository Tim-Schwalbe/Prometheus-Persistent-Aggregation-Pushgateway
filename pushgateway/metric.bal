import ballerina/http;
import ballerina/io;
import ballerina/log;
import ballerina/auth;

public function addMetric (http:Request req) returns http:Response {
  
  http:Response res = new;
  string|error metricReq = req.getPayloadAsString();
  if(metricReq is string){
    res.statusCode = 200;
    res.setJsonPayload("{result:ok}", contentType = "application/json");
    io:println(metricReq);
  }else{
    io:println("error");
    res.statusCode = 500;
    res.setJsonPayload("{result:request was empty!}", contentType = "application/json");
  }

  return res;
}

public function getMetric (http:Request req) returns http:Response {
  io:print("test");
  http:Response res = new;
  return res;
}


