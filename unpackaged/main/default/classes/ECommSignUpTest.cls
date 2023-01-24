@isTest
private class ECommSignUpTest {
    
    private static void testdata1(){
        //Test Data for account and contact
        //Not used test setup as some method don't need existing account and contact data
        Account acc = new Account(Name=System.Label.PlaceHolderAccountName);
        String recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId();
        insert acc;
        
        Contact con = new Contact();
        con.RecordTypeId = recordTypeId;
        con.Source_System__c = 'eComm';
        con.AccountId = acc.Id;
        con.Brand_Id__c = '1';
        con.FirstName = 'cfname';
        con.LastName = 'clname';
        con.MailingStreet = 'c mailing scteet';
        con.MailingCity = 'ccity';
        con.MailingState = 'cstate';
        con.MailingPostalCode = 'c1234';
        con.MailingCountry = 'ccity';
        con.Email = 'testemail@nomail.com';
        con.Phone = '5555555555';
        con.HomePhone = '0987654321';
        con.MobilePhone = '7777777775';
        con.Birthdate = Date.newInstance(1990, 12, 30);       
        con.HomeStore__c = 'cLoc';
        con.LoyaltyFlag__c = false;
        con.EmailOptInStatus__c = 'N'; //false;
        con.SMSOptinStatus__c = 'N'; //false;
        con.WelcomeSource__c = '01';
		con.StoreOfCapture__c = 'cLoc';
        
        insert con;
        
        
        //Same contact record for Brand 2
        Contact con1 = new Contact();
        con1.RecordTypeId = recordTypeId ;
        con1.Source_System__c = 'eComm';
        con1.AccountId = acc.Id;
        con1.Brand_Id__c = '9';
        con1.FirstName = 'cfname';
        con1.LastName = 'clname';
        con1.MailingStreet = 'c mailing scteet';
        con1.MailingCity = 'ccity';
        con1.MailingState = 'cstate';
        con1.MailingPostalCode = 'c1234';
        con1.MailingCountry = 'ccity';
        con1.Email = 'testemai2@nomail.com';
        con1.Phone = '8473849384';
        con1.HomePhone = '0987654321';
        con1.MobilePhone = '2375838483';
        con1.Birthdate = Date.newInstance(1990, 12, 30);
        con1.HomeStore__c = 'cLoc';
        con1.LoyaltyFlag__c = false;
        con1.EmailOptInStatus__c = 'N'; //false;
        con1.SMSOptinStatus__c = 'Y'; //true;
        con1.WelcomeSource__c = '02';
        con1.StoreOfCapture__c = 'cLoc';
        
        insert con1;
           
    }
    
    private static void testdata2(){
        Account acc = new Account(Name=System.Label.PlaceHolderAccountName);
        String recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId();
        insert acc;
        
        Contact con4 = new Contact();
        con4.RecordTypeId = recordTypeId;
        con4.Source_System__c = 'eComm';
        con4.AccountId = acc.Id;
        con4.Brand_Id__c = '81';
        con4.FirstName = 'cfname';
        con4.LastName = 'clname';
        con4.MailingStreet = 'c mailing scteet';
        con4.MailingCity = 'ccity';
        con4.MailingState = 'cstate';
        con4.MailingPostalCode = 'c1234';
        con4.MailingCountry = 'ccity';
        con4.Email = 'testemail4@nomail.com';
        con4.Phone = '5555555555';
        con4.HomePhone = '0987654321';
        con4.MobilePhone = '7777777775';
        con4.Birthdate = Date.newInstance(1990, 12, 30);
        con4.LoyaltyID__c = 'E00000000000';   
        con4.HomeStore__c = 'cLoc';
        con4.LoyaltyFlag__c = false;
        con4.EmailOptInStatus__c = 'N'; //false;
        con4.SMSOptinStatus__c = 'N'; //false;
        con4.Source_System__c = 'eComm';
        con4.WelcomeSource__c = '04';
        con4.StoreOfCapture__c = 'cLoc';
        insert con4; 
    }
    
