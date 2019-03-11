import ballerina/io;
import ballerina/internal;
public function readFile(string filePath) returns json | error? {
    io:ReadableByteChannel rbc = io:openReadableFile(filePath);
    io:ReadableCharacterChannel rch = new(rbc, "UTF8");

    json | error result = rch.readJson();
    if (result is error) {
        closeRc(rch);
        return result;
    } else {
        closeRc(rch);
        return result;
    }
}

public function writeFile(string filePath, json text) returns int | error? {

    internal:Path deleteFilePath = new(filePath);
    if (deleteFilePath.exists()) {
        _ = deleteFilePath.delete();
        _ = deleteFilePath.createFile();
    }
    io:WritableByteChannel wbc = io:openWritableFile(filePath);
    io:WritableCharacterChannel wch = new(wbc, "UTF8");
    var result = wch.writeJson(text);
    if (result is error) {
        closeWc(wch);
        return result;
    } else {
        closeWc(wch);
        return result;
    }
}

function closeRc(io:ReadableCharacterChannel rc) {
    var result = rc.close();
    if (result is error) {
        log:printError("Error occurred while closing character stream",
                        err = result);
    }
}

function closeWc(io:WritableCharacterChannel wc) {
    var result = wc.close();
    if (result is error) {
        log:printError("Error occurred while closing character stream",
                        err = result);
    }
}

