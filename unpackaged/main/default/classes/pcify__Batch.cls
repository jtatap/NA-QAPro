/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class Batch extends pcify.Processor implements Database.Batchable<SObject> {
    global String action;
    global Integer batchSize;
    global Datetime endDate;
    global List<String> fieldNames;
    global String filterField;
    global String objectName;
    global String query;
    global Integer queryLimit;
    global Datetime startDate;
    global Batch() {

    }
    global void execute(Database.BatchableContext BC, List<SObject> sObjects) {

    }
    global void finish(Database.BatchableContext BC) {

    }
    global void loadQuery() {

    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return null;
    }
}