    private static void testdata3(){
        Account acc = new Account(Name=System.Label.PlaceHolderAccountName);
        String recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId();
        insert acc;
        
        Contact con4 = new Contact();
        con4.RecordTypeId = recordTypeId;
        con4.Source_System__c = 'eComm';
        con4.AccountId = acc.Id;
        con4.Brand_Id__c = '9';
        con4.FirstName = 'cfname';
        con4.LastName = 'clname';
        con4.MailingStreet = 'c mailing scteet';
        con4.MailingCity = 'ccity';
        con4.MailingState = 'cstate';
        con4.MailingPostalCode = 'c1234';
        con4.MailingCountry = 'ccity';
        con4.Email = 'testemail4@nomail.com';
        con4.Phone = '5555555555';
        con4.HomePhone = '0987654321';
        con4.MobilePhone = '7777777775';
        con4.Birthdate = Date.newInstance(1990, 12, 30);
        con4.LoyaltyID__c = 'E00000000000';   
        con4.HomeStore__c = 'cLoc';
        con4.LoyaltyFlag__c = false;
        con4.EmailOptInStatus__c = 'Y'; //false;
        con4.SMSOptinStatus__c = 'N'; //false;
        con4.Source_System__c = 'eComm';
        con4.WelcomeSource__c = '04';
        con4.StoreOfCapture__c = 'cLoc';
        insert con4; 
        
        Contact con5 = new Contact();
        con5.RecordTypeId = recordTypeId;
        con5.Source_System__c = 'eComm';
        con5.AccountId = acc.Id;
        con5.Brand_Id__c = '9';
        con5.FirstName = 'cfname';
        con5.LastName = 'clname';
        con5.MailingStreet = 'c mailing scteet';
        con5.MailingCity = 'ccity';
        con5.MailingState = 'cstate';
        con5.MailingPostalCode = 'c1234';
        con5.MailingCountry = 'ccity';
        con5.Email = 'testemail5@nomail.com';
        con5.Phone = '5555555555';
        con5.HomePhone = '0987654321';
        con5.MobilePhone = '7777777775';
        con5.Birthdate = Date.newInstance(1990, 12, 30);
        con5.LoyaltyID__c = 'E00000000000';   
        con5.HomeStore__c = 'cLoc';
        con5.LoyaltyFlag__c = false;
        con5.EmailOptInStatus__c = 'Y'; //false;
        con5.SMSOptinStatus__c = 'N'; //false;
        con5.Source_System__c = 'eComm';
        con5.WelcomeSource__c = '04';
        con5.StoreOfCapture__c = 'cLoc';
        insert con5;
    }
    
    @isTest static void testdoSignup1(){
        //Test for Brand id or email not present in request
        ECommSignUp.EcomRequest ecomReq = new ECommSignUp.EcomRequest();
        ECommSignUp.ECommResponse ecomRes = new ECommSignUp.ECommResponse();
        
        ecomReq.brandId = '2';
        ecomReq.emailAddress ='';
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String JsonMsg=JSON.serialize(ecomReq);
        
        req.requestURI = '/services/apexrest/subscriber/SignUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        ecomRes = ECommSignUp.doSignup();
        System.debug(ecomRes);
        System.assertEquals(res.statusCode, 400);
        System.assertEquals('Missing required parameters:  BrandId or email', ecomRes.message);
        System.assertEquals('INVALID_QUERY', ecomRes.code);
        Test.stopTest();
    } 
    
    @isTest static void testdoSignup2(){
        //Test for Contact not existing in the System BrandID 1.
        ECommSignUp.EcomRequest ecomReq = new ECommSignUp.EcomRequest();
        ECommSignUp.ECommResponse ecomRes = new ECommSignUp.ECommResponse();
        ecomReq.brandId = '1';
        ecomReq.firstName = 'fname'; 
        ecomReq.lastName = 'lname';
        ecomReq.addressLine1 = 'address 1 abc';
        ecomReq.addressLine2 = 'address 2 xyz'; 
        ecomReq.city = 'testcity';
        ecomReq.state = 'teststate'; 
        ecomReq.zip = 'c1234';
        ecomReq.country = 'testcountry';
        ecomReq.emailAddress = 'testemail@nomail.com';
        ecomReq.phoneNumber = '5555555555';        
        ecomReq.homePhoneNumber = '1234567890';
        ecomReq.mobilePhoneNumber = '7777777775';
        ecomReq.birthMonth = '01';
        ecomReq.birthDay = '02';
        ecomReq.birthYear = '2001'; 
        ecomReq.gender = 'Male';                          
        ecomReq.location = '123 Location';
        ecomReq.loyaltySignup = 'true';
        ecomReq.emailOptIn = 'true';
        ecomReq.smsOptIn = 'true';
        ecomReq.smsOptInFrequency = 'Weekly';
        ecomReq.sourceSystem = 'eComm';
        ecomReq.WelcomeSource = '02';
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String JsonMsg=JSON.serialize(ecomReq);
        
        req.requestURI = '/services/apexrest/subscriber/SignUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        ecomRes = ECommSignUp.doSignup();
        System.debug(ecomRes);
        
        Contact con = [SELECT Id,LoyaltyID__c FROM Contact Limit 1];
        
        System.assertEquals(con.Id, ecomRes.ContactId);
        System.assertEquals(200,res.statusCode);
        System.assert(con.LoyaltyID__c!=Null);
        System.assertEquals('false', ecomRes.ExistingCustomer);
        System.assertEquals('false', ecomRes.NewsLetterAlreadySignedUp);
        
        Test.stopTest();
    }
    
