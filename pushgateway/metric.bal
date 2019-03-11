import ballerina/http;
import ballerina/io;
import ballerina/log;
import ballerina/auth;
import ballerina/file;
import ballerina/observe;

boolean fileChanged = true;
json | error? metricsJson = "";
string metricStoreFile = "store/metrics.json";

// listener file:Listener localFolder = new ({
//     path: "store/",
//     recursive: false
// });
// service fileSystem on localFolder {
//     resource function onCreate(file:FileEvent m) {
//         io:println("file created!");
//     }
//     resource function onModify(file:FileEvent m) {
//         io:println("file modified!");
//         metricsJson = untaint readFile(metricStoreFile);
//     }
// }

public function addMetric(http:Request req) returns http:Response {

    http:Response res = new;
    string | error metricReq = req.getPayloadAsString();

    //add missing replace part just for same metric_name including labels

    if (metricReq is string) {
        if (metricsJson is json) {

            string[] fullMetric = metricReq.split(";");
            if (fullMetric.length() < 3) {
                res.statusCode = 500;
                res.setJsonPayload({
                    "error": "Please use following format:'#HELP help text;#TYPE metricname <gauge|counter>; metricname <value>"
                }, contentType = "application/json");
                return res;
            }
            


            string help = fullMetric[0].trim();
            string metricType = fullMetric[1].trim();
            string metric = fullMetric[2].trim();
            string metricSubstring = metric.substring(0, metric.lastIndexOf(" "));
            string metricValue = metric.substring(metric.lastIndexOf(" "), metric.length()).trim();

            metricsJson.metrics[metricSubstring] = {
                "help": help,
                "type": metricType,
                "metric": metricSubstring,
                "value": metricValue
            };

            (        int | error | ()) writeMetricsJson = writeFile(metricStoreFile, metricsJson);
            res.statusCode = 200;
            res.setJsonPayload("{metricsJson:ok}", contentType = "application/json");
            io:println(metricReq);
        } else {
            res.statusCode = 500;
            res.setJsonPayload({
                "error": "bad request!"
            }, contentType = "application/json");
        }

    } else {
        io:println("error");
        res.statusCode = 500;
        res.setJsonPayload({
            "metricsJson": "request was empty!"
        }, contentType = "application/json");
    }

    return res;
}

public function getMetric(http:Request req) returns http:Response {
    http:Response res = new;
    if (metricsJson is string) {
        res.statusCode = 200;
        res.setTextPayload(untaint metricsJson, contentType = "text/plain");
    }
    return res;
}

public function main() returns int {
    io:println("Pushgateway started!");
    metricsJson = untaint readFile(metricStoreFile);
    return 0;
}
