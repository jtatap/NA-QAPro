@isTest
public class CustomerSMSOptinServicesTest {
    private static Contact createContact(){
        //Test Data for account and contact
        Account acc = new Account(Name=System.Label.PlaceHolderAccountName);
        String recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId();
        insert acc;
        Contact con = new Contact();  
        con.Source_System__c = 'eComm';
        con.AccountId = acc.Id;
        con.Brand_Id__c = '1';
        con.FirstName = 'cfname';
        con.LastName = 'clname';
        con.Email = 'testemail@nomail.com';
        con.EmailOptInStatus__c = 'Y'; // true;
        con.EmailOptInDate__c = System.now();
        con.LoyaltyFlag__c=false;
        con.WelcomeSource__c = '01';
		con.StoreOfCapture__c = 'cLoc';
        con.SMSNumber__c = '9999988888';
        insert con;
        return con;
     }
    
    private static Contact createContact2(){
        //Test Data for account and contact
        Account acc = new Account(Name=System.Label.PlaceHolderAccountName);
        String recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId();
        insert acc;
        Contact con = new Contact();  
        con.Source_System__c = 'eComm';
        con.AccountId = acc.Id;
        con.Brand_Id__c = '1';
        con.FirstName = 'cfname';
        con.LastName = 'clname';
        con.Email = 'testemail@nomail.com';
        con.EmailOptInStatus__c = 'N'; // true;
        con.EmailOptInDate__c = System.now();
        con.LoyaltyFlag__c=false;
        con.WelcomeSource__c = '01';
		con.StoreOfCapture__c = 'cLoc';
        con.SMSNumber__c = '8888899999';
        insert con;
        return con;
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
    
    @isTest static void testdoOptinSMSInUse(){
        
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
        System.assertEquals('SMS_NUMBER_IN_USE', sfccRes.code);
        Test.stopTest();
    }
 	
    @isTest static void testdoOptinValidContactUpdate(){
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
    }
    
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
 
}