    @isTest static void testdoSignup3(){
        //Test for Contact not existing in the System BrandID 2.
        ECommSignUp.EcomRequest ecomReq = new ECommSignUp.EcomRequest();
        ECommSignUp.ECommResponse ecomRes = new ECommSignUp.ECommResponse();
 
        ecomReq.brandId = '2';
        ecomReq.firstName = 'fname'; 
        ecomReq.lastName = 'lname';
        ecomReq.addressLine1 = 'address 1 abc';
        ecomReq.addressLine2 = 'address 2 xyz'; 
        ecomReq.city = 'testcity';
        ecomReq.state = 'teststate'; 
        ecomReq.zip = 'c1234';
        ecomReq.country = 'testcountry';
        ecomReq.emailAddress = 'testemail@nomail.com';
        ecomReq.phoneNumber = '5555555555';        
        ecomReq.homePhoneNumber = '1234567890';
        ecomReq.mobilePhoneNumber = '7777777775';
        ecomReq.birthMonth = '01';
        ecomReq.birthDay = '02';
        ecomReq.birthYear = '2001'; 
        ecomReq.gender = 'Male';                          
        ecomReq.location = '123 Location';
        ecomReq.loyaltySignup = 'true';
        ecomReq.emailOptIn = 'true';
        ecomReq.smsOptIn = 'true';
        ecomReq.smsOptInFrequency = 'Weekly';
        ecomReq.sourceSystem = 'eComm';
        ecomReq.WelcomeSource = '01';
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String JsonMsg = JSON.serialize(ecomReq);
        
        req.requestURI = '/services/apexrest/subscriber/SignUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        ecomRes = ECommSignUp.doSignup();
        System.debug(ecomRes);
        
        Contact con = [SELECT Id,LoyaltyID__c FROM Contact WHERE Email='testemail@nomail.com' Limit 1];
        
        System.assertEquals(200,res.statusCode);
        System.assertEquals(con.Id, ecomRes.ContactId);
        System.assert(con.LoyaltyID__c!=Null);
        System.assertEquals('false', ecomRes.ExistingCustomer);
        System.assertEquals('false', ecomRes.NewsLetterAlreadySignedUp);
        Test.stopTest();
    }
    
    @isTest static void testdoSignup4(){
        
        //Test for Contact not existing in the System BrandID 9 with no sub brand .
        ECommSignUp.EcomRequest ecomReq = new ECommSignUp.EcomRequest();
        ECommSignUp.ECommResponse ecomRes = new ECommSignUp.ECommResponse();
        
        ecomReq.brandId = '9';
        ecomReq.firstName = 'fname'; 
        ecomReq.lastName = 'lname';
        ecomReq.addressLine1 = 'address 1 abc';
        ecomReq.addressLine2 = 'address 2 xyz'; 
        ecomReq.city = 'testcity';
        ecomReq.state = 'teststate'; 
        ecomReq.zip = 'c1234';
        ecomReq.country = 'testcountry';
        ecomReq.emailAddress = 'testemail@nomail.com';
        ecomReq.phoneNumber = '5555555555';        
        ecomReq.homePhoneNumber = '1234567890';
        ecomReq.mobilePhoneNumber = '7777777775';
        ecomReq.birthMonth = '01';
        ecomReq.birthDay = '02';
        ecomReq.birthYear = '2001'; 
        ecomReq.gender = 'Male';                          
        ecomReq.location = '123 Location';
        ecomReq.loyaltySignup = 'true';
        ecomReq.emailOptIn = 'true';
        ecomReq.smsOptIn = 'true';
        ecomReq.smsOptInFrequency = 'Weekly';
        ecomReq.sourceSystem = 'eComm';
        ecomReq.WelcomeSource = '01';
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String JsonMsg = JSON.serialize(ecomReq);
        
        req.requestURI = '/services/apexrest/subscriber/SignUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        ecomRes = ECommSignUp.doSignup();
        System.debug(ecomRes);
        
        list<Contact> con = [SELECT Id, LoyaltyID__c FROM Contact WHERE Email='testemail@nomail.com'];
        System.debug('con:'+con);
        System.assert(con.size()>0);
        System.assertEquals(200,res.statusCode);
       // System.assertEquals(con[0].Id, ecomRes.ContactId);
        System.assert(con[0].LoyaltyID__c!=Null);
        System.assertEquals('false', ecomRes.ExistingCustomer);
        System.assertEquals('false', ecomRes.NewsLetterAlreadySignedUp);
        Test.stopTest();
    }
    
