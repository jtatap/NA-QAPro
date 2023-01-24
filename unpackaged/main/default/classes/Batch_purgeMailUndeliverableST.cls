/* Story No : NASSC-1135
 *  Class: Batch_purgeMailUndeliverableST
 *  Description : Batch class to Delete  DirectMailUndeliverableStaging__c	Records with CreatedDate > (Today - 21)
 */

global class Batch_purgeMailUndeliverableST implements Database.Batchable <sObject>{
 
    String QueryString = Null;
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        QueryString = 'SELECT Id, CreatedDate FROM DirectMailUndeliverablesStaging__c ';
        System.debug('QueryString: '+ QueryString);
        return Database.getQueryLocator(QueryString);
    }
    
    global void execute(Database.BatchableContext bc, List<DirectMailUndeliverablesStaging__c> records){
         List<DirectMailUndeliverablesStaging__c> DirectMailUndeliverableStagingList = new List<DirectMailUndeliverablesStaging__c>();
        
        for(DirectMailUndeliverablesStaging__c  DMS: records){
            date createddate = date.valueOf(DMS.CreatedDate);
            date today = date.valueOf(system.now());
            integer datediff = CreatedDate.daysBetween(Today);
                   
                    if(datediff > 21){
                    System.debug('>>>Records Add in IREStagingList');
                    DirectMailUndeliverableStagingList.add(DMS);
                }
            } 
            
        
        System.debug('DirectMailUndeliverableStagingList size: '+ DirectMailUndeliverableStagingList.size());
        
        if(DirectMailUndeliverableStagingList.size()>0){
            List<Database.DeleteResult> results = Database.Delete(DirectMailUndeliverableStagingList, false);
            for (Database.DeleteResult result : results) {
                if (!result.isSuccess()){
                    for (Database.Error err : result.getErrors()){
                        System.debug('Error: '+ err.getStatusCode() + ' ' + err.getMessage());
                    }
                }
            }
        } 
    }
    
    global void finish(Database.BatchableContext bc){
        
    }
}