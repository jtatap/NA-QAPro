/* Story No : NASSC-1133 
  * Class: Batch_purgeIREStagingTable
*  Description : Batch class to Delete  IRES_tagingTable__c	Records with CreatedDate > (Today - 21)
*/

global class Batch_purgeIREStagingTable implements  Database.Batchable <sObject>{
 
    String QueryString = Null;
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        NF_Batch_Control__mdt batchMeta = NF_Batch_Control__mdt.getInstance('Batch_purgeIREStagingTable');
        QueryString = batchMeta.Query_String__c;
        Log.push('QueryString: '+ QueryString);
        Logger.logDebug();
        return Database.getQueryLocator(QueryString);
    }
    
    global void execute(Database.BatchableContext bc, List<IRE_StagingTable__c> records){
         List<IRE_StagingTable__c> IREStagingList = new List<IRE_StagingTable__c>();
        
        for(IRE_StagingTable__c  IST: records){
            date createddate = date.valueOf(IST.CreatedDate);
            date today = date.valueOf(system.now());
            integer datediff = CreatedDate.daysBetween(Today);
                   
                    if(datediff > 21){
                    Log.push('>>>Records Add in IREStagingList');
                    IREStagingList.add(IST);
                }
            } 
            
        
        Log.push('IREStagingList size: '+ IREStagingList.size());
        
        if(IREStagingList.size()>0){
            List<Database.DeleteResult> results = Database.Delete(IREStagingList, false);
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