// Author: Bala Vadlamuri
// The purpose of this call is to do the additional things while doing the data extraction job. 
// Like deleting all the existing records, check the contact for SubKey missing (Email + Brand) and chekcing the contact updation
public class ContactDataExtractionUtil {
    
    //String ids = '0032C00000eOO1EQAW','0032C00000eOO1JQAW','0032C00000eOO1YQAW','0032C00000eOO1sQAG','0032C00000eOO1UQAW','0032C00000eOO2lQAG','0032C00000eOO2qQAG','0032C00000eOO35QAG','0032C00000eOO3UQAW','0032C00000eOO3ZQAW','0032C00000eOO3oQAG','0032C00000eOO3yQAG','0032C00000eOO43QAG','0032C00000eOO48QAG','0032C00000eOO3QQAW','0032C00000eOO4mQAG','0032C00000eOO1xQAG','0032C00000eOO2WQAW','0032C00000eOO2bQAG','0032C00000eOO4wQAG','0032C00000eOO5BQAW','0032C00000eOO5aQAG','0032C00000eOO5kQAG','0032C00000eOO5pQAG','0032C00000eOO69QAG','0032C00000eOO6YQAW','0032C00000eOO6dQAG','0032C00000eOO6xQAG','0032C00000eOO7MQAW','0032C00000eOO7WQAW','0032C00000eOO8AQAW','0032C00000eOO8UQAW','0032C00000eOO86QAG','0032C00000eOO8oQAG','0032C00000eOO93QAG','0032C00000eOO9XQAW','0032C00000eOO9hQAG','0032C00000eOOA1QAO','0032C00000eOOAQQA4','0032C00000eOOAaQAO','0032C00000eOOBEQA4','0032C00000eOOBYQA4','0032C00000eOOC7QAO','0032C00000eOOCMQA4','0032C00000eOOClQAO','0032C00000eOO7bQAG','0032C00000eOODAQA4','0032C00000eOODPQA4','0032C00000eOODjQAO','0032C00000eOODoQAO','0032C00000eOOEDQA4','0032C00000eOOEIQA4','0032C00000eOOEXQA4','0032C00000eOOEcQAO','0032C00000eOOErQAO','0032C00000eOOFGQA4','0032C00000eOOFQQA4','0032C00000eOOFaQAO','0032C00000eOOFgQAO','0032C00000eOOG4QAO','0032C00000eOOG9QAO','0032C00000eOOH2QAO','0032C00000eOOHMQA4','0032C00000eOOHWQA4','0032C00000eOOIFQA4','0032C00000eOOIjQAO','0032C00000eOOIoQAO','0032C00000eOOJSQA4','0032C00000eOOJhQAO','0032C00000eOOPzQAO','0032C00000eOORWQA4','0032C00000eOOTIQA4','0032C00000eOOTwQAO','0032C00000eOOUQQA4','0032C00000eOOVJQA4','0032C00000eOOVOQA4','0032C00000eOOVYQA4','0032C00000eOOVxQAO','0032C00000eOOWCQA4','0032C00000eOOWgQAO','0032C00000eOOX5QAO','0032C00000eOOXKQA4','0032C00000eOOXUQA4','0032C00000eOOIGQA4','0032C00000eOOYXQA4','0032C00000eOOYhQAO','0032C00000eOOZ6QAO','0032C00000eOOZGQA4','0032C00000eOP44QAG','0032C00000eOP4YQAW','0032C00000eOP4sQAG','0032C00000eOP52QAG','0032C00000eOP5HQAW','0032C00000eOP5bQAG','0032C00000eOQyoQAG','0032C00000eORfGQAW','0032C00000eORsyQAG','0032C00000eORtNQAW','0032C00000eORtXQAW','0032C00000eP65RQAS','0032C00000ePBN3QAO','0032C00000ePCysQAG','0032C00000eGBtmQAG','0032C00000ePDOqQAO','0032C00000eQRmkQAG','0032C00000eQVPpQAO','0032C00000eNUCdQAO','0032C00000eeEofQAE','0032C00000eePLhQAM','0032C00000delQjQAI','0032C00000delRIQAY','0032C00000drdveQAA','0032C00000dreAeQAI','0032C00000drzpyQAA','0032C00000e66aRQAQ','0032C00000e66b5QAA','0032C00000e7esEQAQ','0032C00000e90axQAA','0032C00000e9NQgQAM','0032C00000e9Q7JQAU','0032C00000e9Q9TQAU','0032C00000eFjtJQAS','0032C00000eFju2QAC','0032C00000eFjuHQAS','0032C00000eFjuMQAS','0032C00000eFjubQAC','0032C00000eFjuqQAC','0032C00000eFjuvQAC','0032C00000eFxTNQA0','0032C00000eGP7QQAW','0032C00000eGPDTQA4','0032C00000eGPFAQA4','0032C00000eGPHkQAO','0032C00000eGPJrQAO','0032C00000eGd6PQAS','0032C00000eHPk3QAG','0032C00000eHQ8yQAG','0032C00000eHQIoQAO','0032C00000eIadlQAC','0032C00000eIbAXQA0','0032C00000eN8RIQA0','0032C00000eNTkyQAG','0032C00000eNToWQAW','0032C00000eNTpKQAW','0032C00000eNgRwQAK','0032C00000eNn0uQAC','0032C00000eOF4sQAG','0032C00000eGPIJQA4','0032C00000eOF57QAG','0032C00000eOF5RQAW','0032C00000eOF5qQAG','0032C00000eOF60QAG','0032C00000eONbdQAG','0032C00000eONZOQA4','0032C00000eONd5QAG','0032C00000eONhlQAG','0032C00000eONeuQAG','0032C00000eONknQAG','0032C00000eONlBQAW','0032C00000eONmKQAW','0032C00000eONn2QAG','0032C00000eONo0QAG','0032C00000eONo5QAG','0032C00000eONoUQAW','0032C00000eONojQAG','0032C00000eONp3QAG','0032C00000eONpwQAG','0032C00000eONpdQAG','0032C00000eONq6QAG','0032C00000eONqQQAW','0032C00000eONqkQAG','0032C00000eONsvQAG','0032C00000eONtFQAW','0032C00000eONttQAG','0032C00000eONv6QAG','0032C00000eONvzQAG','0032C00000eONwEQAW','0032C00000eONx2QAG','0032C00000eONwoQAG','0032C00000eONyKQAW','0032C00000eONzmQAG','0032C00000eOO01QAG','0032C00000eOO0BQAW','0032C00000eOO0LQAW','0032C00000eOO0zQAG','0032C00000VKNPjQAP','0032C00000VKNNTQA5','0032C00000VLUYKQA5','0032C00000W4ZfXQAV','0032C00000W4ZfmQAF','0032C00000W4a8uQAB','0032C00000W4a99QAB','0032C00000W4aLHQAZ','0032C00000Vbta0QAB','0032C00000WKodEQAT','0032C00000WKog3QAD','0032C00000WKomVQAT','0032C00000WKomaQAD','0032C00000WKoqRQAT','0032C00000WKoqlQAD','0032C00000WKoqvQAD','0032C00000WKorUQAT','0032C00000WKos8QAD','0032C00000WKot1QAD','0032C00000WMvfqQAD','0032C00000XpjecQAB','0032C00000YE3b5QAD','0032C00000YE4MzQAL','0032C00000WJx2YQAT','0032C00000YE519QAD','0032C00000YFhwXQAT','0032C00000YFxenQAD','0032C00000Z6IQXQA3','0032C00000Y2tETQAZ','0032C00000Z77Q9QAJ','0032C00000Z78AdQAJ','0032C00000Z7A3sQAF','0032C00000Z7ANtQAN','0032C00000Z8DHUQA3','0032C00000Z8TBPQA3','0032C00000Z8TCIQA3','0032C00000Z8TChQAN','0032C00000Z8TmgQAF','0032C00000Z8TjJQAV','0032C00000ZkFp6QAF','0032C00000ZkUhqQAF','0032C00000a3o2oQAA','0032C00000a3pGYQAY','0032C00000a5XiLQAU','0032C00000a5XikQAE','0032C00000a5ctGQAQ','0032C00000aORlGQAW','0032C00000aZwy9QAC','0032C00000acaNIQAY','0032C00000acad1QAA','0032C00000aqsxGQAQ','0032C00000argP4QAI','0032C00000asqgHQAQ','0032C00000b8EFVQA2','0032C00000bp79gQAA','0032C00000bs5bpQAA','0032C00000dIPfXQAW','0032C00000dIPtKQAW','0032C00000dImK3QAK','0032C00000dIsSOQA0','0032C00000ddpEOQAY','0032C00000ddq3iQAA','0032C00000ddq4vQAA','0032C00000ddq6XQAQ','0032C00000ddzW0QAI','0032C00000ddzbcQAA','0032C00000deBpGQAU','0032C00000deGYlQAM','0032C00000deGZPQA2','0032C00000deGZ0QAM','0032C00000dedX8QAI','0032C00000dedaHQAQ','0032C00000dedd6QAA','0032C00000dedgeQAA','0032C00000dejmZQAQ','0032C00000delNQQAY','0032C00000delPgQAI','0032C00000VvNKjQAN';
    
