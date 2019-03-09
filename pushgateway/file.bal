import ballerina/io;
public function readFile(string filePath) returns string | error? {
    io:println("reading file!");
    io:ReadableByteChannel byteChannel = io:openReadableFile(filePath);
    io:ReadableCharacterChannel sourceChannel = new(io:openReadableFile(filePath), "UTF-8");
    string content = check sourceChannel.read(10000);
    closeRc(sourceChannel);
    return content;
}

public function writeFile(string filePath, string text) returns int | error? {
    io:WritableCharacterChannel destinationChannel = new(io:openWritableFile(filePath, append = true), "UTF-8");
    int writeCharResult = check destinationChannel.write(text, 0);
    closeWc(destinationChannel);
    return writeCharResult;
}

function closeRc(io:ReadableCharacterChannel ch) {
    var cr = ch.close();
    if (cr is error) {
        log:printError("Error occured while closing the channel: ", err = cr);
    }
}

function closeWc(io:WritableCharacterChannel ch) {
    var cr = ch.close();
    if (cr is error) {
        log:printError("Error occured while closing the channel: ", err = cr);
    }
}
