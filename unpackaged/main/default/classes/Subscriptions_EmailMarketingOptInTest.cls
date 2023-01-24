@isTest
public class Subscriptions_EmailMarketingOptInTest {
	
    private static Contact createContact(){
        //Test Data for account and contact
        Account acc = new Account(Name=System.Label.PlaceHolderAccountName);
        String recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId();
        insert acc;
        Contact con = new Contact();  
        con.Source_System__c = 'eComm';
        con.AccountId = acc.Id;
        con.Brand_Id__c = '2';
        con.FirstName = 'cfname';
        con.LastName = 'clname';
        con.Email = 'testemail@nomail.com';
        con.EmailOptInStatus__c = 'Y'; // true;
        con.EmailOptInDate__c = System.now();
        con.LoyaltyFlag__c=false;
        con.WelcomeSource__c = '01';
		con.StoreOfCapture__c = 'cLoc';
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
        con.Brand_Id__c = '2';
        con.FirstName = 'cfname';
        con.LastName = 'clname';
        con.Email = 'testemail@nomail.com';
        con.EmailOptInStatus__c = 'N'; // true;
        con.EmailOptInDate__c = System.now();
        con.LoyaltyFlag__c=false;
        con.WelcomeSource__c = '01';
		con.StoreOfCapture__c = 'cLoc';
        insert con;
        return con;
    }

    @isTest static void testDoSignupEmailsourceNull(){
        //Test for Email source is not passed in the request
        Subscriptions_EmailMarketingOptIn.SFCCRequest sfccReq = new Subscriptions_EmailMarketingOptIn.SFCCRequest();
        Subscriptions_EmailMarketingOptIn.SFCCResponse  sfccRes = new Subscriptions_EmailMarketingOptIn.SFCCResponse();
        sfccReq.brandId = '';
        sfccReq.emailAddress ='';
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        String jsonMsg=JSON.serialize(sfccReq);
        req.requestURI = '/Subscriptions/EmailMarketingOptIn';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        sfccRes = Subscriptions_EmailMarketingOptIn.doSignup();
        System.assertEquals(res.statusCode, 400);
        System.assertEquals('Request rejected. Unsupported value "head-n-tail" was passed for parameternull', sfccRes.message);
        System.assertEquals('INVALID_QUERY', sfccRes.code);
        Test.stopTest();
    }
    
    @isTest static void testDoSignupWeOverlay(){
        //Test for welcome source WE_OVERLAY 
        Contact conRec = createContact();
        Subscriptions_EmailMarketingOptIn.SFCCRequest sfccReq = new Subscriptions_EmailMarketingOptIn.SFCCRequest();
        Subscriptions_EmailMarketingOptIn.SFCCResponse  sfccRes = new Subscriptions_EmailMarketingOptIn.SFCCResponse();
        sfccReq.firstName = 'TEST NAME1';
        sfccReq.lastName = 'TEST NAME2';
        sfccReq.brandId = '1';
        sfccReq.emailAddress ='test@yopemail.com';
        sfccReq.region = 'NA';
        sfccReq.country = 'CA';
        sfccReq.market = 'CA';
        sfccReq.sourceSystem = 'ecom';
        sfccReq.requestType = 'Subscribe';
        sfccReq.EmailOrgSource = 'WE_OVERLAY';
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        String jsonMsg=JSON.serialize(sfccReq);
        req.requestURI = '/Subscriptions/EmailMarketingOptIn';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        sfccRes = Subscriptions_EmailMarketingOptIn.doSignup();
        Test.stopTest();
        System.assertEquals(res.statusCode, 200);
        Contact returnContact = [SELECT Id, WelcomeSource__c, EmailOrigSource__c FROM Contact WHERE Id =: sfccRes.Subscriberkey];
        System.assertEquals('01', returnContact.WelcomeSource__c);
        System.assertEquals('OK', sfccRes.code);
        System.assertEquals('Success', sfccRes.message);
    }
    
