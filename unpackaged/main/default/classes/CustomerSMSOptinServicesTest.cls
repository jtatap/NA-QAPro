@isTest
public class CustomerSMSOptinServicesTest {
    
     /*@testSetup
    static void dataSetup() {
        Account accOne = new Account(Name = 'Testing', Gender__c='M');
        insert accOne;
        
         
        Contact cfname4 = new Contact(LastName='cfname4', AccountId=accOne.Id,Brand_Id__c='1', Email='testemail11@nomail.com');
        insert cfname4;
        
    }*/
    
    public static Contact createContact(){
        //Test Data for account and contact
        Account acc = new Account(Name=System.Label.PlaceHolderAccountName);
        String recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId();
        insert acc;
        Contact con1 = new Contact();  
        con1.Source_System__c = 'eComm';
        con1.AccountId = acc.Id;
        con1.Brand_Id__c = '1';
        con1.FirstName = 'cfname';
        con1.LastName = 'clname';
        con1.Email = 'testemail@nomail.com';
        con1.EmailOptInStatus__c = 'Y'; // true;
        con1.EmailOptInDate__c = System.now();
        con1.LoyaltyFlag__c=false;
        con1.WelcomeSource__c = '01';
		con1.StoreOfCapture__c = 'cLoc';
        con1.SMSNumber__c = '19999988888';
        insert con1;
        return con1;
     }
    
    private static Contact createContact2(){
        //Test Data for account and contact
        Account acc = new Account(Name=System.Label.PlaceHolderAccountName);
        String recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId();
        insert acc;
        Contact con2 = new Contact();  
        con2.Source_System__c = 'eComm';
        con2.AccountId = acc.Id;
        con2.Brand_Id__c = '1';
        con2.FirstName = 'cfname';
        con2.LastName = 'clname';
        con2.Email = 'testemail@nomail.com';
        con2.EmailOptInStatus__c = 'N'; // true;
        con2.EmailOptInDate__c = System.now();
        con2.LoyaltyFlag__c=false;
        con2.WelcomeSource__c = '01';
		con2.StoreOfCapture__c = 'cLoc';
        con2.SMSNumber__c = '18888899999';
        insert con2;
        return con2;
    }
    
    private static Contact createContact3(){
        //Test Data for account and contact
        Account acc = new Account(Name=System.Label.PlaceHolderAccountName);
        String recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId();
        insert acc;
        Contact con3 = new Contact();  
        con3.Source_System__c = 'eComm';
        con3.AccountId = acc.Id;
        con3.Brand_Id__c = '1';
        con3.FirstName = 'cfname';
        con3.LastName = 'clname';
        con3.Email = 'testemail1@nomail.com';
        con3.EmailOptInStatus__c = 'Y'; // true;
        con3.SMSOptinStatus__c = 'Y'; // true;
        con3.SMSOptInDate__c= System.now();
        con3.EmailOptInDate__c = System.now();
        con3.LoyaltyFlag__c=false;
        con3.WelcomeSource__c = '01';
		con3.StoreOfCapture__c = 'cLoc';
        con3.SMSNumber__c = '18898899999';
        insert con3;
        return con3;
    }
    
    
    @isTest static void testdoOptinBlankSubKey(){
        //Test for Email source is not passed in the request
        CustomerSMSOptinServices.SFCCRequest sfccReq = new CustomerSMSOptinServices.SFCCRequest();
        CustomerSMSOptinServices.SFCCResponse  sfccRes = new CustomerSMSOptinServices.SFCCResponse();
        sfccReq.brandId = '1';
        sfccReq.emailAddress ='abcde@def.com';
        sfccReq.SMSNumber='9999988888';
        sfccReq.SMSOptinStatus='P';
        sfccReq.Locale='en_us';
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        String jsonMsg=JSON.serialize(sfccReq);
        req.requestURI = '/subscriptions/customeroptin';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        sfccRes = CustomerSMSOptinServices.doOptin();
        System.assertEquals(res.statusCode, 200);
        System.assertEquals('Missing: ContactId', sfccRes.message);
        System.assertEquals('MISSING_PARAMETERS', sfccRes.code);
        Test.stopTest();
    }
   /* @isTest static void testSMSNumberExists(){
        //Test for Email source is not passed in the request
        //
        Account accOne = new Account(Name = 'Testing', Gender__c='M');
        insert accOne;
        
         
        Contact cfname4 = new Contact(LastName='cfname4', AccountId=accOne.Id,Brand_Id__c='1', Email='testemail11@nomail.com');
        insert cfname4;
         CustomerSMSOptinServices.SFCCRequest sfccReq = new CustomerSMSOptinServices.SFCCRequest();
        CustomerSMSOptinServices.SFCCResponse  sfccRes = new CustomerSMSOptinServices.SFCCResponse();
        //List<Contact> conList=[Select Id,Email,SMSOptinStatus__c from Contact where Email='testemail11@nomail.com' limit 1];
        //Contact getConfour = [Select Id,SMSNumber__c,LastName from Contact Where LastName='cfname4' and Email='testemail11@nomail.com' limit 1];
        sfccReq.brandId = '1';
        sfccReq.emailAddress ='testemail11@nomail.com';
        sfccReq.SMSNumber='8898899999';
        sfccReq.Subscriberkey=cfname4.Id;
        //sfccReq.Subscriberkey = '0032C00000hn06g';
        sfccReq.SMSOptinStatus='P';
        sfccReq.Locale='en_us';
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        String jsonMsg=JSON.serialize(sfccReq);
        req.requestURI = '/subscriptions/customeroptin';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        sfccRes = CustomerSMSOptinServices.doOptin();
        System.assertEquals(res.statusCode, 200);
        System.assertEquals('Ok', sfccRes.code);
        System.assertEquals('SUCCESS', sfccRes.message);
        Test.stopTest();
    } */
    @isTest static void testdoOptinContactNotFound(){
        //Test for Email source is not passed in the request
        CustomerSMSOptinServices.SFCCRequest sfccReq = new CustomerSMSOptinServices.SFCCRequest();
        CustomerSMSOptinServices.SFCCResponse  sfccRes = new CustomerSMSOptinServices.SFCCResponse();
        sfccReq.brandId = '1';
        sfccReq.Subscriberkey = '0032C00000hn06g';
        sfccReq.emailAddress ='abcde@def.com';
        sfccReq.SMSNumber='9999988888';
        sfccReq.SMSOptinStatus='P';
        sfccReq.Locale='en_us';
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        String jsonMsg=JSON.serialize(sfccReq);
        req.requestURI = '/subscriptions/customeroptin';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        sfccRes = CustomerSMSOptinServices.doOptin();
        System.assertEquals(res.statusCode, 200);
        System.assertEquals('No matching contact found', sfccRes.message);
        System.assertEquals('CONTACT_NOT_FOUND', sfccRes.code);
        Test.stopTest();
    }
    
