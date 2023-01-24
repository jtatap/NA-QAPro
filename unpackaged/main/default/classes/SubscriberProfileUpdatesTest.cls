/******************************************************************************
* @Description: Test class for SubscriberProfileUpdates
* @Date       : April 15, 2020
* @JIRA       : NASSC-1671
*
******************************************************************************/

@isTest
private class SubscriberProfileUpdatesTest {

    @testSetup
    static void dataSetup() {
        Account accOne = new Account(Name = 'Testing', Gender__c='M');
        insert accOne;
        
        Contact conOne = new Contact(LastName='TestConOne', AccountId=accOne.Id);
        insert conOne;
        
        Contact conTwo = new Contact(LastName='TestConTwo', AccountId=accOne.Id, SMSNumber__c='16667778888');
        insert conTwo;
        
    }
    
    @isTest
    static void doSignUpTest_BlankContactId() {
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/subscriber/profile';
        req.httpMethod = 'POST';
        String reqBody = '{"ContactId":" ","Name":{"FirstName":"Eric","LastName":"Cranmer"},"MailingAddress":{"Street":"123 Main St","City":"My city","State":"TX","Country":"US","PostalCode":"01234-6787"},"BirthDate":"2001-11-29","Phone":"18887778888","SMS":{"SMSNumber ":"16667778888","SMSOptinStatus":"P","SMSOptinDate":"2020-04-02T10:55:30-04:00"},"PrefCenterInterests":"M;O","HomeStore":"TO33","Gender":"M"}';
        req.requestBody = Blob.valueof(reqBody);
        RestContext.request = req;
        RestContext.response= res;
        SubscriberProfileUpdates.PCUpdateResponse subResponse = new SubscriberProfileUpdates.PCUpdateResponse();
        subResponse = SubscriberProfileUpdates.doSignUp();
        System.debug('***Response 1 = '+subResponse);
    }
    
    @isTest
    static void doSignUpTest_ContactNotFound() {
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/subscriber/profile';
        req.httpMethod = 'POST';
        String reqBody = '{"ContactId":"0032100000t6xxxAAE","Name":{"FirstName":"Eric","LastName":"Cranmer"},"MailingAddress":{"Street":"123 Main St","City":"My city","State":"TX","Country":"US","PostalCode":"01234-6787"},"BirthDate":"2001-11-29","Phone":"18887778888","SMS":{"SMSNumber ":"16667778888","SMSOptinStatus":"P","SMSOptinDate":"2020-04-02T10:55:30-04:00"},"PrefCenterInterests":"M;O","HomeStore":"TO33","Gender":"M"}';
        req.requestBody = Blob.valueof(reqBody);
        RestContext.request = req;
        RestContext.response= res;
        SubscriberProfileUpdates.PCUpdateResponse subResponse = new SubscriberProfileUpdates.PCUpdateResponse();
        subResponse = SubscriberProfileUpdates.doSignUp();
        Test.stopTest(); 
        System.debug('***Response 2 = '+subResponse);
    }
    
    @isTest
    static void doSignUpTest_AnotherContactExist() {
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/subscriber/profile';
        req.httpMethod = 'POST';
        SubscriberProfileUpdates.PCUpdateRequest subRequest = new SubscriberProfileUpdates.PCUpdateRequest();
        SubscriberProfileUpdates.SMS smsReq = new SubscriberProfileUpdates.SMS();
        Contact getConOne = [Select Id,SMSNumber__c from Contact Where LastName='TestConOne'];
        Contact getContwo = [Select Id,SMSNumber__c from Contact Where LastName='TestConTwo'];
        subRequest.ContactId = getConOne.Id;
        smsReq.SMSNumber = getContwo.SMSNumber__c;
        smsReq.Locale = 'en_US';
        subRequest.SMS = smsReq;
        System.debug('******Request = '+subRequest);
        String reqString = JSON.serialize(subRequest);
        req.requestBody = Blob.valueof(reqString);
        RestContext.request = req;
        RestContext.response= res;
        SubscriberProfileUpdates.PCUpdateResponse subResponse = new SubscriberProfileUpdates.PCUpdateResponse();
        
        //subResponse = SubscriberProfileUpdates.doSignUp();
       
        System.debug('***Response 3 = '+subResponse);
       
    }
    