        @isTest static void testDoSignupWeCheckout(){
		//Test for welcome sourse WE_CHECKOUT        
		Contact conRec = createContact();
        Subscriptions_EmailMarketingOptIn.SFCCRequest sfccReq = new Subscriptions_EmailMarketingOptIn.SFCCRequest();
        Subscriptions_EmailMarketingOptIn.SFCCResponse  sfccRes = new Subscriptions_EmailMarketingOptIn.SFCCResponse();
        sfccReq.firstName = 'TEST NAME1';
        sfccReq.lastName = 'TEST NAME2';
        sfccReq.brandId = '1';
        sfccReq.emailAddress ='test@yopemail.com';
        sfccReq.region = 'NA';
        sfccReq.country = 'US';
        sfccReq.market = 'CA';
        sfccReq.sourceSystem = 'ecom';
        sfccReq.requestType = 'Subscribe';
        sfccReq.EmailOrgSource = 'WE_CHECKOUT';
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        String jsonMsg=JSON.serialize(sfccReq);
        req.requestURI = '/Subscriptions/EmailMarketingOptIn';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        sfccRes = Subscriptions_EmailMarketingOptIn.doSignup();
        Test.stopTest();
        System.assertEquals(res.statusCode, 200);
        Contact returnContact = [SELECT Id, WelcomeSource__c, EmailOrigSource__c FROM Contact WHERE Id =: sfccRes.Subscriberkey];
        System.assertEquals('04', returnContact.WelcomeSource__c);
        System.assertEquals('OK', sfccRes.code);
        System.assertEquals('Success', sfccRes.message);
    }
    
    @isTest static void testDoSignupWeCheckoutCA(){
        //Test for welcome sourse WE_CHECKOUT and Country CA
        Contact conRec = createContact();
        Subscriptions_EmailMarketingOptIn.SFCCRequest sfccReq = new Subscriptions_EmailMarketingOptIn.SFCCRequest();
        Subscriptions_EmailMarketingOptIn.SFCCResponse  sfccRes = new Subscriptions_EmailMarketingOptIn.SFCCResponse();
        sfccReq.firstName = 'TEST NAME1';
        sfccReq.lastName = 'TEST NAME2';
        sfccReq.brandId = '1';
        sfccReq.emailAddress ='test@yopemail.com';
        sfccReq.region = 'NA';
        sfccReq.country = 'CA';
        sfccReq.market = 'CA';
        sfccReq.sourceSystem = 'ecom';
        sfccReq.requestType = 'Subscribe';
        sfccReq.EmailOrgSource = 'WE_CHECKOUT';
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        String jsonMsg=JSON.serialize(sfccReq);
        req.requestURI = '/Subscriptions/EmailMarketingOptIn';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        sfccRes = Subscriptions_EmailMarketingOptIn.doSignup();
        Test.stopTest();
        System.assertEquals(res.statusCode, 200);
        System.assertEquals('OK', sfccRes.code);
        System.assertEquals('Success', sfccRes.message);
		Contact returnContact = [SELECT Id, WelcomeSource__c, EmailOrigSource__c FROM Contact WHERE Id =: sfccRes.Subscriberkey];
        System.assertEquals('24', returnContact.WelcomeSource__c);
    }
    
    @isTest static void testDoSignupWeFooter(){
        //Test for welcome sourse WE_FOOTER 
        Contact conRec = createContact();
        Subscriptions_EmailMarketingOptIn.SFCCRequest sfccReq = new Subscriptions_EmailMarketingOptIn.SFCCRequest();
        Subscriptions_EmailMarketingOptIn.SFCCResponse  sfccRes = new Subscriptions_EmailMarketingOptIn.SFCCResponse();
        sfccReq.firstName = 'TEST NAME1';
        sfccReq.lastName = 'TEST NAME2';
        sfccReq.brandId = '1';
        sfccReq.emailAddress ='test@yopemail.com';
        sfccReq.region = 'NA';
        sfccReq.country = 'CA';
        sfccReq.market = 'CA';
        sfccReq.sourceSystem = 'ecom';
        sfccReq.requestType = 'Subscribe';
        sfccReq.EmailOrgSource = 'WE_FOOTER';
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        String jsonMsg=JSON.serialize(sfccReq);
        req.requestURI = '/Subscriptions/EmailMarketingOptIn';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        sfccRes = Subscriptions_EmailMarketingOptIn.doSignup();
        Test.stopTest();
        System.assertEquals(res.statusCode, 200);
        System.assertEquals('OK', sfccRes.code);
        System.assertEquals('Success', sfccRes.message);
        Contact returnContact = [SELECT Id, WelcomeSource__c, EmailOrigSource__c FROM Contact WHERE Id =: sfccRes.Subscriberkey];
        System.assertEquals('02', returnContact.WelcomeSource__c);
    }
    
