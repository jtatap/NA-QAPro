@isTest
private class POSsignupTest {
    
    private static void testdata1(){
        //Test Data for account and contact
        //Not used test setup as some method don't need existing account and contact data
        Account acc = new Account(Name=System.Label.PlaceHolderAccountName);
        String recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId();
        insert acc;
        
        Contact con = new Contact();
        con.RecordTypeId = recordTypeId;
        con.Source_System__c = 'POS';
        con.AccountId = acc.Id;
        con.Brand_Id__c = '81';
        con.FirstName = 'cfname';
        con.LastName = 'clname';
        con.MailingStreet = 'c mailing street';
        con.MailingCity = 'ccity';
        con.MailingState = 'cstate';
        con.MailingPostalCode = 'c1234';
        con.MailingCountry = 'ccity';
        con.Email = 'testemail5@nomail.com';
        con.Phone = '5555555555';
        con.HomePhone = '0987654321';
        con.LoyaltyID__c='testing';
        con.MobilePhone = '7777777775';
        con.Birthdate = Date.newInstance(1990, 12, 30);       
        con.HomeStore__c = 'cLoc';
        con.LoyaltyFlag__c = false;
        con.EmailOptInStatus__c = 'N';
        con.EmailOptOutDate__c=system.now();//false;
        con.SMSOptinStatus__c = 'N'; //false;
        con.WelcomeSource__c = '01';
		con.StoreOfCapture__c = 'cLoc';
        
        insert con;
        
        
        //Same contact record for Brand 2
        Contact con1 = new Contact();
        con1.RecordTypeId = recordTypeId ;
        con1.Source_System__c = 'POS';
        con1.AccountId = acc.Id;
        con1.Brand_Id__c = '1';
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
           
        //Same contact record for Brand 2
        Contact con2 = new Contact();
        con2.RecordTypeId = recordTypeId ;
        con2.Source_System__c = 'POS';
        con2.AccountId = acc.Id;
        con2.Brand_Id__c = '9';
        con2.FirstName = 'cfname';
        con2.LastName = 'clname';
        con2.MailingStreet = 'c mailing scteet';
        con2.MailingCity = 'ccity';
        con2.MailingState = 'cstate';
        con2.MailingPostalCode = 'c1234';
        con2.MailingCountry = 'ccity';
        con2.Email = 'a@a.com';
        con2.Phone = '8473849384';
        con2.HomePhone = '0987654321';
        con2.MobilePhone = '2375838483';
        con2.Birthdate = Date.newInstance(1990, 12, 30);
        con2.HomeStore__c = 'cLoc';
        con2.LoyaltyFlag__c = false;
        con2.EmailOptInStatus__c = 'N'; //false;
        con2.SMSOptinStatus__c = 'Y'; //true;
        con2.WelcomeSource__c = '02';
        con2.StoreOfCapture__c = 'cLoc';
        
        insert con2;
    }
    
