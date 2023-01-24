/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class FileAuditor implements Database.AllowsCallouts, Database.Batchable<SObject> {
    global String action;
    global Integer batchSize;
    global Datetime endDate;
    global List<String> fieldNames;
    global String filterField;
    global String objectName;
    global String query;
    global Integer queryLimit;
    global Datetime startDate;
    global FileAuditor() {

    }
    @AuraEnabled
    global static void executeAudit(String objectName, Datetime startDate, Datetime endDate, String action) {

    }
    @AuraEnabled
    global static void executeStandardAudit(String objectName, Datetime startDate, Datetime endDate, String action) {

    }
    global void execute(Database.BatchableContext BC, List<SObject> sObjects) {

    }
    global void finish(Database.BatchableContext BC) {

    }
    @AuraEnabled
    global static List<String> getManagerSettingNames() {
        return null;
    }
    global void loadQuery() {

    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return null;
    }
}
