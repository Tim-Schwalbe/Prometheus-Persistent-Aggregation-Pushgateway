import ballerina/http;
import ballerina/io;
import ballerina/log;
import ballerina/auth;
import ballerina/file;

boolean fileChanged = true;
string | error? result = "";
string metricStoreFile = "store/metrics.txt";

listener file:Listener localFolder = new ({
    path: "store/",
    recursive: false
});
service fileSystem on localFolder {
    resource function onCreate(file:FileEvent m) {
        io:println("file created!");
    }
    resource function onModify(file:FileEvent m) {
        io:println("file modified!");
        result = untaint readFile(metricStoreFile);
    }
}

public function addMetric(http:Request req) returns http:Response {

    http:Response res = new;
    string | error metricReq = req.getPayloadAsString();

    //add missing replace part just for same metric_name including labels

    if (metricReq is string) {
        if (result is string) {

            io:println("Result:" + result);
            string[] fullMetric = metricReq.split(";");
            string help = fullMetric[0].trim();
            string metricType = fullMetric[1].trim();
            string metric = fullMetric[2].trim();

            result = result + "\n" + help + "\n" + metricType + "\n" + metric;
          
            io:println("newResult:" + result);

            (        int | error | ()) writeResult = writeFile(metricStoreFile, result);
            res.statusCode = 200;
            res.setJsonPayload("{result:ok}", contentType = "application/json");
            io:println(metricReq);
        } else {
            res.statusCode = 500;
            res.setJsonPayload({
                "result": "request was empty!"
            }, contentType = "application/json");
        }

    } else {
        io:println("error");
        res.statusCode = 500;
        res.setJsonPayload({
            "result": "request was empty!"
        }, contentType = "application/json");
    }

    return res;
}

public function getMetric(http:Request req) returns http:Response {
    http:Response res = new;
    if (result is string) {
        res.statusCode = 200;
        res.setTextPayload(untaint result, contentType = "text/plain");
    }
    return res;
}

public function main() returns int {
    io:println("Pushgateway started!");
    result = untaint readFile(metricStoreFile);
    return 0;
}