    @isTest static void testdoSignup5(){
        //Test for Contact not existing in the System BrandID 9 with one sub brands present .
        ECommSignUp.EcomRequest ecomReq = new ECommSignUp.EcomRequest();
        ECommSignUp.ECommResponse ecomRes = new ECommSignUp.ECommResponse();
            
        ecomReq.brandId = '9';
        ecomReq.firstName = 'fname'; 
        ecomReq.lastName = 'lname';
        ecomReq.addressLine1 = 'address 1 abc';
        ecomReq.addressLine2 = 'address 2 xyz'; 
        ecomReq.city = 'testcity';
        ecomReq.state = 'teststate'; 
        ecomReq.zip = 'c1234';
        ecomReq.country = 'testcountry';
        ecomReq.emailAddress = 'testemail@nomail.com';
        ecomReq.phoneNumber = '5555555555';        
        ecomReq.homePhoneNumber = '1234567890';
        ecomReq.mobilePhoneNumber = '7777777775';
        ecomReq.birthMonth = '01';
        ecomReq.birthDay = '02';
        ecomReq.birthYear = '2001'; 
        ecomReq.gender = 'Male';                          
        ecomReq.location = '123 Location';
        ecomReq.loyaltySignup = 'true';
        ecomReq.emailOptIn = 'true';
        ecomReq.smsOptIn = 'true';
        ecomReq.smsOptInFrequency = 'Weekly';
        ecomReq.sourceSystem = 'eComm';
        ecomReq.WelcomeSource = '01';
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String JsonMsg = JSON.serialize(ecomReq);
        
        req.requestURI = '/services/apexrest/subscriber/SignUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        ecomRes = ECommSignUp.doSignup();
        System.debug(ecomRes);
        
        list<Contact> con = [SELECT Id, LoyaltyID__c FROM Contact WHERE Email='testemail@nomail.com'];
        System.assert(con.size()>1);
        System.assertEquals(200,res.statusCode);
       // System.assertEquals(con[0].Id, ecomRes.ContactId);
        System.assert(con[0].LoyaltyID__c!=Null);
        System.assertEquals('false', ecomRes.ExistingCustomer);
        System.assertEquals('false', ecomRes.NewsLetterAlreadySignedUp);
        Test.stopTest();
    }
    
