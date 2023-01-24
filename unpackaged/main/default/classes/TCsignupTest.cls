@isTest
private class TCsignupTest {
    
     private static void testdata1(){
          //Test Data for account and contact
        //Not used test setup as some method don't need existing account and contact data
        Account acc = new Account(Name=System.Label.PlaceHolderAccountName);
        String recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId();
        insert acc;
        
        Contact con = new Contact();
        con.RecordTypeId = recordTypeId;
        con.Source_System__c = 'TC';
        con.AccountId = acc.Id;
        con.Brand_Id__c = '11';
        con.FirstName = 'tcfname';
        con.LastName = 'tclname';
        con.MailingCountry = 'ccity';
        con.Email = 'testemail@nomail.com';
        con.EmailOptInStatus__c = 'N'; //false;
        con.WelcomeSource__c = '01';
        con.Latest_Source__c= 'cLoc';
        
        insert con;
        
     }
    
     @isTest static void testdoSignup1(){
        //Test for Brand id or email not present in request
        TCsignUp.TnCoRequest tcReq = new TCsignUp.TnCoRequest();
        TCsignUp.TnCoResponse tcRes = new TCsignUp.TnCoResponse();
        
        tcReq.brandId = '11';
        tcReq.emailAddress ='';
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String JsonMsg=JSON.serialize(tcReq);
        
        req.requestURI = '/services/apexrest/tcsubscriber/SignUp';  
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        tcRes = TCsignUp.doSignup();
        System.debug(tcRes);
        System.assertEquals(res.statusCode, 400);
        System.assertEquals('Missing required parameters:  BrandId or email', tcRes.message);
        System.assertEquals('INVALID_QUERY', tcRes.code);
        Test.stopTest();
    } 
    
    @isTest static void testdoSignup2(){
        //Test for Contact not existing in the System BrandID 11.
        TCsignUp.TnCoRequest tcReq = new TCsignUp.TnCoRequest();
        TCsignUp.TnCoResponse tcRes = new TCsignUp.TnCoResponse();
        
        tcReq.brandId = '11';
        tcReq.firstName = 'fname'; 
        tcReq.lastName = 'lname';
        tcReq.country = 'testcountry';
        tcReq.emailAddress = 'testemail@nomail.com';
        tcReq.emailOptIn = 'true';
        tcReq.SourceSystem = 'TC';
        tcReq.WelcomeSource = '01';
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String JsonMsg=JSON.serialize(tcReq);
        
        req.requestURI = '/services/apexrest/tcsubscriber/SignUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        tcRes = TCsignUp.doSignup();
        System.debug(tcRes);
        
        Contact con = [SELECT Id FROM Contact Limit 1];
        
        System.assertEquals(con.Id, tcRes.ContactId);
        System.assertEquals(200,res.statusCode);
        System.assertEquals('false', tcRes.ExistingCustomer);
        System.assertEquals('false', tcRes.NewsLetterAlreadySignedUp);
        
        Test.stopTest();
    }
    @isTest static void testdoSignup3(){
        //Test for Contact not existing in the System BrandID 11.
        TCsignUp.TnCoRequest tcReq = new TCsignUp.TnCoRequest();
        TCsignUp.TnCoResponse tcRes = new TCsignUp.TnCoResponse();
        
        tcReq.brandId = '11';
        tcReq.emailAddress = 'testemail@nomail.com';
        tcReq.emailOptIn = 'false';
        tcReq.WelcomeSource = '01';
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String JsonMsg=JSON.serialize(tcReq);
        
        req.requestURI = '/services/apexrest/tcsubscriber/SignUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        tcRes = TCsignUp.doSignup();
        System.debug(tcRes);
        
        Contact con = [SELECT Id FROM Contact Limit 1];
        
        System.assertEquals(con.Id, tcRes.ContactId);
        System.assertEquals(200,res.statusCode);
        System.assertEquals('false', tcRes.ExistingCustomer);
        System.assertEquals('false', tcRes.NewsLetterAlreadySignedUp);
        
        Test.stopTest();
    }
    
    
        @isTest static void testdoSignup8(){
        //Test for existing Contact in the System BrandID 11 .
        testdata1();
        TCsignUp.TnCoRequest tcReq = new TCsignUp.TnCoRequest();
        TCsignUp.TnCoResponse tcRes = new TCsignUp.TnCoResponse();
            
        tcReq.brandId = '11';
        tcReq.firstName = 'fname'; 
        tcReq.lastName = 'lname';
        tcReq.country = 'testcountry';
        tcReq.emailAddress = 'testemail@nomail.com';
        tcReq.emailOptIn = 'true';
        tcReq.SourceSystem = 'TC';
        tcReq.WelcomeSource = '01';
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String JsonMsg = JSON.serialize(tcReq);
        
        req.requestURI = '/services/apexrest/tcsubscriber/SignUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        tcRes = TCsignUp.doSignup();
        System.debug(tcRes);
        
        list<Contact> con = [SELECT Id FROM Contact WHERE Email='testemail@nomail.com'AND Brand_Id__c = '11'];
        System.assert(con.size()==1);
        System.assertEquals(200,res.statusCode);
        System.assertEquals(con[0].Id, tcRes.ContactId);
        System.assertEquals('true', tcRes.ExistingCustomer);
        //System.assertEquals('false', tcRes.NewsLetterAlreadySignedUp);
            
        req = new RestRequest();
        res = new RestResponse();

        JsonMsg = JSON.serialize(tcReq);

        req.requestURI = '/services/apexrest/tcsubscriber/SignUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;

        tcRes = TCsignUp.doSignup();
        System.debug(tcRes);

        con = [SELECT Id FROM Contact WHERE Email='testemail@nomail.com'AND Brand_Id__c = '11'];
        System.assert(con.size()==1);
        System.assertEquals('true', tcRes.ExistingCustomer);
        System.assertEquals('true', tcRes.NewsLetterAlreadySignedUp);
        Test.stopTest();
    }

}