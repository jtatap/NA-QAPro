global class ContactExtractionProcess implements Database.Batchable <sObject>, Database.stateful {
    global List<Contact> finalConList = new List<Contact>();
    Private String fileName;
    Private Id batchProcessId;
    
    global ContactExtractionProcess(){
        List<BatchProcess__c> nextBP = [SELECT Id, IsProcessed__c, FileName__c FROM BatchProcess__c WHERE IsProcessed__c = false LIMIT 1];
        if(nextBP.size() > 0){
            fileName = nextBP[0].FileName__c;
        	System.debug('fileName: '+fileName);
            batchProcessId = nextBP[0].Id;
            System.debug('batchProcessId: '+batchProcessId);
        }
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        //modify the query to pick the first unporcessed file
        return Database.getQueryLocator( [SELECT id,Brand__c, Email__c 
                                          FROM ContactStaging2__c WHERE FileName__c =: fileName LIMIT 10000]); //0032C00000eOODoQAO   (Subscriber_Key__c != null OR Email__c != null)
    }
    global void execute(Database.BatchableContext bc, List<ContactStaging2__c> conStgList) {

        Set<String> emailIds = new Set<String>();
        for(ContactStaging2__c cs1: conStgList){
            emailIds.add(cs1.Email__c);
        }//For TH please include SMS related fields in the below query
        List<Contact> conList = [SELECT id,Email,Brand_Id__c,Point_Balance__c,Deceased__c,Bulk_Buyer__c,Bulk_Buyer_Update_Date__c, Fraud__c,WelcomeSource__c,Loyalty_Optin_Date__c,LoyaltyFlag__c,LoyaltyID__c,EmailOptInStatus__c, EmailOptInDate__c, EmailOptOutDate__c, Latest_Source__c, AccountId, lastmodifieddate, SMSNumber__c, SMSOptinStatus__c, SMSOptOutDate__c, SMSOptInDate__c, PrefCenterInterests__c, HomeStore__c,StoreOfCapture__c,FirstName,LastName
                                 FROM contact WHERE Email IN :emailIds AND Brand_Id__c IN('1','2')];
        finalConList.addAll(conList);
        
        }
    global void finish(Database.BatchableContext BC){
        //For TH please include SMS related fields in the below header and line no 36 for values
        string header = 'Sub_Key,Email,Brand_Id__c,Point_Balance__c,Deceased__c,Bulk_Buyer__c,Bulk_Buyer_Update_Date__c,Fraud__c,WelcomeSource__c,Loyalty_Optin_Date__c,LoyaltyFlag__c,LoyaltyID__c,EmailOptInStatus__c,EmailOptInDate__c,EmailOptOutDate__c,Latest_Source__c,AccountId,LastModifiedDate,SMSNumber__c,SMSOptinStatus__c,SMSOptOutDate__c,SMSOptInDate__c,PrefCenterInterests__c,HomeStore__c,StoreOfCapture__c,FirstName,LastName\n';
        string finalstr = header;
        for(Contact c: finalConList){
            string recordString = c.id+','+c.Email+','+c.Brand_Id__c+','+c.Point_Balance__c+','+c.Deceased__c+','+c.Bulk_Buyer__c+','+c.Bulk_Buyer_Update_Date__c+','+c.Fraud__c+','+c.WelcomeSource__c+','+c.Loyalty_Optin_Date__c+','+c.LoyaltyFlag__c+','+c.LoyaltyID__c+','+c.EmailOptInStatus__c+','+c.EmailOptInDate__c+','+c.EmailOptOutDate__c+','+c.Latest_Source__c+','+c.AccountId+','+c.lastmodifieddate+ ',' + c.SMSNumber__c +  ',' + c.SMSOptinStatus__c + ',' + c.SMSOptOutDate__c + ',' + c.SMSOptInDate__c + ',' + c.PrefCenterInterests__c + ',' + c.HomeStore__c + ',' + c.StoreOfCapture__c + ',' + c.FirstName + ',' + c.LastName + '\n';            
            finalstr = finalstr +recordString;
        }
        /*Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        blob csvBlob = Blob.valueOf(finalstr);
        string csvname= fileName+'.csv';
        String email1 = 'balav@stabilistech.com';
        csvAttc.setFileName(csvname);
        csvAttc.setBody(csvBlob);
        
        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        String[] toAddresses = new list<string> {email1};
            String subject ='Contact CSV';
        email.setSubject(subject);SELECT CustomerNumber__c, Id, Subscriber_Key__c, Loyalty_ID__c, Loyalty_Flag__c, Email_Optin_Status__c, Welcome_source__c, Brand_ID__c, Email__c, Latest_Source__c, IsProcessed__c, SFSC_Contact_Id__c, Point_Balance__c, Loyalty_Optin_Date__c, Bulk_Buyer__c, Deceased__c, Fraud__c, SFSCAccountId__c, b2ccrm_syncStatus__c, isLoyaltyVerified__c  FROM Contact_Staging__c where FileName__c = 'loyalty-2022-08-11-001.xml' AND IsProcessed__c = true
        email.setToAddresses( toAddresses );
        email.setPlainTextBody('Contact CSV ');
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        */
        ContentVersion ContVerFile = new ContentVersion();
            ContVerFile.VersionData = Blob.valueOf(finalstr);
            ContVerFile.Title = fileName; 
            ContVerFile.ContentLocation= 's';
            ContVerFile.PathOnClient=fileName+'.csv';
      	insert ContVerFile;
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:ContVerFile.Id].ContentDocumentId;
                ContentDocumentLink cDe = new ContentDocumentLink();
                cDe.ContentDocumentId = conDoc;
                cDe.LinkedEntityId = batchProcessId;
                cDe.ShareType = 'I';
                cDe.Visibility = 'AllUsers';
                insert cDe;
        //Updating the current file as processed and starting the process for next file
        
        BatchProcess__c bp = [SELECT Id, IsProcessed__c,Output_File_Name__c FROM BatchProcess__c WHERE FileName__c =: fileName LIMIT 1];
        bp.IsProcessed__c = true;
        Update bp;
        
        List<BatchProcess__c> nextBP = [SELECT Id, IsProcessed__c, FileName__c FROM BatchProcess__c WHERE IsProcessed__c = false LIMIT 1];
        if(nextBP.size() > 0){
            ContactExtractionProcess cep = new ContactExtractionProcess();
        	Id batchId = database.executeBatch(cep);
        	System.debug('Batch Id: '+batchId);
        }
        
    } 
}