    public void getDuplicateEmailRec(String fileName){
        //This method helps us to get the Contact Id for the missing SubKey
        //String fileName = 'loyalty_GDC-9618.xml';
        List<Contact_Staging__c> csList = [SELECT Id, Email__c 
                                           FROM Contact_Staging__c 
                                           WHERE FileName__c =:fileName  AND IsProcessed__c = false];
        Set<String> emailIds = new Set<String>();
        for(Contact_Staging__c cs1: csList){
            emailIds.add(cs1.Email__c);
        }
        List<Contact> conList = new List<Contact>();
        for(Contact c1: [SELECT Id, Email, Brand__c FROM Contact WHERE Email IN: emailIds]){
            System.debug('c1 Email '+c1.Email);
            System.debug('c1 Id '+c1.Id);
            System.debug('c1 Brand__c '+c1.Brand__c);
            conList.add(c1);
        }
        System.debug('conList size : '+conList.size());
    }
    
    public void generateCSV(String fileName, String email1){
        //This method is used to get the contact as csv post updation process
        List<Contact_Staging__c> csList = [SELECT Id, Subscriber_Key__c, Email__c, SFSC_Contact_Id__c
                                           FROM Contact_Staging__c 
                                           WHERE FileName__c =:fileName];
        Set<String> subKeys = new Set<String>();
        Set<String> emailIds = new Set<String>();
        for(Contact_Staging__c cs1: csList){
            subKeys.add(cs1.SFSC_Contact_Id__c);
            //emailIds.add(cs1.Email__c);
        }
        System.debug('subKeys :'+subKeys.size());
        List<Contact> conList = [SELECT id,Email,Brand_Id__c,Point_Balance__c,Deceased__c,Bulk_Buyer__c,Bulk_Buyer_Update_Date__c, Fraud__c,WelcomeSource__c,Loyalty_Optin_Date__c,LoyaltyFlag__c,LoyaltyID__c,EmailOptInStatus__c, EmailOptInDate__c, EmailOptOutDate__c, Latest_Source__c, AccountId, lastmodifieddate 
                                 FROM contact WHERE Id IN: subKeys AND Brand_Id__c='2']; //OR Email IN :emailIds
            //[Select id , EmailOptInStatus__c , Loyalty_Optin_Date__c, B2C_Customer_No__c, B2C_CustomerList_ID__c, B2C_CustomerList__c, B2C_Disable_Integration__c, B2C_Instance__c, B2C_Is_Enabled__c, B2C_Integration_Status__c  
                                 //FROM Contact WHERE Id IN:subKeys  limit 1000];
		System.debug('conList :'+conList.size());
        string header = 'Sub_Key,Email,Brand_Id__c,Point_Balance__c,Deceased__c,Bulk_Buyer__c,Bulk_Buyer_Update_Date__c, Fraud__c,WelcomeSource__c,Loyalty_Optin_Date__c,LoyaltyFlag__c,LoyaltyID__c,EmailOptInStatus__c, EmailOptInDate__c, EmailOptOutDate__c, Latest_Source__c, AccountId, LastModifiedDate \n';
        string finalstr = header;
        for(Contact c: conList){
            string recordString = c.id+','+c.Email+','+c.Brand_Id__c+','+c.Point_Balance__c+','+c.Deceased__c+','+c.Bulk_Buyer__c+','+c.Bulk_Buyer_Update_Date__c+','+c.Fraud__c+','+c.WelcomeSource__c+','+c.Loyalty_Optin_Date__c+','+c.LoyaltyFlag__c+','+c.LoyaltyID__c+','+c.EmailOptInStatus__c+','+c.EmailOptInDate__c+','+c.EmailOptOutDate__c+','+c.Latest_Source__c+','+c.AccountId+','+c.lastmodifieddate+'\n';            
            finalstr = finalstr +recordString;
        }
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        blob csvBlob = Blob.valueOf(finalstr);
        string csvname= fileName+'.csv';
        csvAttc.setFileName(csvname);
        csvAttc.setBody(csvBlob);
        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        String[] toAddresses = new list<string> {email1};
            String subject ='Contact CSV';
        email.setSubject(subject);
        email.setToAddresses( toAddresses );
        email.setPlainTextBody('Contact CSV ');
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        
        /*
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
         */
          
    }

