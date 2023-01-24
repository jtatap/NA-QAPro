/* Story No : NASSC-1133 
  * Class: Batch_purgeIREStagingTable
*  Description : Batch class to Delete  IRES_tagingTable__c	Records with CreatedDate > (Today - 21)
*/

global class Batch_purgeIREStagingTable implements  Database.Batchable <sObject>{
 
    String QueryString = Null;
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        QueryString = 'SELECT Id, CreatedDate FROM IRE_StagingTable__c ';
        System.debug('QueryString: '+ QueryString);
        return Database.getQueryLocator(QueryString);
    }
    
    global void execute(Database.BatchableContext bc, List<IRE_StagingTable__c> records){
         List<IRE_StagingTable__c> IREStagingList = new List<IRE_StagingTable__c>();
        
        for(IRE_StagingTable__c  IST: records){
            date createddate = date.valueOf(IST.CreatedDate);
            date today = date.valueOf(system.now());
            integer datediff = CreatedDate.daysBetween(Today);
                   
                    if(datediff > 21){
                    System.debug('>>>Records Add in IREStagingList');
                    IREStagingList.add(IST);
                }
            } 
            
        
        System.debug('IREStagingList size: '+ IREStagingList.size());
        
        if(IREStagingList.size()>0){
            List<Database.DeleteResult> results = Database.Delete(IREStagingList, false);
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