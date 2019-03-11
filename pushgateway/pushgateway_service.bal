import ballerina/http;
import ballerina/log;
import ballerina/mime;
import ballerina/config;
import ballerina/io;

listener http:Listener httpListener = new(9090);

@http:ServiceConfig {
    basePath: "/v1"
}

service PushgatewayService on httpListener {

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/metrics"
    }
    resource function addMetric(http:Caller caller, http:Request res) {
        http:Response metricsRes = addMetric(res);
        _ = caller->respond(metricsRes);
    }
}
