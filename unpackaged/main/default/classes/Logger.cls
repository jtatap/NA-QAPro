/*
* @Author: Apoorv (NeuraFlash)
* @CreatedDate: May'10, 2020
* @Description: Static class used for logging messages. 
*               Consists of different methods for hanlding logging activities for an application
* @TestClass: LoggerTest
*/ 

public with sharing class Logger {

    private static List<Log_Event__e> logEventList;
    private enum LogLevel {FATAL, ERROR, INFO, DEBUG}

    public static void logAPIInfo(HttpRequest apiRequest, HttpResponse apiResponse){
        Log_Event__e logEvent = new Log_Event__e();
        logEvent.API_Request__c = String.valueOf(apiRequest);
        logEvent.API_Response__c = String.valueOf(apiResponse) + ' Response Body: '+apiResponse.getBody();
        populateLog(logEvent,String.valueOf(LogLevel.INFO));
        publishLog(logEvent);
    }

    public static void logException(Exception ex){
        Log_Event__e logEvent = new Log_Event__e();
        logEvent.Message__c = ex.getMessage();
        logEvent.Type__c = ex.getTypeName();
        logEvent.Stack_Trace__c = ex.getStackTraceString();
        populateLog(logEvent,String.valueOf(LogLevel.FATAL));
        StackTraceUtility.populateClassAndMethodName(logEvent,ex.getStackTraceString());
        publishLog(logEvent);
    }

    public static void logError(String errorMessage){
        Log_Event__e logEvent = new Log_Event__e();
        logEvent.Message__c = errorMessage;
        populateLog(logEvent,String.valueOf(LogLevel.ERROR));
        publishLog(logEvent);
    }

    public static void logDatabaseError(List<Database.SaveResult> srList){
        List<Log_Event__e> logEventList = new List<Log_Event__e>();
        Set<String> errMsgSet = new Set<String>();
        DateTime currentTimeStamp;
        for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess()) {              
                for(Database.Error err : sr.getErrors()) {
                    String recordId = sr.getId();
                    Log_Event__e logEvent = new Log_Event__e();
                    logEvent.Message__c = err.getMessage();
                    logEvent.Record_Id__c = String.isNotBlank(recordId) ? recordId : 'NA';
                    populateLog(logEvent,String.valueOf(LogLevel.ERROR));
                    logEventList.add(logEvent);
                }
            }
        }
        if(!logEventList.isEmpty()){
            LogPublisher.publishLogs(logEventList);
        }
    }

    public static void logDebug(){
        if(Log.logEntries != null && !Log.logEntries.isEmpty()){
            Log_Event__e logEvent = new Log_Event__e();
            logEvent.Message__c = String.join(Log.logEntries, ' <br/>');
            populateLog(logEvent,String.valueOf(LogLevel.DEBUG));
            publishLog(logEvent);
        }
    }

    private static void populateLog(Log_Event__e logEvent, String loglevel){
        logEvent.Level__c = loglevel;
        logEvent.User_Info__c = UserInfo.getUserName() + ' - ' + UserInfo.getUserId();
        logEvent.Log_Date__c = System.now();
    }

    private static void publishLog(Log_Event__e logEvent){
        LogPublisher.publishLogs(new List<Log_Event__e>{logEvent});
    }
}