    /*@isTest static void testdoOptinSMSInUse(){
        
        Contact Cont1 = createContact();
        Contact Cont2 = createContact2();
        
        CustomerSMSOptinServices.SFCCRequest sfccReq = new CustomerSMSOptinServices.SFCCRequest();
        CustomerSMSOptinServices.SFCCResponse  sfccRes = new CustomerSMSOptinServices.SFCCResponse();
        sfccReq.brandId = '1';
        sfccReq.Subscriberkey = cont2.Id;
        sfccReq.emailAddress ='abcde@def.com';
        sfccReq.SMSNumber='9999988888';
        sfccReq.SMSOptinStatus='P';
        sfccReq.Locale='en_us';
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        String jsonMsg=JSON.serialize(sfccReq);
        req.requestURI = '/subscriptions/customeroptin';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        sfccRes = CustomerSMSOptinServices.doOptin();
        System.assertEquals(res.statusCode, 200);
        System.assertEquals('SMS Number used by another contact', sfccRes.message);
        //System.assertEquals('SUCCESS', sfccRes.message);
        System.assertEquals('SMS_NUMBER_IN_USE', sfccRes.code);
        Test.stopTest();
    }*/
 	
   /* @isTest static void testdoOptinValidContactUpdate(){
        Contact Cont1 = createContact();
        CustomerSMSOptinServices.SFCCRequest sfccReq = new CustomerSMSOptinServices.SFCCRequest();
        CustomerSMSOptinServices.SFCCResponse  sfccRes = new CustomerSMSOptinServices.SFCCResponse();
        sfccReq.brandId = '1';
        sfccReq.Subscriberkey = Cont1.Id;
        sfccReq.emailAddress =Cont1.Email;
        sfccReq.SMSNumber='7777788899';
        sfccReq.SMSOptinStatus='P';
        sfccReq.Locale='en_us';
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        String jsonMsg=JSON.serialize(sfccReq);
        req.requestURI = '/subscriptions/customeroptin';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        sfccRes = CustomerSMSOptinServices.doOptin();    
        System.assertEquals(res.statusCode, 200);
        System.assertEquals('SUCCESS', sfccRes.message);
        System.assertEquals('Ok', sfccRes.code);
        Test.stopTest();
    }*/
    