    private static void testdata2(){
        Account acc = new Account(Name=System.Label.PlaceHolderAccountName);
        String recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId();
        insert acc;
        
        Contact con3 = new Contact();
        con3.RecordTypeId = recordTypeId;
        con3.Source_System__c = 'POS';
        con3.AccountId = acc.Id;
        con3.Brand_Id__c = '81';
        con3.FirstName = 'cfname';
        con3.LastName = 'clname';
        con3.MailingStreet = 'c mailing scteet';
        con3.MailingCity = 'ccity';
        con3.MailingState = 'cstate';
        con3.MailingPostalCode = 'c1234';
        con3.MailingCountry = 'ccity';
        con3.Email = 'testemail3@nomail.com';
        con3.Phone = '5555555555';
        con3.LoyaltyID__c = 'E00000000000';   
        con3.HomeStore__c = 'cLoc';
        con3.LoyaltyFlag__c = false;
        con3.EmailOptInStatus__c = 'N'; //false;
        con3.Source_System__c = 'POS';
        con3.WelcomeSource__c = '04';
        con3.StoreOfCapture__c = 'cLoc';
        insert con3; 
    }
     @isTest static void testdoSignup1(){
        //Test for Brand id or email not present in request
        POSsignup.posRequest posReq = new POSsignup.posRequest();
        POSsignup.posResponse posRes = new POSsignup.posResponse();
        
        posReq.brandId = '1';
        posReq.emailAddress ='';
        posReq.lastName ='';
         
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String JsonMsg=JSON.serialize(posReq);
        
        req.requestURI = '/services/apexrest/posSubscriber/SignUp';  
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        posRes = POSsignup.doSignup();
        System.debug(posRes);
        System.assertEquals(res.statusCode, 400);
        System.assertEquals('Missing required parameters: BrandId or email or lastName', posRes.message);
        System.assertEquals('INVALID_QUERY', posRes.code);
        Test.stopTest();
    } 
     @isTest static void testdoSignup2(){
        //Test for Contact not existing in the System BrandID 1.
        POSsignup.posRequest posReq = new POSsignup.posRequest();
        POSsignup.posResponse posRes = new POSsignup.posResponse();
        
        posReq.brandId = '1';
        posReq.firstName = 'fname'; 
        posReq.lastName = 'lname';
        posReq.country = 'testcountry';
        posReq.emailAddress = 'testemail@nomail.com';
        posReq.emailOptIn = 'true';
        posReq.SourceSystem = 'POS';
        posReq.addressLine1 ='123 Main Street';
        posReq.addressLine2 = '';
        posReq.city= 'Albany';
        posReq.state='NY';
        posReq.zip='14810';
        posReq.country= 'US';
        posReq.phonenumber='9876567893';
        posReq.birthDate='';
        posReq.gender= 'Male';
        posReq.location='TH601';
        posReq.loyaltySignup='true';
    
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String JsonMsg=JSON.serialize(posReq);
        
        req.requestURI = '/services/apexrest/posSubscriber/SignUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        posRes = POSsignup.doSignup();
        System.debug(posRes);
        
        List<Contact> con = [SELECT Id,Email,LoyaltyId__c FROM Contact where Email='testemail@nomail.com' Limit 1];
        
       // System.assertEquals(con[0].Id, posRes.ContactId);
        System.assertEquals(200,res.statusCode);
       // System.assertEquals(con[0].LoyaltyId__c, posRes.LoyaltyId);
        
        
        Test.stopTest();
    }
    
     @isTest static void testdoSignup3(){
        //Test for Contact not existing in the System BrandID 81.
        POSsignup.posRequest posReq = new POSsignup.posRequest();
        POSsignup.posResponse posRes = new POSsignup.posResponse();
        
        posReq.brandId = '81';
        posReq.firstName = 'fname'; 
        posReq.lastName = 'lname';
        posReq.country = 'testcountry';
        posReq.emailAddress = 'testemail@nomail.com';
        posReq.emailOptIn = 'true';
        posReq.SourceSystem = 'POS';
        posReq.addressLine1 ='123 Main Street';
        posReq.addressLine2 = '';
        posReq.city= 'Albany';
        posReq.state='NY';
        posReq.zip='14810';
        posReq.country= 'US';
        posReq.phonenumber='9876567893';
        posReq.birthDate='';
        posReq.gender= 'Male';
        posReq.location='TH601';
        posReq.loyaltySignup='true';
    
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String JsonMsg=JSON.serialize(posReq);
        
        req.requestURI = '/services/apexrest/posSubscriber/SignUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        posRes = POSsignup.doSignup();
        System.debug(posRes);
        
        List<Contact> con = [SELECT Id,LoyaltyId__c,Email FROM Contact where Email='testemail@nomail.com' Limit 1];
        
        //System.assertEquals(con[0].Id, posRes.ContactId);
        System.assertEquals(200,res.statusCode);
        //System.assertEquals(con[0].LoyaltyId__c, posRes.LoyaltyId);
        
        
        Test.stopTest();
    }
     @isTest static void testdoSignup4(){
        //Test for Contact existing in the System BrandID 81.
        testdata1();
        list<Contact> con1 = [SELECT Id, LoyaltyID__c FROM Contact WHERE Email='testemail5@nomail.com'];
        System.debug('con1 size'+con1.size());
        system.debug('loyaltyId******'+con1[0].LoyaltyID__c);
        POSsignup.posRequest posReq = new POSsignup.posRequest();
        POSsignup.posResponse posRes = new POSsignup.posResponse();
        
        posReq.brandId = '81';
        posReq.firstName = 'fname'; 
        posReq.lastName = 'lname';
        posReq.country = 'testcountry';
        posReq.emailAddress = 'testemail5@nomail.com';
        posReq.emailOptIn = 'true';
        posReq.isemployee='true';
        posReq.SourceSystem = 'POS';
        posReq.addressLine1 ='123 Main Street';
        posReq.addressLine2 = '';
        posReq.city= 'Albany';
        posReq.state='NY';
        posReq.zip='14810';
        posReq.country= 'US';
        posReq.loyaltyId='Testing';
        posReq.phonenumber='9876567893';
        posReq.birthDate='';
        posReq.gender= 'Male';
        posReq.location='TH601';
        posReq.loyaltySignup='true';
    
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String JsonMsg=JSON.serialize(posReq);
        
        req.requestURI = '/services/apexrest/posSubscriber/SignUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        posRes = POSsignup.doSignup();
        System.debug(posRes);
        
       list<Contact> con = [SELECT Id,LoyaltyId__c FROM Contact where Email='testemail5@nomail.com' ];
        System.debug('con size'+con.size());
       // System.assertEquals(con[0].Id, posRes.ContactId);
        System.assertEquals(200,res.statusCode);
       // System.assertEquals(con[0].LoyaltyId__c, posRes.LoyaltyId);
        
        
        Test.stopTest();
    }
    