    @isTest static void testdoSignup6(){
        //Test for Contact not existing in the System BrandID 9 with multiple sub brands present .
        ECommSignUp.EcomRequest ecomReq = new ECommSignUp.EcomRequest();
        ECommSignUp.ECommResponse ecomRes = new ECommSignUp.ECommResponse();
        ecomReq.brandId = '9';
        ecomReq.firstName = 'fname'; 
        ecomReq.lastName = 'lname';
        ecomReq.addressLine1 = 'address 1 abc';
        ecomReq.addressLine2 = 'address 2 xyz'; 
        ecomReq.city = 'testcity';
        ecomReq.state = 'teststate'; 
        ecomReq.zip = 'c1234';
        ecomReq.country = 'testcountry';
        ecomReq.emailAddress = 'testemail@nomail.com';
        ecomReq.phoneNumber = '5555555555';        
        ecomReq.homePhoneNumber = '1234567890';
        ecomReq.mobilePhoneNumber = '7777777775';
        ecomReq.birthMonth = '01';
        ecomReq.birthDay = '02';
        ecomReq.birthYear = '2001'; 
        ecomReq.gender = 'Male';                          
        ecomReq.location = '123 Location';
        ecomReq.loyaltySignup = 'true';
        ecomReq.emailOptIn = 'true';
        ecomReq.smsOptIn = 'true';
        ecomReq.smsOptInFrequency = 'Weekly';
        ecomReq.sourceSystem = 'eComm';
        ecomReq.WelcomeSource = '01';
        
        System.debug(ecomReq);
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String JsonMsg = JSON.serialize(ecomReq);
        
        req.requestURI = '/services/apexrest/subscriber/SignUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        ecomRes = ECommSignUp.doSignup();
        System.debug(ecomRes);
        
        list<Contact> con = [SELECT Id, LoyaltyID__c FROM Contact WHERE Email='testemail@nomail.com'];
        System.assert(con.size()>1);
        System.assertEquals(200,res.statusCode);
        //System.assertEquals(con[0].Id, ecomRes.ContactId);
        System.assert(con[0].LoyaltyID__c!=Null);
        System.assertEquals('false', ecomRes.ExistingCustomer);
        System.assertEquals('false', ecomRes.NewsLetterAlreadySignedUp);
        Test.stopTest();
    }
    
    @isTest static void testdoSignup7(){
        //Test for Contact existing in the System BrandID 9 with multiple sub brands present .
        testdata1();
        list<Contact> con2 = [SELECT Id, LoyaltyID__c FROM Contact WHERE Email='testemai2@nomail.com'];
        System.debug('con2 size:'+con2);
        ECommSignUp.EcomRequest ecomReq = new ECommSignUp.EcomRequest();
        ECommSignUp.ECommResponse ecomRes = new ECommSignUp.ECommResponse();
          
        ecomReq.brandId = '9';
        ecomReq.firstName = 'fname'; 
        ecomReq.lastName = 'lname';
        ecomReq.addressLine1 = 'address 1 abc';
        ecomReq.addressLine2 = 'address 2 xyz'; 
        ecomReq.city = 'testcity';
        ecomReq.state = 'teststate'; 
        ecomReq.zip = 'c1234';
        ecomReq.country = 'testcountry';
        ecomReq.emailAddress = 'testemail1@nomail.com';
        ecomReq.phoneNumber = '5555555555';        
        ecomReq.homePhoneNumber = '1234567890';
        ecomReq.mobilePhoneNumber = '7777777775';
        ecomReq.birthMonth = '01';
        ecomReq.birthDay = '02';
        ecomReq.birthYear = '2001'; 
        ecomReq.gender = 'Male';                          
        ecomReq.location = '123 Location';
        ecomReq.loyaltySignup = 'true';
        ecomReq.emailOptIn = 'true';
        ecomReq.smsOptIn = 'true';
        ecomReq.smsOptInFrequency = 'Weekly';
        ecomReq.sourceSystem = 'eComm';
        ecomReq.WelcomeSource = '03';
        
        System.debug(ecomReq);
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String JsonMsg = JSON.serialize(ecomReq);
        
        req.requestURI = '/services/apexrest/subscriber/SignUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        ecomRes = ECommSignUp.doSignup();
        System.debug(ecomRes);
        
        list<Contact> con = [SELECT Id, LoyaltyID__c FROM Contact WHERE Email='testemai2@nomail.com'];
        System.assert(con.size()>0);
        System.assertEquals(200,res.statusCode);
        System.assert(con[0].LoyaltyID__c!=Null);
        //System.assertEquals('false', ecomRes.ExistingCustomer);
        System.assertEquals('false', ecomRes.NewsLetterAlreadySignedUp);
        Test.stopTest();
    }
    