    @isTest static void testDoSignupUnSubscribe(){
        //Test for Email optin request for UnSubscribe
        Contact conRec = createContact();
        Subscriptions_EmailMarketingOptIn.SFCCRequest sfccReq = new Subscriptions_EmailMarketingOptIn.SFCCRequest();
        Subscriptions_EmailMarketingOptIn.SFCCResponse  sfccRes = new Subscriptions_EmailMarketingOptIn.SFCCResponse();
        sfccReq.firstName = 'TEST NAME1';
        sfccReq.lastName = 'TEST NAME2';
        sfccReq.brandId = '1';
        sfccReq.emailAddress ='test@yopemail.com';
        sfccReq.region = 'NA';
        sfccReq.country = 'CA';
        sfccReq.market = 'CA';
        sfccReq.sourceSystem = 'ecom';
        sfccReq.requestType = 'UnSubscribe';
        sfccReq.EmailOrgSource = 'WE_FOOTER';
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        String jsonMsg=JSON.serialize(sfccReq);
        req.requestURI = '/Subscriptions/EmailMarketingOptIn';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        sfccRes = Subscriptions_EmailMarketingOptIn.doSignup();
        Test.stopTest();
        System.assertEquals(res.statusCode, 200);
        System.assertEquals('OK', sfccRes.code);
        System.assertEquals('Success', sfccRes.message);
        Contact returnContact = [SELECT Id, HasOptedOutOfEmail, EmailOptOutDate__c FROM Contact WHERE Id =: sfccRes.Subscriberkey];
        System.assertEquals(true, returnContact.HasOptedOutOfEmail);
        System.assertEquals(System.today(), returnContact.EmailOptOutDate__c.date());
    }
    
    @isTest static void testDoSignupExistingContact(){
        //Test for existing contact signup
        Contact conRec = createContact();
        Subscriptions_EmailMarketingOptIn.SFCCRequest sfccReq = new Subscriptions_EmailMarketingOptIn.SFCCRequest();
        Subscriptions_EmailMarketingOptIn.SFCCResponse  sfccRes = new Subscriptions_EmailMarketingOptIn.SFCCResponse();
        sfccReq.firstName = 'TEST NAME1';
        sfccReq.lastName = 'TEST NAME2';
        sfccReq.brandId = '2';
        sfccReq.emailAddress ='testemail@nomail.com';
        sfccReq.region = 'NA';
        sfccReq.country = 'CA';
        sfccReq.market = 'CA';
        sfccReq.sourceSystem = 'ecom';
        sfccReq.requestType = 'Subscribe';
        sfccReq.EmailOrgSource = 'WE_OVERLAY';
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        String jsonMsg=JSON.serialize(sfccReq);
        req.requestURI = '/Subscriptions/EmailMarketingOptIn';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        sfccRes = Subscriptions_EmailMarketingOptIn.doSignup();
        Test.stopTest();
        System.assertEquals(res.statusCode, 200);
        System.assertEquals('OK', sfccRes.code);
        System.assertEquals('Success', sfccRes.message);
    }
    
