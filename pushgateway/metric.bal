import ballerina/http;
import ballerina/io;
import ballerina/log;
import ballerina/auth;
import ballerina/file;
import ballerina/observe;

boolean fileChanged = true;
json | error? metricsJson = "";
string metricStoreFile = "store/metrics.json";
map<observe:Counter> publishedMetricMap = {

};

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
            string metricWithLabels = metric.substring(0, metric.lastIndexOf(" "));
            string metricName = metricWithLabels.substring(0, metricWithLabels.indexOf("{")).trim();
            string labels = metricWithLabels.substring(metric.indexOf("{") + 1, metricWithLabels.lastIndexOf("}")).trim();
            string metricValue = metric.substring(metric.lastIndexOf(" "), metric.length()).trim();

            int | error actual = int.convert(metricsJson.metrics[metricWithLabels].value);
            int actualVerified;
            if (actual is int) {
                actualVerified = actual;
            } else {
                actualVerified = 0;
            }
            int addValueVerified;
            int | error | () addValue = int.convert(metricValue);
            if ( addValue is int) {
                addValueVerified = addValue;
            } else {
                addValueVerified = 0;
            }
            int newValue = actualVerified + addValueVerified;
            metricsJson.metrics[metricWithLabels] = {
                "help": help,
                "metricType": metricType,
                "metricName": metricName,
                "labels": labels,
                "value": newValue
            };

            (        int | error | ()) writeMetricsJson = writeFile(metricStoreFile, metricsJson);

            publishMetric(help, metricType, metricWithLabels, metricName, labels, addValueVerified);

            res.statusCode = 200;
            res.setJsonPayload("{sucess:metric saved!}", contentType = "application/json");
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
public function main() returns int {
    io:println("Pushgateway started!");
    metricsJson = untaint readFile(metricStoreFile);
    publishAllMetrics();
    return 0;
}

function publishMetric(string help, string metricType, string metricWithLabels, string metricName, string labels, int newValue) {

    map<string> labelsMap = {

    };

    string[] labelArray = labels.split(",");
    foreach string item in labelArray {
        string[] tag = item.split("=");
        string key = tag[0].trim();
        string value = tag[1].replace("\"", "").trim();
         labelsMap[key] = value;
    }
    observe:Counter | () registeredCounter = publishedMetricMap[metricWithLabels];
    if (registeredCounter is ()) {
        observe:Counter newRegisteredCounter = new observe:Counter(metricName,desc = help, tags = labelsMap);
        _ = newRegisteredCounter.register();
        newRegisteredCounter.increment(amount = newValue);
        publishedMetricMap[metricWithLabels] = newRegisteredCounter;
    } else {
        registeredCounter.increment(amount = newValue);
        publishedMetricMap[metricWithLabels] = registeredCounter;
    }

}


function publishAllMetrics() {
    string metricWithLabel = "";
    string help = "";
    string metricType = "";
    string labels = "";
    string metricName = "";

    int | error metricValue;

    if (metricsJson is json) {

        if (metricsJson.length() > 0) {
            int i = 0;
            string[] keys = metricsJson.metrics.getKeys();
            while (i < metricsJson.metrics.length()) {
                string metricWithLabels =keys[i];
                json singleMetric = metricsJson.metrics[metricWithLabels];
                help = singleMetric.help.toString();
                metricType = singleMetric.metricType.toString();
                metricName = singleMetric.metricName.toString();
                labels = singleMetric.labels.toString();
                metricValue =int.convert(singleMetric.value);
                if(metricValue is int){
                publishMetric(help, metricType, metricWithLabels, metricName, labels, metricValue);
                }
                i = i + 1;
            }

        }
    }
}