    @isTest static void testdoSignup8(){
        //Test for existing Contact in the System BrandID 1 .
        testdata1();
        ECommSignUp.EcomRequest ecomReq = new ECommSignUp.EcomRequest();
        ECommSignUp.ECommResponse ecomRes = new ECommSignUp.ECommResponse();
        //List<ECommSignUp.subBrands> subBrands = new List<ECommSignUp.subBrands>();
        
        ecomReq.brandId = '1';
        ecomReq.firstName = 'fname'; 
        ecomReq.lastName = 'lname';
        ecomReq.addressLine1 = 'address 1 abc';
        ecomReq.addressLine2 = 'address 2 xyz'; 
        ecomReq.city = 'testcity';
        ecomReq.state = 'teststate'; 
        ecomReq.zip = 'c1234';
        ecomReq.country = 'testcountry';
        ecomReq.emailAddress = 'testemail@nomail.com';
        ecomReq.phoneNumber = '5555555555';        
        ecomReq.homePhoneNumber = '1234567890';
        ecomReq.mobilePhoneNumber = '7777777775';
        ecomReq.birthMonth = '01';
        ecomReq.birthDay = '02';
        ecomReq.birthYear = ''; 
        ecomReq.gender = 'Male';                          
        ecomReq.location = '123 Location';
        ecomReq.loyaltySignup = 'true';
        ecomReq.emailOptIn = 'true';
        ecomReq.smsOptIn = 'true';
        ecomReq.smsOptInFrequency = 'Weekly';
        ecomReq.sourceSystem = 'eComm';
        ecomReq.WelcomeSource = '02';
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String JsonMsg = JSON.serialize(ecomReq);
        
        req.requestURI = '/services/apexrest/subscriber/SignUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        ecomRes = ECommSignUp.doSignup();
        System.debug(ecomRes);
        
        list<Contact> con = [SELECT Id, LoyaltyID__c FROM Contact WHERE Email='testemail@nomail.com'AND Brand_Id__c = '1'];
        System.assert(con.size()==1);
        System.assertEquals(200,res.statusCode);
        System.assertEquals(con[0].Id, ecomRes.ContactId);
        System.assert(con[0].LoyaltyID__c!=Null);
        System.assertEquals('true', ecomRes.ExistingCustomer);
        System.assertEquals('false', ecomRes.NewsLetterAlreadySignedUp);
        System.assertEquals('false', ecomRes.LoyaltyAlreadySignedUp);


        req = new RestRequest();
        res = new RestResponse();

        JsonMsg = JSON.serialize(ecomReq);

        req.requestURI = '/services/apexrest/subscriber/SignUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;

        ecomRes = ECommSignUp.doSignup();
        System.debug(ecomRes);

        con = [SELECT Id, LoyaltyID__c FROM Contact WHERE Email='testemail@nomail.com'AND Brand_Id__c = '1'];
        System.assert(con.size()==1);
        System.assertEquals('true', ecomRes.ExistingCustomer);
        //System.assertEquals('true', ecomRes.NewsLetterAlreadySignedUp);
        Test.stopTest();
    }
    
    @isTest static void testdoSignup9(){
        //Test for request with only email and brand details present
        ECommSignUp.EcomRequest ecomReq = new ECommSignUp.EcomRequest();
        ECommSignUp.ECommResponse ecomRes = new ECommSignUp.ECommResponse();
       // ECommSignUp.subBrands subBrand = new ECommSignUp.subBrands();
        
        ecomReq.brandId = '2';
        ecomReq.emailAddress = 'testemail10@nomail.com';
        ecomReq.emailOptIn = 'True';
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String JsonMsg=JSON.serialize(ecomReq);
        
        req.requestURI = '/services/apexrest/subscriber/SignUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        ecomRes = ECommSignUp.doSignup();
        System.debug(ecomRes);
        
        Contact con = [SELECT Id FROM Contact WHERE email='testemail10@nomail.com' Limit 1];
        
        
        System.assertEquals(con.Id, ecomRes.ContactId);
        System.assertEquals(200,res.statusCode);
        
        System.assertEquals('false', ecomRes.ExistingCustomer);
        System.assertEquals('false', ecomRes.NewsLetterAlreadySignedUp);
        
        Test.stopTest();
    } 
    
