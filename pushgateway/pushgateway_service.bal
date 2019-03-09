import ballerina/http;
import ballerina/log;
import ballerina/mime;
import ballerina/swagger;
import ballerinax/docker;
import ballerinax/kubernetes;
import ballerina/config;

listener http:Listener httpListener = new(9090);

@http:ServiceConfig {
    basePath: "/v1"
}
service PushgatewayService on httpListener {

    @http:ResourceConfig {
        methods:["POST"],
        path:"/metrics"
    }
    resource function addMetric (http:Caller caller, http:Request res) {
        http:Response metricsRes = addMetric(res);
        _ = caller->respond(metricsRes);
    }

    @http:ResourceConfig {
        methods:["GET"],
        path:"/metrics"
    }
    resource function getMetricc (http:Caller caller, http:Request res) {
        http:Response metricsRes = getMetric(res);
        _ = caller->respond(metricsRes);
    }
}
