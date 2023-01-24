/*
* @Author: Apoorv (NeuraFlash)
* @CreatedDate: May'10, 2020
* @Description: Publishes the Log_Event__e platform events, which further creates 
*               Log__c record in the system.
* @TestClass: LoggerTest
*/ 

public with sharing class LogPublisher {

    public static void publishLogs(List<Log_Event__e> logEventList){
        try{
            Log_Setting__mdt logSetting = [SELECT Logging_Enabled__c	 
                                                FROM Log_Setting__mdt 
                                                    WHERE DeveloperName = 'Log_Setting'];
                                                    
            if(logSetting != null && logSetting.Logging_Enabled__c){
                List<Database.SaveResult> results = EventBus.publish(logEventList);
                for (Database.SaveResult sr : results) {
                    if (!sr.isSuccess()) {
                        for(Database.Error err : sr.getErrors()) {
                            System.debug(LoggingLevel.ERROR, 'LogPublisher > publishLog: '+err.getMessage());
                        }
                    }       
                }
            }
         } catch(Exception ex){
            System.debug(LoggingLevel.ERROR, 'LogPublisher > publishLog: '+ex.getMessage());
        }
    }    
}