/*  Class: BatchCaseClose
*  Description : Batch class to update Case with Status = Closed as per the No of Days specified
*(After 24 hours of violation of milestone case gets closed automatically)
*/

global class BatchCaseClose implements Database.Batchable <sObject>{
    
    
    Id SupportRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support_Case').getRecordTypeId();
    Id SupportReadOnlyRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support_Case_Read_Only').getRecordTypeId();
    String QueryString = Null;
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        
        
        NF_Batch_Control__mdt batchMeta = NF_Batch_Control__mdt.getInstance('BatchCaseClose');
        QueryString = batchMeta.Query_String__c;
        Log.push('QueryString: '+ QueryString);
        Logger.logDebug();
        return Database.getQueryLocator(QueryString);
    }
    
    global void execute(Database.BatchableContext bc, List<Case> records){
        List<Case> caseList = new List<Case>();
        
        for(Case c: records){
            date createddate = date.valueOf(c.CreatedDate);
            date today = date.valueOf(system.now());
            integer datediff = CreatedDate.daysBetween(Today);
            
            if((c.Type == 'Support') && (c.Is_Milestone_Violated__c = True)){
                Log.push('>>>Support Record Check');
                
                
                if(datediff > 4){
                    Log.push('>>>Support child case Record Closed');
                    c.Status = 'Closed';
                    c.RecordTypeId = SupportReadOnlyRecordId;
                    caseList.add(c);
                }
            } 
            
        }
        Log.push('Caselist size: '+caseList.size());
        
        if(caseList.size()>0){
            List<Database.SaveResult> results = Database.update(caseList, false);
            for (Database.SaveResult result : results) {
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