    Public void deleteContactStagingRecords(String fileName){
        //This method is used to delete the contact staging records as per the file name
        List<Contact_Staging__c> csList = [SELECT Id, Subscriber_Key__c 
                                           FROM Contact_Staging__c 
                                           WHERE FileName__c =:fileName];
        Delete csList;
    }   
    
    //select id,Brand_ID__c,IsProcessed__c,Subscriber_Key__c, Email__c, Email_Optin_Status__c from Contact_Staging__c where IsProcessed__c=true AND Subscriber_Key__c IN ('0032C00000bSH6wQAG','0032C00000bSG4zQAG','0032C00000bSFLQQA4','0032C00000bmBAOQA2','0032C00000bmN2DQAU','0032C00000bm9qDQAQ','0032C00000eOhLPQA0','0032C00000eOhMsQAK','0032C00000eOhTiQAK','0032C00000eOhURQA0','0032C00000eOhZvQAK','0032C00000eOhcBQAS','0032C00000eOhf5QAC','0032C00000eOhgwQAC','0032C00000eOhhaQAC','0032C00000eOhmfQAC','0032C00000eOhuvQAC','0032C00000e8jUKQAY','0032C00000eGHwpQAG','0032C00000eOXsQQAW','0032C00000eOcwSQAS','0032C00000eOi7gQAC','0032C00000eOiHbQAK','0032C00000eOiIZQA0','0032C00000eOidZQAS','0032C00000eOim2QAC','0032C00000eOimMQAS','0032C00000eOisPQAS','0032C00000eOjOaQAK','0032C00000eOjT6QAK','0032C00000eOjXIQA0','0032C00000eOiEnQAK','0032C00000eOjgUQAS','0032C00000eOjowQAC','0032C00000eOjpQQAS','0032C00000eOjsGQAS','0032C00000eOk2fQAC','0032C00000eOk3nQAC','0032C00000eOk3sQAC','0032C00000eOk5oQAC','0032C00000eOkElQAK','0032C00000eOkGIQA0','0032C00000eOkO7QAK','0032C00000e7ycaQAA','0032C00000eOY2kQAG','0032C00000eOj5xQAC','0032C00000eOkUtQAK','0032C00000eOkXjQAK','0032C00000eOkh1QAC','0032C00000eOklcQAC','0032C00000eOklwQAC','0032C00000eOkqrQAC','0032C00000eOls8QAC','0032C00000eOmwbQAC','0032C00000eOnwnQAC','0032C00000eOnqzQAC','0032C00000eOYRzQAO','0032C00000eOYfSQAW','0032C00000eOYsbQAG','0032C00000eOa9BQAS','0032C00000eOaj5QAC','0032C00000eOakmQAC','0032C00000eOb5fQAC','0032C00000eObSKQA0','0032C00000eOtLoQAK','0032C00000eOZtQQAW','0032C00000eOe12QAC','0032C00000eOfqNQAS','0032C00000eOmlnQAC','0032C00000arVlyQAE','0032C00000ar8puQAA','0032C00000ar8qpQAA','0032C00000asxQfQAI','0032C00000atARpQAM','0032C00000atEgKQAU','0032C00000asxoiQAA','0032C00000a3v4cQA')
}