    @isTest static void testDoSignupExistingBrandIdEmailNull(){
        //Test for checking response when Brand Id and Email are null in the request
        Contact conRec = createContact();
        Subscriptions_EmailMarketingOptIn.SFCCRequest sfccReq = new Subscriptions_EmailMarketingOptIn.SFCCRequest();
        Subscriptions_EmailMarketingOptIn.SFCCResponse  sfccRes = new Subscriptions_EmailMarketingOptIn.SFCCResponse();
        sfccReq.firstName = 'TEST NAME1';
        sfccReq.lastName = 'TEST NAME2';
        sfccReq.brandId = '';
        sfccReq.emailAddress ='';
        sfccReq.region = 'NA';
        sfccReq.country = 'CA';
        sfccReq.market = 'CA';
        sfccReq.sourceSystem = 'ecom';
        sfccReq.requestType = 'Subscribe';
        sfccReq.EmailOrgSource = 'WE_OVERLAY';
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        String jsonMsg=JSON.serialize(sfccReq);
        req.requestURI = '/Subscriptions/EmailMarketingOptIn';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        sfccRes = Subscriptions_EmailMarketingOptIn.doSignup();
        Test.stopTest();
        System.assertEquals(res.statusCode, 400);
        System.assertEquals('Missing required parameters:  BrandId or email or Region or Market or Country', sfccRes.message);
        System.assertEquals('INVALID_QUERY', sfccRes.code);
    }
    
    @isTest static void testDoSignupFirstNameLastNameNull(){
        //Test for updation of first name and last name when the relevent passed is null
        Subscriptions_EmailMarketingOptIn.SFCCRequest sfccReq = new Subscriptions_EmailMarketingOptIn.SFCCRequest();
        Subscriptions_EmailMarketingOptIn.SFCCResponse  sfccRes = new Subscriptions_EmailMarketingOptIn.SFCCResponse();
        sfccReq.firstName = '';
        sfccReq.lastName = '';
        sfccReq.brandId = '2';
        sfccReq.emailAddress ='testemail@nomail.com';
        sfccReq.region = 'NA';
        sfccReq.country = 'CA';
        sfccReq.market = 'CA';
        sfccReq.sourceSystem = 'ecom';
        sfccReq.requestType = 'Subscribe';
        sfccReq.EmailOrgSource = 'WE_OVERLAY';
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        String jsonMsg=JSON.serialize(sfccReq);
        req.requestURI = '/Subscriptions/EmailMarketingOptIn';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        sfccRes = Subscriptions_EmailMarketingOptIn.doSignup();
        Test.stopTest();
        System.assertEquals(res.statusCode, 200);
        Contact returnContact = [SELECT Id, FirstName, LastName FROM Contact WHERE Id =: sfccRes.Subscriberkey];
        System.assertEquals('Unknown', returnContact.FirstName);
        System.assertEquals('Unknown', returnContact.LastName);
        System.assertEquals('OK', sfccRes.code);
        System.assertEquals('Success', sfccRes.message);
    }
    
    @isTest static void testDoSignupExistingContactOptinTrue(){
        //Test for existing contact optin already false
        Contact conRec = createContact2();
        Subscriptions_EmailMarketingOptIn.SFCCRequest sfccReq = new Subscriptions_EmailMarketingOptIn.SFCCRequest();
        Subscriptions_EmailMarketingOptIn.SFCCResponse  sfccRes = new Subscriptions_EmailMarketingOptIn.SFCCResponse();
        sfccReq.firstName = 'TEST NAME1';
        sfccReq.lastName = 'TEST NAME2';
        sfccReq.brandId = '2';
        sfccReq.emailAddress ='testemail@nomail.com';
        sfccReq.region = 'NA';
        sfccReq.country = 'CA';
        sfccReq.market = 'CA';
        sfccReq.sourceSystem = 'ecom';
        sfccReq.requestType = 'Subscribe';
        sfccReq.EmailOrgSource = 'WE_OVERLAY';
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        String jsonMsg=JSON.serialize(sfccReq);
        req.requestURI = '/Subscriptions/EmailMarketingOptIn';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        sfccRes = Subscriptions_EmailMarketingOptIn.doSignup();
        Test.stopTest();
        System.assertEquals(res.statusCode, 200);
        System.assertEquals('false', sfccRes.NewsLetterAlreadySignedUp);
        System.assertEquals('OK', sfccRes.code);
        System.assertEquals('Success', sfccRes.message);
    }
}