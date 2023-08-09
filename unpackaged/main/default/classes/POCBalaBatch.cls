global class POCBalaBatch implements Database.Batchable <sObject>, Database.stateful {
    global List<Contact> finalConList = new List<Contact>();
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator( [SELECT id,Brand_ID__c,IsProcessed__c,Subscriber_Key__c, Email__c 
                                          FROM Contact_Staging__c WHERE FileName__c ='Test1234' LIMIT 20000]); //0032C00000eOODoQAO   (Subscriber_Key__c != null OR Email__c != null)
    }
    global void execute(Database.BatchableContext bc, List<Contact_Staging__c> conStgList) {

//List<Contact_Staging__c> csList = [SELECT Id, Subscriber_Key__c, Email__c FROM Contact_Staging__c WHERE FileName__c ='Test1234'];
        Set<String> subKeys = new Set<String>();
        Set<String> emailIds = new Set<String>();
        for(Contact_Staging__c cs1: conStgList){
            subKeys.add(cs1.Subscriber_Key__c);
            emailIds.add(cs1.Email__c);
        }
        //System.debug('subKeys :'+subKeys.size());
        List<Contact> conList = [SELECT id,Email,Brand_Id__c,Point_Balance__c,Deceased__c,Bulk_Buyer__c,Bulk_Buyer_Update_Date__c, Fraud__c,WelcomeSource__c,Loyalty_Optin_Date__c,LoyaltyFlag__c,LoyaltyID__c,EmailOptInStatus__c, EmailOptInDate__c, EmailOptOutDate__c, Latest_Source__c, AccountId, lastmodifieddate 
                                 FROM contact WHERE (Id IN: subKeys OR Email IN :emailIds) AND Brand_Id__c='2'];
            //[Select id , EmailOptInStatus__c , Loyalty_Optin_Date__c, B2C_Customer_No__c, B2C_CustomerList_ID__c, B2C_CustomerList__c, B2C_Disable_Integration__c, B2C_Instance__c, B2C_Is_Enabled__c, B2C_Integration_Status__c  
                                 //FROM Contact WHERE Id IN:subKeys  limit 1000];
		//System.debug('conList :'+conList.size());
        finalConList.addAll(conList);
        
        }
    global void finish(Database.BatchableContext BC){
        
        string header = 'Sub_Key,Email,Brand_Id__c,Point_Balance__c,Deceased__c,Bulk_Buyer__c,Bulk_Buyer_Update_Date__c, Fraud__c,WelcomeSource__c,Loyalty_Optin_Date__c,LoyaltyFlag__c,LoyaltyID__c,EmailOptInStatus__c, EmailOptInDate__c, EmailOptOutDate__c, Latest_Source__c, AccountId, LastModifiedDate \n';
        string finalstr = header;
        for(Contact c: finalConList){
            string recordString = c.id+','+c.Email+','+c.Brand_Id__c+','+c.Point_Balance__c+','+c.Deceased__c+','+c.Bulk_Buyer__c+','+c.Bulk_Buyer_Update_Date__c+','+c.Fraud__c+','+c.WelcomeSource__c+','+c.Loyalty_Optin_Date__c+','+c.LoyaltyFlag__c+','+c.LoyaltyID__c+','+c.EmailOptInStatus__c+','+c.EmailOptInDate__c+','+c.EmailOptOutDate__c+','+c.Latest_Source__c+','+c.AccountId+','+c.lastmodifieddate+'\n';            
            finalstr = finalstr +recordString;
        }
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        blob csvBlob = Blob.valueOf(finalstr);
        string csvname= 'contact compare data';
        String email1 = 'balagangadharvadlamuri@pvh.com';
        csvAttc.setFileName(csvname);
        csvAttc.setBody(csvBlob);
        
        /*Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        String[] toAddresses = new list<string> {email1};
            String subject ='Contact CSV';
        email.setSubject(subject);
        email.setToAddresses( toAddresses );
        email.setPlainTextBody('Contact CSV ');
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});*/
        
    } 
}