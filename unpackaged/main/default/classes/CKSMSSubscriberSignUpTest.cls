@isTest
public class CKSMSSubscriberSignUpTest {

	@testSetup
    static void dataSetup() {
        List<Contact> listTestContacts = new List<Contact>();
        Account accOne = new Account(Name = 'Testing', Gender__c='M');
        insert accOne;
        
        Contact conOne = new Contact(LastName='TestConOne', AccountId=accOne.Id,
                                     Brand_Id__c='2',SMSNumber__c='15555555550',Email='emailone@doamin.com',SMSOptinStatus__c='Y',SMSLocale__c='en_US');
        listTestContacts.add(conOne);
        
        Contact conTwo = new Contact(LastName='TestConTwo', AccountId=accOne.Id,
                                     Brand_Id__c='2',Email='emailtwo@doamin.com',SMSNumber__c='');
        listTestContacts.add(conTwo);
        
        Contact conThree = new Contact(LastName='TestConThree', AccountId=accOne.Id,
                                     Brand_Id__c='2',SMSNumber__c='15555555552',Email='');
        listTestContacts.add(conThree);
        
        Contact conFour = new Contact(LastName='TestConFour', AccountId=accOne.Id,
                                     Brand_Id__c='2',Email='emailfour@doamin.com',SMSNumber__c='15555555551');
        listTestContacts.add(conFour);
        
        Contact conFive = new Contact(LastName='TestConFive', AccountId=accOne.Id,
                                     Brand_Id__c='2',SMSNumber__c='',Email='');
        listTestContacts.add(conFive);
        Contact conSix = new Contact(LastName='TestConSix', AccountId=accOne.Id,
                                     Brand_Id__c='2',Email='emailsix@doamin.com',SMSNumber__c='15545455550');
        listTestContacts.add(conSix);
        Contact conSeven = new Contact(LastName='TestConSeven', AccountId=accOne.Id,
                                     Brand_Id__c='2',Email='',SMSNumber__c='15545555550');
        listTestContacts.add(conSeven);
        /*
        Contact conSix = new Contact(LastName='TestConSix', AccountId=accOne.Id,
                                     Brand_Id__c='1',SMSNumber__c='15555555558',Email='emailsix@doamin.com');
       	listTestContacts.add(conSix);
        */
        insert listTestContacts;
        
    }
    @isTest
    public static void doSMSSignUp_missingParameters(){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
    
        RestContext.request = req;
        RestContext.response= res;
        CKSMSSubscriberSignUp.SMSRequest requestObj = new CKSMSSubscriberSignUp.SMSRequest();
        CKSMSSubscriberSignUp.SMSResponse responseObj = new CKSMSSubscriberSignUp.SMSResponse();
        requestObj.brandId = ' ';
		requestObj.emailAddress = 'noemailone@domain.com';
		requestObj.smsNumber = '15555555551';
		requestObj.loyaltyOptin = true;
		requestObj.storeOfCapture = 'CK801';
        requestObj.locale = 'en_US';
        //newCon.SMSLocale__c  =smsRequest.locale;
      	String JSONRequest = JSON.serialize(requestObj);  
     	req.requestURI = '/CKSMSSubscriber/SignUp';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JSONRequest);
        responseObj = CKSMSSubscriberSignUp.doSMSSignUp();
        System.debug('***Got Response = '+responseObj);
        System.debug('***RES = '+res);
        System.assertEquals('MISSING_PARAMETERS', responseObj.code);
    }
    @isTest
    public static void doSMSSignUp_missingParameters1(){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
    
        RestContext.request = req;
        RestContext.response= res;
        CKSMSSubscriberSignUp.SMSRequest requestObj = new CKSMSSubscriberSignUp.SMSRequest();
        CKSMSSubscriberSignUp.SMSResponse responseObj = new CKSMSSubscriberSignUp.SMSResponse();
        requestObj.brandId = '2';
		requestObj.emailAddress = '';
		requestObj.smsNumber = '15555555551';
		requestObj.loyaltyOptin = true;
		requestObj.storeOfCapture = 'CK801';
        requestObj.locale = 'en_US';
        //newCon.SMSLocale__c  =smsRequest.locale;
      	String JSONRequest = JSON.serialize(requestObj);  
     	req.requestURI = '/CKSMSSubscriber/SignUp';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JSONRequest);
        responseObj = CKSMSSubscriberSignUp.doSMSSignUp();
        System.debug('***Got Response = '+responseObj);
        System.debug('***RES = '+res);
        System.assertEquals('MISSING_PARAMETERS', responseObj.code);
    }
     @isTest
    public static void doSMSSignUp_ExactSMSEmailMatch(){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
    
        RestContext.request = req;
        RestContext.response= res;
        CKSMSSubscriberSignUp.SMSRequest requestObj = new CKSMSSubscriberSignUp.SMSRequest();
        CKSMSSubscriberSignUp.SMSResponse responseObj = new CKSMSSubscriberSignUp.SMSResponse();
        requestObj.brandId = '2';
		requestObj.emailAddress = 'emailone@doamin.com';
		requestObj.smsNumber = '15555555550';
		requestObj.loyaltyOptin = true;
		requestObj.storeOfCapture = 'CK801';
        requestObj.locale = 'es_MX';
        //newCon.SMSLocale__c  =smsRequest.locale;
      	String JSONRequest = JSON.serialize(requestObj);  
     	req.requestURI = '/CKSMSSubscriber/SignUp';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JSONRequest);
        responseObj = CKSMSSubscriberSignUp.doSMSSignUp();
        System.debug('***Got Response = '+responseObj);
        System.debug('***RES = '+res);
        
    }
   @isTest
    public static void doSMSSignUp_SMSMatchNoEmailMatch(){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
    
        RestContext.request = req;
        RestContext.response= res;
        CKSMSSubscriberSignUp.SMSRequest requestObj = new CKSMSSubscriberSignUp.SMSRequest();
        CKSMSSubscriberSignUp.SMSResponse responseObj = new CKSMSSubscriberSignUp.SMSResponse();
        requestObj.brandId = '2';
		requestObj.emailAddress = 'emailone123@doamin.com';
		requestObj.smsNumber = '15555555550';
		requestObj.loyaltyOptin = true;
		requestObj.storeOfCapture = 'CK801';
        requestObj.locale = 'es_MX';
        //newCon.SMSLocale__c  =smsRequest.locale;
      	String JSONRequest = JSON.serialize(requestObj);  
     	req.requestURI = '/CKSMSSubscriber/SignUp';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JSONRequest);
        responseObj = CKSMSSubscriberSignUp.doSMSSignUp();
        System.debug('***Got Response = '+responseObj);
        System.debug('***RES = '+res);
        
    }
    @isTest
    public static void doSMSSignUp_SMSMatchInvalidEmailMatch(){
          List<Contact> updatedlistTestContacts = new List<Contact>();
        Account acctwo = new Account(Name = 'Testing', Gender__c='M');
        insert accTwo;
        
        Contact conEight = new Contact(LastName='TestConEight', AccountId=accTwo.Id,
                                     Brand_Id__c='2',SMSNumber__c='15555555557',Email='',SMSOptinStatus__c='Y');
        updatedlistTestContacts.add(conEight);
        Contact connine= new Contact(LastName='TestConnine', AccountId=accTwo.Id,
                                     Brand_Id__c='2',SMSNumber__c='',Email='emailtest9@doamin.com',SMSOptinStatus__c='Y');
        updatedlistTestContacts.add(connine);
        insert updatedlistTestContacts;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
    
        RestContext.request = req;
        RestContext.response= res;
        CKSMSSubscriberSignUp.SMSRequest requestObj = new CKSMSSubscriberSignUp.SMSRequest();
        CKSMSSubscriberSignUp.SMSResponse responseObj = new CKSMSSubscriberSignUp.SMSResponse();
        requestObj.brandId = '2';
		requestObj.emailAddress = 'emailtest9@doamin.com';
		requestObj.smsNumber = '15555555557';
		requestObj.loyaltyOptin = true;
		requestObj.storeOfCapture = 'CK801';
        requestObj.locale = 'es_MX';
        //newCon.SMSLocale__c  =smsRequest.locale;
      	String JSONRequest = JSON.serialize(requestObj);  
     	req.requestURI = '/CKSMSSubscriber/SignUp';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JSONRequest);
        responseObj = CKSMSSubscriberSignUp.doSMSSignUp();
        System.debug('***Got Response = '+responseObj);
        System.debug('***RES = '+res);
        
    }
    @isTest
    public static void doSMSSignUp_EmailMatch(){
          List<Contact> updatedlistTestContacts = new List<Contact>();
        Account acc3 = new Account(Name = 'Testing', Gender__c='M');
        insert acc3;
        
        Contact con10= new Contact(LastName='TestCon10', AccountId=acc3.Id,
                                     Brand_Id__c='2',SMSNumber__c='15557655557',Email='emailtest10@doamin.com',SMSOptinStatus__c='Y',LoyaltyFlag__c=False);
        updatedlistTestContacts.add(con10);
        insert updatedlistTestContacts;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
    
        RestContext.request = req;
        RestContext.response= res;
        CKSMSSubscriberSignUp.SMSRequest requestObj = new CKSMSSubscriberSignUp.SMSRequest();
        CKSMSSubscriberSignUp.SMSResponse responseObj = new CKSMSSubscriberSignUp.SMSResponse();
        requestObj.brandId = '2';
		requestObj.emailAddress = 'emailtest10@doamin.com';
		requestObj.smsNumber = '15557555557';
		requestObj.loyaltyOptin = true;
		requestObj.storeOfCapture = 'CK801';
        requestObj.locale = 'es_MX';
        //newCon.SMSLocale__c  =smsRequest.locale;
      	String JSONRequest = JSON.serialize(requestObj);  
     	req.requestURI = '/CKSMSSubscriber/SignUp';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JSONRequest);
        responseObj = CKSMSSubscriberSignUp.doSMSSignUp();
        System.debug('***Got Response = '+responseObj);
        System.debug('***RES = '+res);
        
    }
    
}