    @isTest static void testdoSignup10(){
        //Test for existing Contact in the System BrandID 81 contact existing .
        testdata2();
        
        ECommSignUp.EcomRequest ecomReq = new ECommSignUp.EcomRequest();
        ECommSignUp.ECommResponse ecomRes = new ECommSignUp.ECommResponse();
       //List<ECommSignUp.subBrands> subBrands = new List<ECommSignUp.subBrands>();
        
        ecomReq.brandId = '81';
        ecomReq.firstName = 'fname'; 
        ecomReq.lastName = 'lname';
        ecomReq.addressLine1 = 'address 1 abc';
        ecomReq.addressLine2 = 'address 2 xyz'; 
        ecomReq.city = 'testcity';
        ecomReq.state = 'teststate'; 
        ecomReq.zip = 'c1234';
        ecomReq.country = 'testcountry';
        ecomReq.emailAddress = 'testemail4@nomail.com';
        ecomReq.phoneNumber = '5555555555';        
        ecomReq.homePhoneNumber = '1234567890';
        ecomReq.mobilePhoneNumber = '7777777775';
        ecomReq.birthMonth = '';
        ecomReq.birthDay = '02';
        ecomReq.birthYear = '1981'; 
        ecomReq.gender = 'Male';                          
        ecomReq.location = '123 Location';
        ecomReq.loyaltySignup = 'false';
        ecomReq.emailOptIn = 'false';
        ecomReq.smsOptIn = 'false';
        ecomReq.smsOptInFrequency = 'Weekly';
        ecomReq.sourceSystem = 'eComm';
      	ecomReq.WelcomeSource = '02';
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        String JsonMsg = JSON.serialize(ecomReq);
        
        req.requestURI = '/services/apexrest/subscriber/SignUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        ecomRes = ECommSignUp.doSignup();
        System.debug(ecomRes);
        
        list<Contact> con = [SELECT Id, LoyaltyID__c FROM Contact WHERE Email='testemail4@nomail.com'];
        System.assert(con.size()==1);
        System.assertEquals(200,res.statusCode);
        System.assertEquals(con[0].Id, ecomRes.ContactId);
        System.assert(con[0].LoyaltyID__c!=Null);
        System.assertEquals('true', ecomRes.ExistingCustomer);
        System.assertEquals('false', ecomRes.NewsLetterAlreadySignedUp);
        Test.stopTest();
    }
    
    @isTest static void testdoSignup11(){
        //Test for existing Contact in the System BrandID 81 contact not existing.
        list<Contact> con1 = [SELECT Id, LoyaltyID__c FROM Contact WHERE Email='testemail4@nomail.com'];
        System.debug('con1 size'+con1.size());
        
        ECommSignUp.EcomRequest ecomReq = new ECommSignUp.EcomRequest();
        ECommSignUp.ECommResponse ecomRes = new ECommSignUp.ECommResponse();
       //List<ECommSignUp.subBrands> subBrands = new List<ECommSignUp.subBrands>();
        
        ecomReq.brandId = '81';
        ecomReq.firstName = 'fname'; 
        ecomReq.lastName = 'lname';
        ecomReq.addressLine1 = 'address 1 abc';
        ecomReq.addressLine2 = 'address 2 xyz'; 
        ecomReq.city = 'testcity';
        ecomReq.state = 'teststate'; 
        ecomReq.zip = 'c1234';
        ecomReq.country = 'testcountry';
        ecomReq.emailAddress = 'testemail4@nomail.com';
        ecomReq.phoneNumber = '5555555555';        
        ecomReq.homePhoneNumber = '1234567890';
        ecomReq.mobilePhoneNumber = '7777777775';
        ecomReq.birthMonth = '';
        ecomReq.birthDay = '02';
        ecomReq.birthYear = '1981'; 
        ecomReq.gender = 'Male';                          
        ecomReq.location = '123 Location';
        ecomReq.loyaltySignup = 'false';
        ecomReq.emailOptIn = 'false';
        ecomReq.smsOptIn = 'false';
        ecomReq.smsOptInFrequency = 'Weekly';
        ecomReq.sourceSystem = 'eComm';
        ecomReq.WelcomeSource = '02';
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        String JsonMsg = JSON.serialize(ecomReq);
        
        req.requestURI = '/services/apexrest/subscriber/SignUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        ecomRes = ECommSignUp.doSignup();
        System.debug(ecomRes);
        
        list<Contact> con = [SELECT Id, LoyaltyID__c FROM Contact WHERE Email='testemail4@nomail.com'];
        System.assert(con.size()>1);
        System.assertEquals(200,res.statusCode);
        System.assert(con[0].LoyaltyID__c == con[1].LoyaltyID__c);
        System.assert(con[0].LoyaltyID__c!=Null);
        System.assertEquals('false', ecomRes.ExistingCustomer);
        System.assertEquals('false', ecomRes.NewsLetterAlreadySignedUp);
        Test.stopTest();
    }
    
