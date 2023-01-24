global class CSREmailUpdate implements database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
       String pvhGuestUserId = '0051U000006XWVd';
       //String query = 'select Id from Case where Id =\''+ CaseId + '\' limit 1';
       //String query = 'select Id from Case where CSRMailUpdateonContact__c =true and LastModifiedById =\''+pvhGuestUserId+'\'';
       String query = 'select Id from Case where CSRMailUpdateonContact__c =true';
        System.debug('Query Running in Batch Apex'+ query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Case> records) {
        //User thisUser = [SELECT Id FROM User WHERE Id = :'0051U000006Y2PVQA0'];
        Map<String, Id> params = new Map<String, Id>();
        params.put('CaseId',records[0].Id);
        Flow.Interview.CSR_Update_Email_in_Contact flow1 = new Flow.Interview.CSR_Update_Email_in_Contact(params);
        flow1.start();                     
    }

	global void finish(Database.BatchableContext BC){}
}