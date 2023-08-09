/*
* @Author: Apoorv (NeuraFlash)
* @CreatedDate: June'01, 2020
*/
@isTest(isParallel=false)
private class LogSelectorTest {

    private enum LogLevel {FATAL, ERROR, INFO, DEBUG}

    @testSetup
    static void testDataSteup(){
        List<Log__c> logList  = new List<Log__c>();
        for(Integer i=0; i<150; i++){
            Log__c newLog = new Log__c();
            newLog.Level__c = String.valueof(LogLevel.FATAL);
            newLog.Log_Date__c = System.now();
            newLog.Type__c = 'System.NullPointerException';
            newLog.Message__c = 'null input to JSON parser';
            newLog.Class_Name__c = 'TestClassName';
            newLog.Method_Name__c = 'testMethod';
            logList.add(newLog);
        }
        insert logList;
    }

    @IsTest
    static void testGetLogs(){
        String queryfilters = '{"loglevel":"Fatal","fromlogDate":"'+System.now()+'","tologDate":"'+System.now()+'","classname":"TestClassName","type":"System.NullPointerException"}';
        Test.startTest();
            LogSelector.DataTableResponse dtResponse = LogSelector.getLogs(queryfilters, null);
        Test.stopTest();
        System.assertEquals(true, dtResponse.dataTableRecords.size()>0,'FATAL');
    }

    @IsTest
    static void testLogArchivalBatch(){
        String cronExpression = '0 0 0 06 12 ? *';
        Test.startTest();
            System.schedule('ScheduledApexTest', cronExpression, new LogArchivalBatchScheduler());
        Test.stopTest();
        System.assertEquals(true, [SELECT Id FROM Log__c].size()>0, 'FATAL');
    }
}