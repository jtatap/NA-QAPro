/*  Class: BatchCloseResolvedCase
 *  Description : Batch class to update Case with Status = Resoved to Status = Closed as per the No of Days specified
 *  in the Custom label "GeneralCase_ClosedDays" & "PrivacyCase_ClosedDays" for Privacy and Non Privacy cases.
 */
global class BatchCloseResolvedCase implements Database.Batchable <sObject>{
    Integer GenericCaseClosedDays = Integer.valueOf(System.Label.GeneralCase_ClosedDays);
    public transient Map<String,Schema.RecordTypeInfo> RecordTypes = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();
    Id SupportRecordId = RecordTypes.get('Support_Case').getRecordTypeId();
    Id SupportReadOnlyRecordId = RecordTypes.get('Support_Case_Read_Only').getRecordTypeId();
    
    String QueryString = Null;
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        QueryString = 'SELECT Id, Status, Type, RecordTypeId, LastModifiedDate, CreatedDate, ClosedDate FROM Case ' + 
            'WHERE Status = \'Resolved\'';
        Log.push('BatchCloseResolvedCase'); //Adds the message to the stack.
        Log.push(QueryString);
        Logger.logDebug();
        return Database.getQueryLocator(QueryString);
    }
    
    global void execute(Database.BatchableContext bc, List<Case> records){
        if(Test.isRunningTest()){
            GenericCaseClosedDays = 0;
        }
        try{
            List<Case> caseList = new List<Case>();
            for(Case c: records){
                if(c.RecordTypeId == SupportRecordId){
                    if(c.LastModifiedDate.addDays(GenericCaseClosedDays) < System.now()){
                        if(c.RecordTypeId == SupportRecordId){
                            c.Status = 'Closed';
                            c.RecordTypeId = SupportReadOnlyRecordId;
                        }
                        caseList.add(c);
                    }
                }
            }
            Log.push('BatchCloseResolvedCase'); //Adds the message to the stack.
            Log.push('Caselist size: '+caseList.size());
            Logger.logDebug();
            
            if(caseList.size()>0){
                List<Database.SaveResult> results = Database.update(caseList, false);
                for(Integer i=0;i<results.size();i++){
                    if (!results.get(i).isSuccess()){
                        Database.Error error = results.get(i).getErrors().get(0);
                        String failedDML = error.getMessage();
                        caseList.get(i);
                        Logger.logError('BatchCloseResolvedCase Error: ' + caseList.get(i).Id + ' ' + error.getStatusCode() + ' ' + error.getMessage() + failedDML);     
                    }
                }
            } 
        } catch (Exception ex){
            Logger.logException(ex);
        }
    }
    
    global void finish(Database.BatchableContext bc){}
}