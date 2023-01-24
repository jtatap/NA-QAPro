@isTest
public class SMSSubscriberSignUpTest {

	@testSetup
    static void dataSetup() {
        List<Contact> listTestContacts = new List<Contact>();
        Account accOne = new Account(Name = 'Testing', Gender__c='M');
        insert accOne;
        
        Contact conOne = new Contact(LastName='TestConOne', AccountId=accOne.Id,
                                     Brand_Id__c='1',SMSNumber__c='15555555550',Email='emailone@doamin.com');
        listTestContacts.add(conOne);
        
        Contact conTwo = new Contact(LastName='TestConTwo', AccountId=accOne.Id,
                                     Brand_Id__c='1',Email='emailtwo@doamin.com');
        listTestContacts.add(conTwo);
        
        Contact conThree = new Contact(LastName='TestConThree', AccountId=accOne.Id,
                                     Brand_Id__c='1',SMSNumber__c='15555555552');
        listTestContacts.add(conThree);
        
        Contact conFour = new Contact(LastName='TestConFour', AccountId=accOne.Id,
                                     Brand_Id__c='1',Email='emailfour@doamin.com');
        listTestContacts.add(conFour);
        
        Contact conFive = new Contact(LastName='TestConFive', AccountId=accOne.Id,
                                     Brand_Id__c='1',SMSNumber__c='15555555550',Email='emailfive@doamin.com');
        listTestContacts.add(conFive);
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
        SMSSubscriberSignUp.SMSRequest requestObj = new SMSSubscriberSignUp.SMSRequest();
        SMSSubscriberSignUp.SMSResponse responseObj = new SMSSubscriberSignUp.SMSResponse();
        requestObj.brandId = ' ';
		requestObj.emailAddress = 'noemailone@domain.com';
		requestObj.smsNumber = '15555555551';
		requestObj.loyaltyOptin = true;
		requestObj.storeOfCapture = 'CK801';
        requestObj.locale = 'en_US';
        //newCon.SMSLocale__c  =smsRequest.locale;
      	String JSONRequest = JSON.serialize(requestObj);  
     	req.requestURI = '/SMSSubscriber/SignUp';
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueof(JSONRequest);
        responseObj = SMSSubscriberSignUp.doSMSSignUp();
        System.debug('***Got Response = '+responseObj);
        System.debug('***RES = '+res);
        System.assertEquals('MISSING_PARAMETERS', responseObj.code);
    }
    
    @isTest
    public static void doSMSSignUp_OptIn_1(){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
    
        RestContext.request = req;
        RestContext.response= res;
        SMSSubscriberSignUp.SMSRequest requestObj = new SMSSubscriberSignUp.SMSRequest();
        SMSSubscriberSignUp.SMSResponse responseObj = new SMSSubscriberSignUp.SMSResponse();
        requestObj.brandId = '1';
		requestObj.emailAddress = 'noemailone@domain.com';
		requestObj.smsNumber = '7878787878';
		requestObj.loyaltyOptin = true;
		requestObj.storeOfCapture = 'CK801';
        requestObj.locale = 'en_US';
      	String JSONRequest = JSON.serialize(requestObj);  
     	req.requestURI = '/SMSSubscriber/SignUp';
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueof(JSONRequest);
        responseObj = SMSSubscriberSignUp.doSMSSignUp();
        System.debug('***Got Response = '+responseObj);
        System.debug('***RES = '+res);
    }
    
    @isTest
    public static void doSMSSignUp_OptIn_2(){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
    
        RestContext.request = req;
        RestContext.response= res;
        SMSSubscriberSignUp.SMSRequest requestObj = new SMSSubscriberSignUp.SMSRequest();
        SMSSubscriberSignUp.SMSResponse responseObj = new SMSSubscriberSignUp.SMSResponse();
        requestObj.brandId = '1';
		requestObj.emailAddress = 'emailtwo@doamin.com';
		requestObj.smsNumber = '7878787878';
		requestObj.loyaltyOptin = true;
		requestObj.storeOfCapture = 'CK801';
        requestObj.locale = 'en_US';
      	String JSONRequest = JSON.serialize(requestObj);  
     	req.requestURI = '/SMSSubscriber/SignUp';
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueof(JSONRequest);
        responseObj = SMSSubscriberSignUp.doSMSSignUp();
        System.debug('***Got Response = '+responseObj);
        System.debug('***RES = '+res);
    }
    
    @isTest
    public static void doSMSSignUp_OptIn_3(){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
    
        RestContext.request = req;
        RestContext.response= res;
        SMSSubscriberSignUp.SMSRequest requestObj = new SMSSubscriberSignUp.SMSRequest();
        SMSSubscriberSignUp.SMSResponse responseObj = new SMSSubscriberSignUp.SMSResponse();
        requestObj.brandId = '1';
		requestObj.emailAddress = 'emailfive@doamin.com';
		requestObj.smsNumber = '15555555556';
		requestObj.loyaltyOptin = true;
		requestObj.storeOfCapture = 'CK801';
        requestObj.locale = 'en_US';
      	String JSONRequest = JSON.serialize(requestObj);  
     	req.requestURI = '/SMSSubscriber/SignUp';
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueof(JSONRequest);
        responseObj = SMSSubscriberSignUp.doSMSSignUp();
        System.debug('***Got Response = '+responseObj);
        System.debug('***RES = '+res);
    }
    
    @isTest
    public static void doSMSSignUp_Re_OptIn_5(){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
    
        RestContext.request = req;
        RestContext.response= res;
        SMSSubscriberSignUp.SMSRequest requestObj = new SMSSubscriberSignUp.SMSRequest();
        SMSSubscriberSignUp.SMSResponse responseObj = new SMSSubscriberSignUp.SMSResponse();
        requestObj.brandId = '1';
		requestObj.emailAddress = 'noemailfour@doamin.com';
		requestObj.smsNumber = '15555555552';
		requestObj.loyaltyOptin = true;
		requestObj.storeOfCapture = 'CK801';
        requestObj.locale = 'en_US';
      	String JSONRequest = JSON.serialize(requestObj);  
     	req.requestURI = '/SMSSubscriber/SignUp';
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueof(JSONRequest);
        responseObj = SMSSubscriberSignUp.doSMSSignUp();
        System.debug('***Got Response = '+responseObj);
        System.debug('***RES = '+res);
    }
    
    @isTest
    public static void doSMSSignUp_ReOptIn_1_2_3_4_5(){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
    
        RestContext.request = req;
        RestContext.response= res;
        SMSSubscriberSignUp.SMSRequest requestObj = new SMSSubscriberSignUp.SMSRequest();
        SMSSubscriberSignUp.SMSResponse responseObj = new SMSSubscriberSignUp.SMSResponse();
        requestObj.brandId = '1';
		requestObj.emailAddress = 'emailfour@doamin.com';
		requestObj.smsNumber = '15555555552';
		requestObj.loyaltyOptin = true;
		requestObj.storeOfCapture = 'CK801';
        requestObj.locale = 'en_US';
      	String JSONRequest = JSON.serialize(requestObj);  
     	req.requestURI = '/SMSSubscriber/SignUp';
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueof(JSONRequest);
        responseObj = SMSSubscriberSignUp.doSMSSignUp();
        System.debug('***Got Response = '+responseObj);
        System.debug('***RES = '+res);
    }
}