/* Story No : NASSC-1135
 *  Class: Batch_purgeMailUndeliverableST
 *  Description : Batch class to Delete  DirectMailUndeliverableStaging__c	Records with CreatedDate > (Today - 21)
 */

global class Batch_purgeMailUndeliverableST implements Database.Batchable <sObject>{
 
    String QueryString = Null;
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        NF_Batch_Control__mdt batchMeta = NF_Batch_Control__mdt.getInstance('Batch_purgeMailUndeliverableST');
        QueryString = batchMeta.Query_String__c;
        Log.push('QueryString: '+ QueryString);
        Logger.logDebug();
        return Database.getQueryLocator(QueryString);
    }
    
    global void execute(Database.BatchableContext bc, List<DirectMailUndeliverablesStaging__c> records){
         List<DirectMailUndeliverablesStaging__c> DirectMailUndeliverableStagingList = new List<DirectMailUndeliverablesStaging__c>();
        
        for(DirectMailUndeliverablesStaging__c  DMS: records){
            date createddate = date.valueOf(DMS.CreatedDate);
            date today = date.valueOf(system.now());
            integer datediff = CreatedDate.daysBetween(Today);
                   
                    if(datediff > 21){
                    Log.push('>>>Records Add in IREStagingList');
                    DirectMailUndeliverableStagingList.add(DMS);
                }
            } 
            
        
        Log.push('DirectMailUndeliverableStagingList size: '+ DirectMailUndeliverableStagingList.size());
        
        if(DirectMailUndeliverableStagingList.size()>0){
            List<Database.DeleteResult> results = Database.Delete(DirectMailUndeliverableStagingList, false);
            for (Database.DeleteResult result : results) {
                if (!result.isSuccess()){
                    for (Database.Error err : result.getErrors()){
                        Log.push('Error: '+ err.getStatusCode() + ' ' + err.getMessage());
                    }
                }
            }
        }
        Logger.logDebug(); 
    }
    
    global void finish(Database.BatchableContext bc){
        
    }
}