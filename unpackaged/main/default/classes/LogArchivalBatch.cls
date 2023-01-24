/*
* @Author: Apoorv (NeuraFlash)
* @CreatedDate: May'26, 2020
* @Description: Archives or Deletes the Log__c records present in the system. 
*               Controlled via Log_Setting__mdt configuration.
*/

public class LogArchivalBatch implements Database.Batchable<SObject>{
   
    public String queryString;
    public Boolean isDelete = false;
    public Integer retentionPeriodInDays;
    public String commaSeparatedFields;
    public Set<String> fieldSet;

    public LogArchivalBatch(){
        fieldSet = new Set<String>();
        for(Log_Setting__mdt logSetting: [SELECT Field_Set__c, Data_Strategy__c, Data_Retention_Period_In_Days__c 
                                            FROM Log_Setting__mdt 
                                                WHERE DeveloperName = 'Log_Setting' LIMIT 1]){
            isDelete = (logSetting.Data_Strategy__c == 'Delete') ? true : false;
            retentionPeriodInDays = (Integer)logSetting.Data_Retention_Period_In_Days__c;
            commaSeparatedFields = logSetting.Field_Set__c;
            if(String.isNotBlank(commaSeparatedFields) && commaSeparatedFields.contains(',')){
                fieldSet.addAll(commaSeparatedFields.replaceAll('(\\s+)', '').split(','));   
            } else {
                fieldSet.add(commaSeparatedFields);
            }
        }        
        queryString = 'SELECT Name ';
        if(!isDelete){
            queryString += ', '+commaSeparatedFields; 
        }
        queryString += ' FROM Log__c WHERE CreatedDate >= LAST_N_DAYS:'+retentionPeriodInDays+' ORDER BY CreatedDate';   
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(queryString);
    }

    public void execute(Database.BatchableContext bc, List<Log__c> scope){
        try{
            List<LogHistory__b> logHistoryList = new List<LogHistory__b>();
            List<Log__c> logsToDeleteList = scope;

            if(!isDelete){
                logsToDeleteList = new List<Log__c>();
                for(Log__c logRecord: scope){
                    LogHistory__b logHistory = new LogHistory__b();
                    logHistory.Log_Record_Id__c = logRecord.Id;
                    for(String fieldAPIName: fieldSet){
                        logHistory.put(fieldAPIName,logRecord.get(fieldAPIName));
                    }
                    logHistoryList.add(logHistory);
                }
                if(!logHistoryList.isEmpty() && !Test.isRunningTest()){
                    List<Database.SaveResult> srList = Database.insertImmediate(logHistoryList);
                    if(isArchivalSuccessful(srList)){
                        logsToDeleteList = scope;
                    }
                }
            }
            deleteLogs(logsToDeleteList);
        } catch(Exception ex){
            Logger.logException(ex);
        }
    }

    private void deleteLogs(List<Log__c> logsToDeleteList){
        if(logsToDeleteList != null && !logsToDeleteList.isEmpty()){
            delete logsToDeleteList;
        }
    }

    // TODO: Partial Deletion (big object limitation) or send out an email notification.
    @TestVisible
    private Boolean isArchivalSuccessful(List<Database.SaveResult> srList){
        for(Database.SaveResult sr: srList){
            if(!sr.isSuccess()){
                return false;
            }
        }
        return true;
    }

    public void finish(Database.BatchableContext bc){}
}