    @isTest static void testdoSignup12(){
        testdata3();
        //Test for Contact not existing in the System BrandID 9 with multiple sub brands present .
        ECommSignUp.EcomRequest ecomReq = new ECommSignUp.EcomRequest();
        ECommSignUp.ECommResponse ecomRes = new ECommSignUp.ECommResponse();
         
        ecomReq.brandId = '9';
        ecomReq.firstName = 'fname'; 
        ecomReq.lastName = 'lname';
        ecomReq.addressLine1 = 'address 1 abc';
        ecomReq.addressLine2 = 'address 2 xyz'; 
        ecomReq.city = 'testcity';
        ecomReq.state = 'teststate'; 
        ecomReq.zip = 'c1234';
        ecomReq.country = 'testcountry';
        ecomReq.emailAddress = 'testemail5@nomail.com';
        ecomReq.phoneNumber = '5555555555';        
        ecomReq.homePhoneNumber = '1234567890';
        ecomReq.mobilePhoneNumber = '7777777775';
        ecomReq.birthMonth = '10';
        ecomReq.birthDay = '12';
        ecomReq.birthYear = '1988'; 
        ecomReq.gender = 'Male';                          
        ecomReq.location = '123 Location';
        ecomReq.loyaltySignup = 'true';
        ecomReq.emailOptIn = 'true';
        ecomReq.smsOptIn = 'false';
        ecomReq.smsOptInFrequency = 'Weekly';
        ecomReq.sourceSystem = 'eComm';
        ecomReq.WelcomeSource = '02';
        
        System.debug(ecomReq);
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String JsonMsg = JSON.serialize(ecomReq);
        
        req.requestURI = '/services/apexrest/subscriber/SignUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        ecomRes = ECommSignUp.doSignup();
        System.debug(ecomRes);
        
        list<Contact> con = [SELECT Id, LoyaltyID__c FROM Contact WHERE Email='testemail5@nomail.com'];
        System.assert(con.size()>0);
        System.assertEquals(200,res.statusCode);
        System.assertEquals(con[0].Id, ecomRes.ContactId);
        System.assert(con[0].LoyaltyID__c!=Null);
        System.assertEquals('true', ecomRes.ExistingCustomer);
        System.assertEquals('true', ecomRes.NewsLetterAlreadySignedUp);
        Test.stopTest();
    }
    
    @isTest static void testdoSignup13(){
        testdata3();
       // Test for Contact existing in the System BrandID 9 with multiple sub brands present .
        ECommSignUp.EcomRequest ecomReq = new ECommSignUp.EcomRequest();
        ECommSignUp.ECommResponse ecomRes = new ECommSignUp.ECommResponse();
        
        ecomReq.brandId = '9';
        ecomReq.firstName = 'fname'; 
        ecomReq.lastName = 'lname';
        ecomReq.addressLine1 = 'address 1 abc';
        ecomReq.addressLine2 = 'address 2 xyz'; 
        ecomReq.city = 'testcity';
        ecomReq.state = 'teststate'; 
        ecomReq.zip = 'c1234';
        ecomReq.country = 'testcountry';
        ecomReq.emailAddress = 'testemail4@nomail.com';
        ecomReq.phoneNumber = '5555555555';        
        ecomReq.homePhoneNumber = '1234567890';
        ecomReq.mobilePhoneNumber = '7777777775';
        ecomReq.birthMonth = '';
        ecomReq.birthDay = '';
        ecomReq.birthYear = ''; 
        ecomReq.gender = 'Male';                          
        ecomReq.location = '123 Location';
        ecomReq.loyaltySignup = 'false';
        ecomReq.emailOptIn = 'false';
        ecomReq.smsOptIn = 'false';
        ecomReq.smsOptInFrequency = 'Weekly';
        ecomReq.sourceSystem = 'eComm';
        ecomReq.WelcomeSource = '02';
        
        System.debug(ecomReq);
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String JsonMsg = JSON.serialize(ecomReq);
        
        req.requestURI = '/services/apexrest/subscriber/SignUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        ecomRes = ECommSignUp.doSignup();
        System.debug(ecomRes);
        
        list<Contact> con = [SELECT Id, LoyaltyID__c FROM Contact WHERE Email='testemail4@nomail.com'];
        System.assert(con.size()>0);
        System.assertEquals(200,res.statusCode);
        System.assertEquals(con[0].Id, ecomRes.ContactId);
        System.assert(con[0].LoyaltyID__c!=Null);
        System.assertEquals('true', ecomRes.ExistingCustomer);
        System.assertEquals('true', ecomRes.NewsLetterAlreadySignedUp);
        Test.stopTest();
    }
    
}