    @isTest
    static void doSignUpTest_ContactUpdate() {
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/subscriber/profile';
        req.httpMethod = 'POST';
        SubscriberProfileUpdates.PCUpdateRequest subRequest = new SubscriberProfileUpdates.PCUpdateRequest();
        SubscriberProfileUpdates.Name nameObj = new SubscriberProfileUpdates.Name();
        SubscriberProfileUpdates.MailingAddress maObj = new SubscriberProfileUpdates.MailingAddress();
        SubscriberProfileUpdates.SMS smsObj = new SubscriberProfileUpdates.SMS();
        
        Contact getConOne = [Select Id,SMSNumber__c from Contact Where LastName='TestConOne'];
        Contact getContwo = [Select Id,SMSNumber__c from Contact Where LastName='TestConTwo'];
        subRequest.ContactId = getConOne.Id;
        subRequest.Name = nameObj;
        subRequest.MailingAddress = maObj;
        smsObj.Locale = 'en_US';
        subRequest.SMS = smsObj;
        System.debug('******Request 4 = '+subRequest);
        String reqString = JSON.serialize(subRequest);
        req.requestBody = Blob.valueof(reqString);
        RestContext.request = req;
        RestContext.response= res;
        SubscriberProfileUpdates.PCUpdateResponse subResponse = new SubscriberProfileUpdates.PCUpdateResponse();
        subResponse = SubscriberProfileUpdates.doSignUp();
        System.debug('***Response 4 = '+subResponse);
       
    }
    @isTest
    static void doSignUpTest_ContactUpdate1() {
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/subscriber/profile';
        req.httpMethod = 'POST';
        SubscriberProfileUpdates.PCUpdateRequest subRequest = new SubscriberProfileUpdates.PCUpdateRequest();
        SubscriberProfileUpdates.Name nameObj = new SubscriberProfileUpdates.Name();
        SubscriberProfileUpdates.MailingAddress maObj = new SubscriberProfileUpdates.MailingAddress();
        SubscriberProfileUpdates.SMS smsObj = new SubscriberProfileUpdates.SMS();
        
        Contact getConOne = [Select Id,SMSNumber__c from Contact Where LastName='TestConOne'];
        Contact getContwo = [Select Id,SMSNumber__c from Contact Where LastName='TestConTwo'];
        
        subRequest.ContactId = getConOne.Id;
        subRequest.Name = nameObj;
        subRequest.MailingAddress = maObj;
        smsObj.Locale = 'en_US';
        smsObj.SMSNumber='1234567892';
        subRequest.SMS = smsObj;
        System.debug('******Request 4 = '+subRequest);
        String reqString = JSON.serialize(subRequest);
        req.requestBody = Blob.valueof(reqString);
        RestContext.request = req;
        RestContext.response= res;
        SubscriberProfileUpdates.PCUpdateResponse subResponse = new SubscriberProfileUpdates.PCUpdateResponse();
        subResponse = SubscriberProfileUpdates.doSignUp();
        System.debug('***Response 4 = '+subResponse);
       
    }
    @isTest
    static void doSignUpTest_ContactUpdateException() {
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/subscriber/profile';
        req.httpMethod = 'POST';
        SubscriberProfileUpdates.PCUpdateRequest subRequest = new SubscriberProfileUpdates.PCUpdateRequest();
        SubscriberProfileUpdates.Name nameObj = new SubscriberProfileUpdates.Name();
        SubscriberProfileUpdates.MailingAddress maObj = new SubscriberProfileUpdates.MailingAddress();
        SubscriberProfileUpdates.SMS smsObj = new SubscriberProfileUpdates.SMS();
        
        Contact getConOne = [Select Id,SMSNumber__c from Contact Where LastName='TestConOne'];
        Contact getContwo = [Select Id,SMSNumber__c from Contact Where LastName='TestConTwo'];
        subRequest.ContactId = getConOne.Id;
        subRequest.Name = nameObj;
        subRequest.MailingAddress = maObj;
        smsObj.Locale = 'em_US_en_US_en_US_en_US'; //more than 10 char
        subRequest.SMS = smsObj;
        System.debug('******Request 4 = '+subRequest);
        String reqString = JSON.serialize(subRequest);
        req.requestBody = Blob.valueof(reqString);
        RestContext.request = req;
        RestContext.response= res;
        SubscriberProfileUpdates.PCUpdateResponse subResponse = new SubscriberProfileUpdates.PCUpdateResponse();
        subResponse = SubscriberProfileUpdates.doSignUp();
        System.debug('***Response 4 = '+subResponse);
       
    }
}