    @isTest static void testdoOptinException(){
        Contact Cont1 = createContact();
        CustomerSMSOptinServices.SFCCRequest sfccReq = new CustomerSMSOptinServices.SFCCRequest();
        CustomerSMSOptinServices.SFCCResponse  sfccRes = new CustomerSMSOptinServices.SFCCResponse();
        sfccReq.brandId = '1';
        sfccReq.Subscriberkey = Cont1.Id;
        sfccReq.emailAddress ='asldfa aldsfja ';
        sfccReq.SMSNumber='ABCD 23EF$^$';
        sfccReq.SMSOptinStatus='P';
        sfccReq.Locale='en_us';
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        String jsonMsg=JSON.serialize(sfccReq);
        req.requestURI = '/subscriptions/customeroptin';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        sfccRes = CustomerSMSOptinServices.doOptin();    
        System.assertEquals(res.statusCode, 500);
        System.assertEquals('OTHER_ERROR', sfccRes.code);
        Test.stopTest();
    }
 	
    
    @isTest static void testdoOptinOptingOutSMS(){
        Contact Cont1 = createContact();
        CustomerSMSOptinServices.SFCCRequest sfccReq = new CustomerSMSOptinServices.SFCCRequest();
        CustomerSMSOptinServices.SFCCResponse  sfccRes = new CustomerSMSOptinServices.SFCCResponse();
        sfccReq.brandId = '1';
        sfccReq.Subscriberkey = Cont1.Id;
        sfccReq.emailAddress =Cont1.Email;
        sfccReq.SMSNumber='9999988888';
        sfccReq.SMSOptinStatus='N';
        sfccReq.Locale='en_us';
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        String jsonMsg=JSON.serialize(sfccReq);
        req.requestURI = '/subscriptions/customeroptin';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        sfccRes = CustomerSMSOptinServices.doOptin();
        System.assertEquals(res.statusCode, 200);
        System.assertEquals('SUCCESS', sfccRes.message);
        System.assertEquals('Ok', sfccRes.code);
        Test.stopTest();
    }
 
    @isTest static void testdoOptinOptingOutException(){
        Contact Cont1 = createContact();
        CustomerSMSOptinServices.SFCCRequest sfccReq = new CustomerSMSOptinServices.SFCCRequest();
        CustomerSMSOptinServices.SFCCResponse  sfccRes = new CustomerSMSOptinServices.SFCCResponse();
        sfccReq.brandId = '1';
        sfccReq.Subscriberkey = Cont1.Id;
        sfccReq.emailAddress ='aljfads alsdfj';
        sfccReq.SMSNumber='9999988888';
        sfccReq.SMSOptinStatus='N';
        sfccReq.Locale='en_us';
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        String jsonMsg=JSON.serialize(sfccReq);
        req.requestURI = '/subscriptions/customeroptin';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        sfccRes = CustomerSMSOptinServices.doOptin();
        System.assertEquals(res.statusCode, 500);
        System.assertEquals('OTHER_ERROR', sfccRes.code);
        Test.stopTest();
    }
 
        @isTest static void testdoOptinElse(){
        Contact Cont1 = createContact();
        CustomerSMSOptinServices.SFCCRequest sfccReq = new CustomerSMSOptinServices.SFCCRequest();
        CustomerSMSOptinServices.SFCCResponse  sfccRes = new CustomerSMSOptinServices.SFCCResponse();
        sfccReq.brandId = '1';
        sfccReq.Subscriberkey = Cont1.Id;
        sfccReq.emailAddress =Cont1.Email;
        sfccReq.SMSNumber='7777788888';
        sfccReq.SMSOptinStatus='N';
        sfccReq.Locale='en_us';
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        String jsonMsg=JSON.serialize(sfccReq);
        req.requestURI = '/subscriptions/customeroptin';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        sfccRes = CustomerSMSOptinServices.doOptin();
        System.assertEquals(res.statusCode, 200);
        System.assertEquals('Success', sfccRes.message);
        System.assertEquals('Ok', sfccRes.code);
        Test.stopTest();
    }
    
    @isTest static void testdoOptinElseException(){
        Contact Cont1 = createContact();
        CustomerSMSOptinServices.SFCCRequest sfccReq = new CustomerSMSOptinServices.SFCCRequest();
        CustomerSMSOptinServices.SFCCResponse  sfccRes = new CustomerSMSOptinServices.SFCCResponse();
        sfccReq.brandId = '1';
        sfccReq.Subscriberkey = Cont1.Id;
        sfccReq.emailAddress ='asdfl alsfdjsdf';
        sfccReq.SMSNumber='7777788888';
        sfccReq.SMSOptinStatus='N';
        sfccReq.Locale='en_us';
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        String jsonMsg=JSON.serialize(sfccReq);
        req.requestURI = '/subscriptions/customeroptin';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        sfccRes = CustomerSMSOptinServices.doOptin();
        System.assertEquals(res.statusCode, 500);
        System.assertEquals('OTHER_ERROR', sfccRes.code);
        Test.stopTest();
    }
    
   @isTest static void testdoOptinSMSNull(){
        Contact Cont1 = createContact();
       	System.debug('Cont1****' + Cont1.Id );
        CustomerSMSOptinServices.SFCCRequest sfccReq = new CustomerSMSOptinServices.SFCCRequest();
        CustomerSMSOptinServices.SFCCResponse  sfccRes = new CustomerSMSOptinServices.SFCCResponse();
        sfccReq.brandId = '1';
        sfccReq.Subscriberkey = Cont1.Id;
        sfccReq.emailAddress ='smsnull@yop.com ';
        sfccReq.SMSNumber='9999988888';
        sfccReq.SMSOptinStatus='Y';
        sfccReq.Locale='en_us';
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        String jsonMsg=JSON.serialize(sfccReq);
        req.requestURI = '/subscriptions/customeroptin';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        sfccRes = CustomerSMSOptinServices.doOptin();    
        //System.assertEquals(res.statusCode, 500);
        //System.assertEquals('OTHER_ERROR', sfccRes.code);
        Test.stopTest();
    }
 
}