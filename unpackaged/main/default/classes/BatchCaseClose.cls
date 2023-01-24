/*  Class: BatchCaseClose
*  Description : Batch class to update Case with Status = Closed as per the No of Days specified
*(After 24 hours of violation of milestone case gets closed automatically)
*/

global class BatchCaseClose implements Database.Batchable <sObject>{
    
    
    Id SupportRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support_Case').getRecordTypeId();
    Id SupportReadOnlyRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support_Case_Read_Only').getRecordTypeId();
    String QueryString = Null;
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        
        
        QueryString = 'SELECT Id, Status, Type, RecordTypeId, LastModifiedDate, CreatedDate, ClosedDate  FROM Case ' + 
            'WHERE  ParentId != Null And Is_Milestone_Violated__c = True';
        System.debug('QueryString: '+ QueryString);
        return Database.getQueryLocator(QueryString);
    }
    
    global void execute(Database.BatchableContext bc, List<Case> records){
        List<Case> caseList = new List<Case>();
        
        for(Case c: records){
            date createddate = date.valueOf(c.CreatedDate);
            date today = date.valueOf(system.now());
            integer datediff = CreatedDate.daysBetween(Today);
            
            if((c.Type == 'Support') && (c.Is_Milestone_Violated__c = True)){
                System.debug('>>>Support Record Check');
                
                
                if(datediff > 4){
                    System.debug('>>>Support child case Record Closed');
                    c.Status = 'Closed';
                    c.RecordTypeId = SupportReadOnlyRecordId;
                    caseList.add(c);
                }
            } 
            
        }
        System.debug('Caselist size: '+caseList.size());
        
        if(caseList.size()>0){
            List<Database.SaveResult> results = Database.update(caseList, false);
            for (Database.SaveResult result : results) {
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