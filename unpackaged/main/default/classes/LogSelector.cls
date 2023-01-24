/*
* @Author: Apoorv (NeuraFlash)
* @CreatedDate: May'10, 2020
* @Description: Used by the logViewComponent(LWC), selects and returns the log records
*               that match the filter criteria (selected by end used via UI).
*/

public with sharing class LogSelector {
    
    public static DataTableResponse tableResponse;

    @AuraEnabled
    public static DataTableResponse getLogs(String queryFilters, String lastRecord){
        try{
            Map<String, Object> filterMap;
            tableResponse = new DataTableResponse();
            Set<String> fieldsToDisplaySet = new Set<String>();
            String logLevel;

            if(String.isBlank(queryFilters)){
               queryFilters = '{"loglevel":"Fatal","fromlogDate":"'+System.now()+'","tologDate":"'+System.now()+'"}';
            }
            filterMap = (Map<String, Object>)JSON.deserializeUntyped(queryFilters);
            logLevel = String.valueOf(filterMap.get('loglevel')).toUpperCase();
            
            for(Log_View_Setting__mdt logViewRec : [SELECT Fields_to_Display__c, Datatable_Payload__c  
                                                        FROM Log_View_Setting__mdt 
                                                            WHERE DeveloperName =: logLevel LIMIT 1]){
                tableResponse.dataTablePayload = logViewRec.Datatable_Payload__c;
                if(logViewRec.Fields_to_Display__c.contains(',')){
                    fieldsToDisplaySet.addAll(logViewRec.Fields_to_Display__c.replaceAll('(\\s+)', '').split(','));   
                } else {
                    fieldsToDisplaySet.add(logViewRec.Fields_to_Display__c);
                }
            }
            List<Log__c> logs = queryRecords(fieldsToDisplaySet, filterMap, 50, lastRecord);
            tableResponse.dataTableRecords = logs;
            return tableResponse;
        } catch(Exception ex){
            System.debug(LoggingLevel.ERROR, 'Something went wrong: LogSelector > getLogs: '+ex.getMessage());
        }
        return null;
    }

    private static List<Log__c> queryRecords(Set<String> fieldsToDisplaySet, Map<String, Object> filterMap, Integer rowsToFetch, String recordName){
        Datetime fromlogDate;
        Datetime tologDate;
        String queryString = 'SELECT Name ';
        for(String fieldAPI: fieldsToDisplaySet){
            if(!fieldAPI.equalsIgnoreCase('Name')){
                queryString += ', '+fieldAPI;
            }
        }
        queryString += ' FROM Log__c WHERE';
        if(String.isNotBlank(recordName)){
            queryString += ' Name <: recordName AND';
        }
        
        for(String filter: filterMap.keySet()){
            switch on filter.toLowerCase() {
                when 'loglevel' {	
                    String logLevel = String.valueOf(filterMap.get('loglevel')).toUpperCase();
                    queryString += ' Level__c =: logLevel';
                }
                when 'fromlogdate' {
                    String logDate = (String)filterMap.get(filter);
                    fromlogDate = Datetime.valueOfGmt(logDate.substring(0,10) + ' 00:00:00');
                    queryString += ' AND Log_Date__c >= :fromlogDate';
                }
                when 'tologdate' {
                    String logDate = (String)filterMap.get(filter);
                    tologDate = (String.isNotBlank(logDate)) ? Datetime.valueOfGmt(logDate.substring(0,10) + ' 23:59:59') : fromlogDate.addHours(24);
                    queryString += ' AND Log_Date__c <= :toLogDate';
                }
                when 'classname' {
                    String classname = (String)filterMap.get('classname');
                    if(String.isNotBlank(classname)){
                        queryString += ' AND Class_Name__c = :classname';
                    }
                }
                when 'type' {
                    String exceptionType = (String)filterMap.get('type');
                    if(String.isNotBlank(exceptionType)){
                        queryString += ' AND Type__c = :exceptionType';
                    }
                }
            }
        }
        queryString += ' ORDER BY Name DESC';
        String queryLimit = ' LIMIT 50000';
        String actualLimit = ' LIMIT '+rowsToFetch;
        queryString += queryLimit;
        List<Log__c> logList = Database.query(String.escapeSingleQuotes(queryString));
        tableResponse.totalRecordCount = (logList != null) ? logList.size() : 0;
        queryString = queryString.replace(queryLimit, actualLimit);
        return Database.query(String.escapeSingleQuotes(queryString));
    }

    public class DataTableResponse{
        @AuraEnabled
        public String dataTablePayload {get;set;}
        @AuraEnabled
        public List<SObject> dataTableRecords {get;set;}   
        @AuraEnabled
        public Integer totalRecordCount {get;set;}   
        
        public DataTableResponse(){
            dataTableRecords = new List<SObject>();
        }
    }
}