      @isTest static void testdoSignup5(){
        //Test for Contact existing in the System BrandID 81.
        testdata1();
        list<Contact> con1 = [SELECT Id, LoyaltyID__c FROM Contact WHERE Email='testemail5@nomail.com'];
        System.debug('con1 size'+con1.size());
        system.debug('loyaltyId******'+con1[0].LoyaltyID__c);
        POSsignup.posRequest posReq = new POSsignup.posRequest();
        POSsignup.posResponse posRes = new POSsignup.posResponse();
        
        posReq.brandId = '81';
        posReq.firstName = 'fname'; 
        posReq.lastName = 'lname';
        posReq.country = 'testcountry';
        posReq.emailAddress = 'testemail5@nomail.com';
        posReq.emailOptIn = 'false';
        posReq.isemployee='flase';
        posReq.SourceSystem = 'POS';
        posReq.addressLine1 ='123 Main Street';
        posReq.addressLine2 = '';
        posReq.city= 'Albany';
        posReq.state='NY';
        posReq.zip='14810';
        posReq.country= 'US';
        posReq.loyaltyId='Testing';
        posReq.phonenumber='9876567893';
        posReq.birthDate='';
        posReq.gender= 'Male';
        posReq.location='TH601';
        posReq.loyaltySignup='false';
    
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String JsonMsg=JSON.serialize(posReq);
        
        req.requestURI = '/services/apexrest/posSubscriber/SignUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        posRes = POSsignup.doSignup();
        System.debug(posRes);
        
       list<Contact> con = [SELECT Id,LoyaltyId__c FROM Contact where Email='testemail5@nomail.com' ];
        System.debug('con size'+con.size());
       // System.assertEquals(con[0].Id, posRes.ContactId);
        System.assertEquals(200,res.statusCode);
       // System.assertEquals(con[0].LoyaltyId__c, posRes.LoyaltyId);
        
        
        Test.stopTest();
    }
       @isTest static void testdoSignup6(){
        //Test for Contact existing in the System BrandID 81.
        testdata1();
        list<Contact> con2 = [SELECT Id, LoyaltyID__c FROM Contact WHERE Email='a@a.com'];
        System.debug('con2 size'+con2.size());
        system.debug('loyaltyId******'+con2[0].LoyaltyID__c);
        POSsignup.posRequest posReq = new POSsignup.posRequest();
        POSsignup.posResponse posRes = new POSsignup.posResponse();
        
        posReq.brandId = '1';
        posReq.firstName = 'fname'; 
        posReq.lastName = 'lname';
        posReq.country = 'testcountry';
        posReq.emailAddress = 'a@a.com';
        posReq.emailOptIn = 'false';
        posReq.isemployee='flase';
        posReq.SourceSystem = 'POS';
        posReq.addressLine1 ='123 Main Street';
        posReq.addressLine2 = '';
        posReq.city= 'Albany';
        posReq.state='NY';
        posReq.zip='14810';
        posReq.country= 'US';
        posReq.loyaltyId='';
        posReq.phonenumber='9876567893';
        posReq.birthDate='';
        posReq.gender= 'Male';
        posReq.location='TH601';
        posReq.loyaltySignup='false';
    
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String JsonMsg=JSON.serialize(posReq);
        
        req.requestURI = '/services/apexrest/posSubscriber/SignUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        posRes = POSsignup.doSignup();
        System.debug(posRes);
        
       list<Contact> con = [SELECT Id,LoyaltyId__c FROM Contact where Email='a@a.com' ];
        System.debug('con size'+con.size());
       // System.assertEquals(con[0].Id, posRes.ContactId);
        System.assertEquals(200,res.statusCode);
       // System.assertEquals(con[0].LoyaltyId__c, posRes.LoyaltyId);
        
        
        Test.stopTest();
    }
}