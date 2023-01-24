global class ContactUpdationProcess1 implements Database.Batchable <sObject>, Database.stateful {
global List<Contact> finalConList = new List<Contact>();
    Private String fileName;
    Private Id batchProcessId;
    Private String OutputFileName;
    Private String exceptionMessage;
    Private List<Contact> conListToExportToFile = new List<Contact>();
    
    global ContactUpdationProcess1(){
        List<BatchProcess__c> nextBP = [SELECT Id, IsProcessed__c, FileName__c FROM BatchProcess__c WHERE IsProcessed__c = false LIMIT 1];
        if(nextBP.size() > 0){
            fileName = nextBP[0].FileName__c;
            System.debug('fileName: '+fileName);
            batchProcessId = nextBP[0].Id;
            System.debug('batchProcessId: '+batchProcessId);
            //OutputFileName = nextBP[0].OutputFileName__c;
        }
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        //modify the query to pick the first unporcessed file
        return Database.getQueryLocator( [SELECT Id, B2C_CustomerList_ID__c, B2C_CustomerList__c, B2C_Disable_Integration__c, 
                                          B2C_Integration_Status__c, B2C_Is_Enabled__c, Brand_ID__c, FileName__c, Point_Balance__c, SFSC_Contact_Id__c, 
                                          B2C_Customer_No__c 
                                          FROM ContactStaging2__c WHERE FileName__c =: fileName LIMIT 100]); //0032C00000eOODoQAO   (Subscriber_Key__c != null OR Email__c != null)
    }
    global void execute(Database.BatchableContext bc, List<ContactStaging2__c> conStgList) {

        List<Contact> conListToUpdate = new List<Contact>();
        for(ContactStaging2__c cs2: conStgList ){
            Contact con = new Contact();
            con.Id = cs2.SFSC_Contact_Id__c;
            con.B2C_CustomerList_ID__c = cs2.B2C_CustomerList_ID__c;
            con.B2C_CustomerList__c = cs2.B2C_CustomerList__c;
            con.B2C_Disable_Integration__c = cs2.B2C_Disable_Integration__c;
            con.B2C_Integration_Status__c = cs2.B2C_Integration_Status__c;
            con.B2C_Is_Enabled__c = cs2.B2C_Is_Enabled__c;
            con.Point_Balance__c = cs2.Point_Balance__c;
            con.B2C_Customer_No__c = cs2.B2C_Customer_No__c;
            conListToUpdate.add(con);
            conListToExportToFile.add(con);
        }
        try{
            Update conListToUpdate;
        }
        catch(DmlException e){
            exceptionMessage = e.getMessage();
        }
        
        
        }
    global void finish(Database.BatchableContext BC){
        
        string header = 'Sub_Key,B2C_CustomerList_ID__c,B2C_CustomerList__c,B2C_Disable_Integration__c,B2C_Integration_Status__c,B2C_Is_Enabled__c,Point_Balance__c,B2C_Customer_No__c,exceptionMessage\n';
        string finalstr = header;
        for(Contact c: conListToExportToFile){
            string recordString = c.id+','+c.B2C_CustomerList_ID__c+','+c.B2C_CustomerList__c+','+c.B2C_Disable_Integration__c+','+c.B2C_Integration_Status__c+','+c.B2C_Is_Enabled__c+','+c.Point_Balance__c+','+c.B2C_Customer_No__c+exceptionMessage+'\n';            
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
            List<String> S = fileName.split('\\.');
            ContVerFile.PathOnClient=S[0];
        insert ContVerFile;
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:ContVerFile.Id].ContentDocumentId;
                ContentDocumentLink cDe = new ContentDocumentLink();
                cDe.ContentDocumentId = conDoc;
                cDe.LinkedEntityId = batchProcessId;
                cDe.ShareType = 'I';
                cDe.Visibility = 'AllUsers';
                insert cDe;
        //Updating the current file as processed and starting the process for next file
        
        BatchProcess__c bp = [SELECT Id, IsProcessed__c FROM BatchProcess__c WHERE FileName__c =: fileName LIMIT 1];
        bp.IsProcessed__c = true;
        Update bp;
        
        List<BatchProcess__c> nextBP = [SELECT Id, IsProcessed__c, FileName__c FROM BatchProcess__c WHERE IsProcessed__c = false LIMIT 1];
        if(nextBP.size() > 0){
            ContactUpdationProcess1 cup = new ContactUpdationProcess1();
            Id batchId = database.executeBatch(cup);
            System.debug('batchId : '+batchId);
        }
        
    } 
}