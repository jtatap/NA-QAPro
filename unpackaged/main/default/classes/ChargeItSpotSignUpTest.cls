@isTest
private class ChargeItSpotSignUpTest {

    
    private static void testdata1(){
        //Test Data for account and contact
        //Not used test setup as some method don't need existing account and contact data
        Account acc = new Account(Name=System.Label.PlaceHolderAccountName);
        insert acc;
        
        Contact con = new Contact();
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId();
        con.Source_System__c = 'ChargeItSpot';
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
        con.HomePhone = '0987654321';
        con.Birthdate = Date.newInstance(1990, 12, 30);
        con.StoreOfCapture__c = 'cLoc';
        con.HomeStore__c = 'cLoc';
        con.EmailOptInStatus__c = 'N'; //false;
        con.SMSOptinStatus__c = 'N'; //false;
        insert con;
        
        //Same contact record for Brand 81
        Contact con1 = new Contact();
        con1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId();
        con1.Source_System__c = 'ChargeItSpot';
        con1.AccountId = acc.Id;
        con1.Brand_Id__c = '1';
        con1.FirstName = 'cfname';
        con1.LastName = 'clname';
        con1.MailingStreet = 'c mailing scteet';
        con1.MailingCity = 'ccity';
        con1.MailingState = 'cstate';
        con1.MailingPostalCode = 'c1234';
        con1.MailingCountry = 'ccity';
        con1.Email = 'testemail1@nomail.com';
        con1.HomePhone = '0987654321';
        con1.Birthdate = Date.newInstance(1991, 12, 30);
        con1.StoreOfCapture__c = 'cLoc';
        con1.HomeStore__c = 'cLoc';
        con1.LoyaltyFlag__c = false;
        con1.EmailOptInStatus__c = 'Y'; //true;
        con1.SMSOptinStatus__c = 'Y'; //true;
        insert con1;
        
    }
    
    
    //Method to generate X signature string from request body, user for test class only
    private static String generateXSignature(BLOB reqBody){
        string sharedSecret =  [SELECT Secret__c FROM SharedSecret__mdt WHERE DeveloperName = 'ChargeItSpot' LIMIT 1].Secret__c;
        system.debug('sharedSecret: ' + sharedSecret);
        
        Blob digest = Crypto.generateMac('hmacSHA1', reqBody, Blob.valueOf(sharedSecret));   
        system.debug('digest hex: ' +    EncodingUtil.convertToHex(digest));
        return EncodingUtil.convertToHex(digest);
    }
    
    //create Generic Contact
    private static Contact createTestData(){
        Account acc = new Account(Name=System.Label.PlaceHolderAccountName);
        insert acc;
        
        Contact con = new Contact();
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId();
        con.Source_System__c = 'ChargeItSpot';
        con.AccountId = acc.Id;
        con.Brand_Id__c = '1';
        con.FirstName = 'cfname';
        con.LastName = 'clname';
        con.MailingStreet = 'c mailing scteet';
        con.MailingCity = 'ccity';
        con.MailingState = 'cstate';
        con.MailingPostalCode = 'c1234';
        con.MailingCountry = 'ccity';
        //con.Email = 'testemail@nomail.com';
        con.HomePhone = '0987654321';
        con.Birthdate = Date.newInstance(1990, 12, 30);
        con.StoreOfCapture__c = 'cLoc';
        con.HomeStore__c = 'cLoc';
        //con.EmailOptInStatus__c = 'N'; //false;
        //con.SMSOptinStatus__c = 'N'; //false;
        //insert con;
        return con;
    }
    
    @isTest static void testdoSignup1(){
        
        //Test for Invalid/Missing Signature in Request header
        ChargeItSpotSignUp.ChargItReq ChargItReq = new ChargeItSpotSignUp.ChargItReq();
        ChargeItSpotSignUp.ChargeItResponse ChargItRes = new ChargeItSpotSignUp.ChargeItResponse();
        ChargeItSpotSignUp.context ctx = new ChargeItSpotSignUp.context();
        ChargeItSpotSignUp.library lib = new ChargeItSpotSignUp.library();
        ChargeItSpotSignUp.integration integ = new ChargeItSpotSignUp.integration();
        ChargeItSpotSignUp.trait trai = new ChargeItSpotSignUp.trait();
        
        ctx.locale = 'en_US';
        ctx.timezone = 'PST8PDT';
        
        lib.name = 'analytics-java';
        lib.version = 'analytics/2.0.0-RC3';        
        
        trai.brand = ' ';
        trai.email='testemail1@nomail.com';
        trai.emailOptin = 'true';
        trai.smsOptin = 'false';
        
        ChargItReq.context = ctx;
        ChargItReq.context.library = lib;
        ChargItReq.integrations = integ;        
        ChargItReq.messageId = '52b3947f-23bc-4454-96e6-f33bcbf920ae';
        ChargItReq.timestamp = '2018-08-08T14:29:33.795Z';
        ChargItReq.traits = trai;
        ChargItReq.type= 'identify';
        ChargItReq.userId = '7785551212';
        ChargItReq.writeKey = 'somewritekey';
        ChargItReq.receivedAt = '2018-08-08T14:29:37.795Z';
        ChargItReq.sentAt = '2018-08-08T14:29:37.000Z';
        ChargItReq.originalTimestamp = '2018-08-08T14:29:33+0000';
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String JsonMsg=JSON.serialize(ChargItReq);
        
        req.requestURI = '/services/apexrest/ChargeItSpot/SignUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        String xsig = generateXSignature(req.requestBody);
        //System.debug('xsig: '+xsig);
        req.addHeader('X-Signature', ''); //Not passing xsig to fail authentication
        RestContext.request = req;
        RestContext.response= res;
        
        ChargItRes = ChargeItSpotSignUp.doSignup();
        //System.debug(ChargItRes);
   //     System.assertEquals(res.statusCode, 400);
    //    System.assertEquals('Incorrect shared secret', ChargItRes.message);
    //    System.assertEquals('AUTHENTICATION_FAILED', ChargItRes.code); 
        Test.stopTest();
    }
    
    @isTest static void testdoSignup2(){
        //testdata1();
        
        //Test for Brand id or email not present in request
        ChargeItSpotSignUp.ChargItReq ChargItReq = new ChargeItSpotSignUp.ChargItReq();
        ChargeItSpotSignUp.ChargeItResponse ChargItRes = new ChargeItSpotSignUp.ChargeItResponse();
        ChargeItSpotSignUp.context ctx = new ChargeItSpotSignUp.context();
        ChargeItSpotSignUp.library lib = new ChargeItSpotSignUp.library();
        ChargeItSpotSignUp.integration integ = new ChargeItSpotSignUp.integration();
        ChargeItSpotSignUp.trait trai = new ChargeItSpotSignUp.trait();
        
        ctx.locale = 'en_US';
        ctx.timezone = 'PST8PDT';
        
        lib.name = 'analytics-java';
        lib.version = 'analytics/2.0.0-RC3';        
        
        trai.brand = '';
        trai.email='testemail1@nomail.com';        
        
        ChargItReq.context = ctx;
        ChargItReq.context.library = lib;
        ChargItReq.integrations = integ;        
        ChargItReq.messageId = '52b3947f-23bc-4454-96e6-f33bcbf920ae';
        ChargItReq.timestamp = '2018-08-08T14:29:33.795Z';
        ChargItReq.traits = trai;
        ChargItReq.type= 'identify';
        ChargItReq.userId = '7785551212';
        ChargItReq.writeKey = 'somewritekey';
        ChargItReq.receivedAt = '2018-08-08T14:29:37.795Z';
        ChargItReq.sentAt = '2018-08-08T14:29:37.000Z';
        ChargItReq.originalTimestamp = '2018-08-08T14:29:33+0000';
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String JsonMsg=JSON.serialize(ChargItReq);
        
        req.requestURI = '/services/apexrest/ChargeItSpot/SignUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        String xsig = generateXSignature(req.requestBody);
        //System.debug('xsig: '+xsig);
        req.addHeader('X-Signature', xsig);
        RestContext.request = req;
        RestContext.response= res;
        
        ChargItRes = ChargeItSpotSignUp.doSignup();
        //System.debug(ChargItRes);
        System.assertEquals(res.statusCode, 400);
        System.assertEquals('Missing brand/email/userId or invalid email', ChargItRes.message);
        System.assertEquals('MISSING_REQ_PARAMS', ChargItRes.code); 
        Test.stopTest();
    }
    
    @isTest static void testdoSignup3(){
        //testdata1();
        
        //Test for Brand id or email present for new Request
        ChargeItSpotSignUp.ChargItReq ChargItReq = new ChargeItSpotSignUp.ChargItReq();
        ChargeItSpotSignUp.ChargeItResponse ChargItRes = new ChargeItSpotSignUp.ChargeItResponse();
        ChargeItSpotSignUp.context ctx = new ChargeItSpotSignUp.context();
        ChargeItSpotSignUp.library lib = new ChargeItSpotSignUp.library();
        ChargeItSpotSignUp.integration integ = new ChargeItSpotSignUp.integration();
        ChargeItSpotSignUp.trait trai = new ChargeItSpotSignUp.trait();
        
        ctx.locale = 'en_US';
        ctx.timezone = 'PST8PDT';
        
        lib.name = 'analytics-java';
        lib.version = 'analytics/2.0.0-RC3';        
        
        trai.brand = 'TH ABC Store 123';
        trai.email='testemail1@nomail.com';
        trai.emailExplicitOptinRequired = 'false';
        trai.emailOptin = 'true';        
        trai.location = 'TestLocation';
        trai.serialNumber = '12345';
        trai.site = 'SiteName';
        trai.smsExplicitOptinRequired = 'false';
        trai.smsOptin = 'true';
        trai.source = 'ChargeItSpot';
        trai.storeNumber = '1234';
        
        ChargItReq.context = ctx;
        ChargItReq.context.library = lib;
        ChargItReq.integrations = integ;        
        ChargItReq.messageId = '52b3947f-23bc-4454-96e6-f33bcbf920ae';
        ChargItReq.timestamp = '2018-08-08T14:29:33.795Z';
        ChargItReq.traits = trai;
        ChargItReq.type= 'identify';
        ChargItReq.userId = '7785551212';
        ChargItReq.writeKey = 'somewritekey';
        ChargItReq.receivedAt = '2018-08-08T14:29:37.795Z';
        ChargItReq.sentAt = '2018-08-08T14:29:37.000Z';
        ChargItReq.originalTimestamp = '2018-08-08T14:29:33+0000';
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String JsonMsg=JSON.serialize(ChargItReq);
        
        req.requestURI = '/services/apexrest/ChargeItSpot/SignUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        String xsig = generateXSignature(req.requestBody);
        //System.debug('xsig: '+xsig);
        req.addHeader('X-Signature', xsig);
        RestContext.request = req;
        RestContext.response= res;
        
        ChargItRes = ChargeItSpotSignUp.doSignup();
        //System.debug(ChargItRes);
        System.assertEquals(res.statusCode, 200);
        System.assertEquals('Success', ChargItRes.message);
        System.assertEquals('OK', ChargItRes.code); 
        Test.stopTest();
    }
    
    @isTest static void testdoSignup4(){
        testdata1();
        
        //Test for Brand id or email present for existing contact
        ChargeItSpotSignUp.ChargItReq ChargItReq = new ChargeItSpotSignUp.ChargItReq();
        ChargeItSpotSignUp.ChargeItResponse ChargItRes = new ChargeItSpotSignUp.ChargeItResponse();
        ChargeItSpotSignUp.context ctx = new ChargeItSpotSignUp.context();
        ChargeItSpotSignUp.library lib = new ChargeItSpotSignUp.library();
        ChargeItSpotSignUp.integration integ = new ChargeItSpotSignUp.integration();
        ChargeItSpotSignUp.trait trai = new ChargeItSpotSignUp.trait();
        
        ctx.locale = 'en_US';
        ctx.timezone = 'PST8PDT';
        
        lib.name = 'analytics-java';
        lib.version = 'analytics/2.0.0-RC3';        
        
        trai.brand = 'TH ABC Store 123';
        trai.email='testemail@nomail.com';
        trai.emailExplicitOptinRequired = 'false';
        trai.emailOptin = 'false';        
        trai.location = 'TestLocation';
        trai.serialNumber = '12345';
        trai.site = 'SiteName';
        trai.smsExplicitOptinRequired = 'false';
        trai.smsOptin = 'true';
        trai.source = 'ChargeItSpot';
        trai.storeNumber = '1234';
        
        ChargItReq.context = ctx;
        ChargItReq.context.library = lib;
        ChargItReq.integrations = integ;        
        ChargItReq.messageId = '52b3947f-23bc-4454-96e6-f33bcbf920ae';
        ChargItReq.timestamp = '2018-08-08T14:29:33.795Z';
        ChargItReq.traits = trai;
        ChargItReq.type= 'identify';
        ChargItReq.userId = '7785551212';
        ChargItReq.writeKey = 'somewritekey';
        ChargItReq.receivedAt = '2018-08-08T14:29:37.795Z';
        ChargItReq.sentAt = '2018-08-08T14:29:37.000Z';
        ChargItReq.originalTimestamp = '2018-08-08T14:29:33+0000';
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String JsonMsg=JSON.serialize(ChargItReq);
        
        req.requestURI = '/services/apexrest/ChargeItSpot/SignUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        String xsig = generateXSignature(req.requestBody);
        //System.debug('xsig: '+xsig);
        req.addHeader('X-Signature', xsig);
        RestContext.request = req;
        RestContext.response= res;
        
        ChargItRes = ChargeItSpotSignUp.doSignup();
        //System.debug(ChargItRes);
        System.assertEquals(res.statusCode, 200);
        System.assertEquals('Success', ChargItRes.message);
        System.assertEquals('OK', ChargItRes.code); 
        Test.stopTest();
    }
    
    @isTest static void testdoSignup5(){
        testdata1();
        
        //Test for Brand id or email present for existing contact for email and sms OptIn
        ChargeItSpotSignUp.ChargItReq ChargItReq = new ChargeItSpotSignUp.ChargItReq();
        ChargeItSpotSignUp.ChargeItResponse ChargItRes = new ChargeItSpotSignUp.ChargeItResponse();
        ChargeItSpotSignUp.context ctx = new ChargeItSpotSignUp.context();
        ChargeItSpotSignUp.library lib = new ChargeItSpotSignUp.library();
        ChargeItSpotSignUp.integration integ = new ChargeItSpotSignUp.integration();
        ChargeItSpotSignUp.trait trai = new ChargeItSpotSignUp.trait();
        
        ctx.locale = 'en_US';
        ctx.timezone = 'PST8PDT';
        
        lib.name = 'analytics-java';
        lib.version = 'analytics/2.0.0-RC3';        
        
        trai.brand = 'TH ABC Store 123';
        trai.email='testemail@nomail.com';
        trai.emailExplicitOptinRequired = 'false';
        trai.emailOptin = 'true';        
        trai.location = 'TestLocation';
        trai.serialNumber = '12345';
        trai.site = 'SiteName';
        trai.smsExplicitOptinRequired = 'false';
        trai.smsOptin = 'true';
        trai.source = 'ChargeItSpot';
        trai.storeNumber = '1234';
        
        ChargItReq.context = ctx;
        ChargItReq.context.library = lib;
        ChargItReq.integrations = integ;        
        ChargItReq.messageId = '52b3947f-23bc-4454-96e6-f33bcbf920ae';
        ChargItReq.timestamp = '2018-08-08T14:29:33.795Z';
        ChargItReq.traits = trai;
        ChargItReq.type= 'identify';
        ChargItReq.userId = '7785551212';
        ChargItReq.writeKey = 'somewritekey';
        ChargItReq.receivedAt = '2018-08-08T14:29:37.795Z';
        ChargItReq.sentAt = '2018-08-08T14:29:37.000Z';
        ChargItReq.originalTimestamp = '2018-08-08T14:29:33+0000';
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String JsonMsg=JSON.serialize(ChargItReq);
        
        req.requestURI = '/services/apexrest/ChargeItSpot/SignUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        String xsig = generateXSignature(req.requestBody);
        //System.debug('xsig: '+xsig);
        req.addHeader('X-Signature', xsig);
        RestContext.request = req;
        RestContext.response= res;
        
        ChargItRes = ChargeItSpotSignUp.doSignup();
        //System.debug(ChargItRes);
        System.assertEquals(res.statusCode, 200);
        System.assertEquals('Success', ChargItRes.message);
        System.assertEquals('OK', ChargItRes.code); 
        Test.stopTest();
    }
    
    @isTest static void testdoSignup6(){
        testdata1();
        
        //Test for Brand id or email present for existing contact for email and sms Opt out
        ChargeItSpotSignUp.ChargItReq ChargItReq = new ChargeItSpotSignUp.ChargItReq();
        ChargeItSpotSignUp.ChargeItResponse ChargItRes = new ChargeItSpotSignUp.ChargeItResponse();
        ChargeItSpotSignUp.context ctx = new ChargeItSpotSignUp.context();
        ChargeItSpotSignUp.library lib = new ChargeItSpotSignUp.library();
        ChargeItSpotSignUp.integration integ = new ChargeItSpotSignUp.integration();
        ChargeItSpotSignUp.trait trai = new ChargeItSpotSignUp.trait();
        
        ctx.locale = 'en_US';
        ctx.timezone = 'PST8PDT';
        
        lib.name = 'analytics-java';
        lib.version = 'analytics/2.0.0-RC3';        
        
        trai.brand = 'TH ABC Store 123';
        trai.email='testemail1@nomail.com';
        trai.emailExplicitOptinRequired = 'false';
        trai.emailOptin = 'false';        
        trai.location = 'TestLocation';
        trai.serialNumber = '12345';
        trai.site = 'SiteName';
        trai.smsExplicitOptinRequired = 'false';
        trai.smsOptin = 'false';
        trai.source = 'ChargeItSpot';
        trai.storeNumber = '1234';
        
        ChargItReq.context = ctx;
        ChargItReq.context.library = lib;
        ChargItReq.integrations = integ;        
        ChargItReq.messageId = '52b3947f-23bc-4454-96e6-f33bcbf920ae';
        ChargItReq.timestamp = '2018-08-08T14:29:33.795Z';
        ChargItReq.traits = trai;
        ChargItReq.type= 'identify';
        ChargItReq.userId = '7785551212';
        ChargItReq.writeKey = 'somewritekey';
        ChargItReq.receivedAt = '2018-08-08T14:29:37.795Z';
        ChargItReq.sentAt = '2018-08-08T14:29:37.000Z';
        ChargItReq.originalTimestamp = '2018-08-08T14:29:33+0000';
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String JsonMsg=JSON.serialize(ChargItReq);
        
        req.requestURI = '/services/apexrest/ChargeItSpot/SignUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        String xsig = generateXSignature(req.requestBody);
        //System.debug('xsig: '+xsig);
        req.addHeader('X-Signature', xsig);
        RestContext.request = req;
        RestContext.response= res;
        
        ChargItRes = ChargeItSpotSignUp.doSignup();
        //System.debug(ChargItRes);
        System.assertEquals(res.statusCode, 200);
        System.assertEquals('Success', ChargItRes.message);
        System.assertEquals('OK', ChargItRes.code); 
        Test.stopTest();
    }
    
    @isTest static void testdoSignup7(){
        
        //Test for Invalid email format
        ChargeItSpotSignUp.ChargItReq ChargItReq = new ChargeItSpotSignUp.ChargItReq();
        ChargeItSpotSignUp.ChargeItResponse ChargItRes = new ChargeItSpotSignUp.ChargeItResponse();
        ChargeItSpotSignUp.context ctx = new ChargeItSpotSignUp.context();
        ChargeItSpotSignUp.library lib = new ChargeItSpotSignUp.library();
        ChargeItSpotSignUp.integration integ = new ChargeItSpotSignUp.integration();
        ChargeItSpotSignUp.trait trai = new ChargeItSpotSignUp.trait();
        
        ctx.locale = 'en_US';
        ctx.timezone = 'PST8PDT';
        
        lib.name = 'analytics-java';
        lib.version = 'analytics/2.0.0-RC3';        
        
        trai.brand = 'TH ABC Store 123';
        trai.email='testemail1nomail.com';        
        
        ChargItReq.context = ctx;
        ChargItReq.context.library = lib;
        ChargItReq.integrations = integ;        
        ChargItReq.messageId = '52b3947f-23bc-4454-96e6-f33bcbf920ae';
        ChargItReq.timestamp = '2018-08-08T14:29:33.795Z';
        ChargItReq.traits = trai;
        ChargItReq.type= 'identify';
        ChargItReq.userId = '7785551212';
        ChargItReq.writeKey = 'somewritekey';
        ChargItReq.receivedAt = '2018-08-08T14:29:37.795Z';
        ChargItReq.sentAt = '2018-08-08T14:29:37.000Z';
        ChargItReq.originalTimestamp = '2018-08-08T14:29:33+0000';
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String JsonMsg=JSON.serialize(ChargItReq);
        
        req.requestURI = '/services/apexrest/ChargeItSpot/SignUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        String xsig = generateXSignature(req.requestBody);
        //System.debug('xsig: '+xsig);
        req.addHeader('X-Signature', xsig);
        RestContext.request = req;
        RestContext.response= res;
        
        ChargItRes = ChargeItSpotSignUp.doSignup();
        //System.debug(ChargItRes);
        System.assertEquals(res.statusCode, 400);
        System.assertEquals('Missing brand/email/userId or invalid email', ChargItRes.message);
        System.assertEquals('MISSING_REQ_PARAMS', ChargItRes.code); 
        Test.stopTest();
    }
    
    //added
    // only emailMatched contact found
    @isTest 
    static void testdoSignup11(){
        Contact createdCon = createTestData();
        createdCon.Email = 'email_matched_contact@gmail.com';
        createdCon.EmailOptInStatus__c = 'N'; //false;
        createdCon.SMSOptinStatus__c = 'N'; //false;
        insert createdCon;
        
        //Test for Brand id or email present for existing contact for email and sms Opt out
        ChargeItSpotSignUp.ChargItReq ChargItReq = new ChargeItSpotSignUp.ChargItReq();
        ChargeItSpotSignUp.ChargeItResponse ChargItRes = new ChargeItSpotSignUp.ChargeItResponse();
        ChargeItSpotSignUp.context ctx = new ChargeItSpotSignUp.context();
        ChargeItSpotSignUp.library lib = new ChargeItSpotSignUp.library();
        ChargeItSpotSignUp.integration integ = new ChargeItSpotSignUp.integration();
        ChargeItSpotSignUp.trait trai = new ChargeItSpotSignUp.trait();
        
        ctx.locale = 'en_US';
        ctx.timezone = 'PST8PDT';
        
        lib.name = 'analytics-java';
        lib.version = 'analytics/2.0.0-RC3';        
        
        trai.brand = 'TH ABC Store 123';
        trai.email='email_matched_contact@gmail.com';
        trai.emailExplicitOptinRequired = 'false';
        trai.emailOptin = 'true';        
        trai.location = 'TestLocation';
        trai.serialNumber = '12345';
        trai.site = 'SiteName';
        trai.smsExplicitOptinRequired = 'false';
        trai.smsOptin = 'false';
        trai.source = 'ChargeItSpot';
        trai.storeNumber = '1234';
        
        ChargItReq.context = ctx;
        ChargItReq.context.library = lib;
        ChargItReq.integrations = integ;        
        ChargItReq.messageId = '52b3947f-23bc-4454-96e6-f33bcbf920ae';
        ChargItReq.timestamp = '2018-08-08T14:29:33.795Z';
        ChargItReq.traits = trai;
        ChargItReq.type= 'identify';
        ChargItReq.userId = '7785551212';
        ChargItReq.writeKey = 'somewritekey';
        ChargItReq.receivedAt = '2018-08-08T14:29:37.795Z';
        ChargItReq.sentAt = '2018-08-08T14:29:37.000Z';
        ChargItReq.originalTimestamp = '2018-08-08T14:29:33+0000';
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String JsonMsg=JSON.serialize(ChargItReq);
        
        req.requestURI = '/services/apexrest/ChargeItSpot/SignUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        String xsig = generateXSignature(req.requestBody);
        //System.debug('xsig: '+xsig);
        req.addHeader('X-Signature', xsig);
        RestContext.request = req;
        RestContext.response= res;
        
        ChargItRes = ChargeItSpotSignUp.doSignup();
        //System.debug(ChargItRes);
        System.assertEquals(res.statusCode, 200);
        System.assertEquals('Success', ChargItRes.message);
        System.assertEquals('OK', ChargItRes.code); 
        Test.stopTest();
    }
    
    //smsAndEmailExactMatch contact found
    @isTest 
    static void testdoSignup12(){
        Contact createdCon = createTestData();
        createdCon.Email = 'SMSemail_matched_contact@gmail.com';
        createdCon.EmailOptInStatus__c = 'N'; //false;
        createdCon.SMSOptinStatus__c = 'N'; //false;
        createdCon.SMSNumber__c = '7785551212';
        insert createdCon;
        
        //Test for Brand id or email present for existing contact for email and sms Opt out
        ChargeItSpotSignUp.ChargItReq ChargItReq = new ChargeItSpotSignUp.ChargItReq();
        ChargeItSpotSignUp.ChargeItResponse ChargItRes = new ChargeItSpotSignUp.ChargeItResponse();
        ChargeItSpotSignUp.context ctx = new ChargeItSpotSignUp.context();
        ChargeItSpotSignUp.library lib = new ChargeItSpotSignUp.library();
        ChargeItSpotSignUp.integration integ = new ChargeItSpotSignUp.integration();
        ChargeItSpotSignUp.trait trai = new ChargeItSpotSignUp.trait();
        
        ctx.locale = 'en_US';
        ctx.timezone = 'PST8PDT';
        
        lib.name = 'analytics-java';
        lib.version = 'analytics/2.0.0-RC3';        
        
        trai.brand = 'TH ABC Store 123';
        trai.email='SMSemail_matched_contact@gmail.com';
        trai.emailExplicitOptinRequired = 'false';
        trai.emailOptin = 'true';        
        trai.location = 'TestLocation';
        trai.serialNumber = '12345';
        trai.site = 'SiteName';
        trai.smsExplicitOptinRequired = 'false';
        trai.smsOptin = 'true';
        trai.source = 'ChargeItSpot';
        trai.storeNumber = '1234';
        
        ChargItReq.context = ctx;
        ChargItReq.context.library = lib;
        ChargItReq.integrations = integ;        
        ChargItReq.messageId = '52b3947f-23bc-4454-96e6-f33bcbf920ae';
        ChargItReq.timestamp = '2018-08-08T14:29:33.795Z';
        ChargItReq.traits = trai;
        ChargItReq.type= 'identify';
        ChargItReq.userId = '7785551212';
        ChargItReq.writeKey = 'somewritekey';
        ChargItReq.receivedAt = '2018-08-08T14:29:37.795Z';
        ChargItReq.sentAt = '2018-08-08T14:29:37.000Z';
        ChargItReq.originalTimestamp = '2018-08-08T14:29:33+0000';
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String JsonMsg=JSON.serialize(ChargItReq);
        
        req.requestURI = '/services/apexrest/ChargeItSpot/SignUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        String xsig = generateXSignature(req.requestBody);
        //System.debug('xsig: '+xsig);
        req.addHeader('X-Signature', xsig);
        RestContext.request = req;
        RestContext.response= res;
        
        ChargItRes = ChargeItSpotSignUp.doSignup();
        //System.debug(ChargItRes);
        System.assertEquals(res.statusCode, 200);
        System.assertEquals('Success', ChargItRes.message);
        System.assertEquals('OK', ChargItRes.code); 
        Test.stopTest();
    }
    
    //only sms match contact found and email is null
    @isTest 
    static void testdoSignup13(){
        Contact createdCon = createTestData();
        createdCon.Email = null;
        createdCon.EmailOptInStatus__c = 'N'; //false;
        createdCon.SMSOptinStatus__c = 'N'; //false;
        createdCon.SMSNumber__c = '7785551212';
        insert createdCon;
        
        //Test for Brand id or email present for existing contact for email and sms Opt out
        ChargeItSpotSignUp.ChargItReq ChargItReq = new ChargeItSpotSignUp.ChargItReq();
        ChargeItSpotSignUp.ChargeItResponse ChargItRes = new ChargeItSpotSignUp.ChargeItResponse();
        ChargeItSpotSignUp.context ctx = new ChargeItSpotSignUp.context();
        ChargeItSpotSignUp.library lib = new ChargeItSpotSignUp.library();
        ChargeItSpotSignUp.integration integ = new ChargeItSpotSignUp.integration();
        ChargeItSpotSignUp.trait trai = new ChargeItSpotSignUp.trait();
        
        ctx.locale = 'en_US';
        ctx.timezone = 'PST8PDT';
        
        lib.name = 'analytics-java';
        lib.version = 'analytics/2.0.0-RC3';        
        
        trai.brand = 'TH ABC Store 123';
        trai.email='Email_matched_contact@gmail.com';
        trai.emailExplicitOptinRequired = 'false';
        trai.emailOptin = 'true';        
        trai.location = 'TestLocation';
        trai.serialNumber = '12345';
        trai.site = 'SiteName';
        trai.smsExplicitOptinRequired = 'false';
        trai.smsOptin = 'true';
        trai.source = 'ChargeItSpot';
        trai.storeNumber = '1234';
        
        ChargItReq.context = ctx;
        ChargItReq.context.library = lib;
        ChargItReq.integrations = integ;        
        ChargItReq.messageId = '52b3947f-23bc-4454-96e6-f33bcbf920ae';
        ChargItReq.timestamp = '2018-08-08T14:29:33.795Z';
        ChargItReq.traits = trai;
        ChargItReq.type= 'identify';
        ChargItReq.userId = '7785551212';
        ChargItReq.writeKey = 'somewritekey';
        ChargItReq.receivedAt = '2018-08-08T14:29:37.795Z';
        ChargItReq.sentAt = '2018-08-08T14:29:37.000Z';
        ChargItReq.originalTimestamp = '2018-08-08T14:29:33+0000';
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String JsonMsg=JSON.serialize(ChargItReq);
        
        req.requestURI = '/services/apexrest/ChargeItSpot/SignUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        String xsig = generateXSignature(req.requestBody);
        //System.debug('xsig: '+xsig);
        req.addHeader('X-Signature', xsig);
        RestContext.request = req;
        RestContext.response= res;
        
        ChargItRes = ChargeItSpotSignUp.doSignup();
        //System.debug(ChargItRes);
        System.assertEquals(res.statusCode, 200);
        System.assertEquals('Success', ChargItRes.message);
        System.assertEquals('OK', ChargItRes.code); 
        Test.stopTest();
    }

    //only sms match contact found and email is NOT null
    @isTest 
    static void testdoSignup14(){
        Contact createdCon = createTestData();
        createdCon.Email = 'notFound@gmail.com';
        createdCon.EmailOptInStatus__c = 'N'; //false;
        createdCon.SMSOptinStatus__c = 'N'; //false;
        createdCon.SMSNumber__c = '7785551212';
        insert createdCon;
        
        //Test for Brand id or email present for existing contact for email and sms Opt out
        ChargeItSpotSignUp.ChargItReq ChargItReq = new ChargeItSpotSignUp.ChargItReq();
        ChargeItSpotSignUp.ChargeItResponse ChargItRes = new ChargeItSpotSignUp.ChargeItResponse();
        ChargeItSpotSignUp.context ctx = new ChargeItSpotSignUp.context();
        ChargeItSpotSignUp.library lib = new ChargeItSpotSignUp.library();
        ChargeItSpotSignUp.integration integ = new ChargeItSpotSignUp.integration();
        ChargeItSpotSignUp.trait trai = new ChargeItSpotSignUp.trait();
        
        ctx.locale = 'en_US';
        ctx.timezone = 'PST8PDT';
        
        lib.name = 'analytics-java';
        lib.version = 'analytics/2.0.0-RC3';        
        
        trai.brand = 'TH ABC Store 123';
        trai.email='Email_matched_contact@gmail.com';
        trai.emailExplicitOptinRequired = 'false';
        trai.emailOptin = 'true';        
        trai.location = 'TestLocation';
        trai.serialNumber = '12345';
        trai.site = 'SiteName';
        trai.smsExplicitOptinRequired = 'false';
        trai.smsOptin = 'true';
        trai.source = 'ChargeItSpot';
        trai.storeNumber = '1234';
        
        ChargItReq.context = ctx;
        ChargItReq.context.library = lib;
        ChargItReq.integrations = integ;        
        ChargItReq.messageId = '52b3947f-23bc-4454-96e6-f33bcbf920ae';
        ChargItReq.timestamp = '2018-08-08T14:29:33.795Z';
        ChargItReq.traits = trai;
        ChargItReq.type= 'identify';
        ChargItReq.userId = '7785551212';
        ChargItReq.writeKey = 'somewritekey';
        ChargItReq.receivedAt = '2018-08-08T14:29:37.795Z';
        ChargItReq.sentAt = '2018-08-08T14:29:37.000Z';
        ChargItReq.originalTimestamp = '2018-08-08T14:29:33+0000';
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String JsonMsg=JSON.serialize(ChargItReq);
        
        req.requestURI = '/services/apexrest/ChargeItSpot/SignUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        String xsig = generateXSignature(req.requestBody);
        //System.debug('xsig: '+xsig);
        req.addHeader('X-Signature', xsig);
        RestContext.request = req;
        RestContext.response= res;
        
        ChargItRes = ChargeItSpotSignUp.doSignup();
        //System.debug(ChargItRes);
        System.assertEquals(res.statusCode, 200);
        System.assertEquals('Success', ChargItRes.message);
        System.assertEquals('OK', ChargItRes.code); 
        Test.stopTest();
    }
  
    //only email match contact found and SMSNumber is NOT null
    @isTest 
    static void testdoSignup15(){
        Contact createdCon = createTestData();
        createdCon.Email = 'Email_matched_contact@gmail.com';
        createdCon.EmailOptInStatus__c = 'N'; //false;
        createdCon.SMSOptinStatus__c = 'N'; //false;
        createdCon.SMSNumber__c = '7785551213';
        insert createdCon;
        
        //Test for Brand id or email present for existing contact for email and sms Opt out
        ChargeItSpotSignUp.ChargItReq ChargItReq = new ChargeItSpotSignUp.ChargItReq();
        ChargeItSpotSignUp.ChargeItResponse ChargItRes = new ChargeItSpotSignUp.ChargeItResponse();
        ChargeItSpotSignUp.context ctx = new ChargeItSpotSignUp.context();
        ChargeItSpotSignUp.library lib = new ChargeItSpotSignUp.library();
        ChargeItSpotSignUp.integration integ = new ChargeItSpotSignUp.integration();
        ChargeItSpotSignUp.trait trai = new ChargeItSpotSignUp.trait();
        
        ctx.locale = 'en_US';
        ctx.timezone = 'PST8PDT';
        
        lib.name = 'analytics-java';
        lib.version = 'analytics/2.0.0-RC3';        
        
        trai.brand = 'TH ABC Store 123';
        trai.email='Email_matched_contact@gmail.com';
        trai.emailExplicitOptinRequired = 'false';
        trai.emailOptin = 'true';        
        trai.location = 'TestLocation';
        trai.serialNumber = '12345';
        trai.site = 'SiteName';
        trai.smsExplicitOptinRequired = 'false';
        trai.smsOptin = 'true';
        trai.source = 'ChargeItSpot';
        trai.storeNumber = '1234';
        
        ChargItReq.context = ctx;
        ChargItReq.context.library = lib;
        ChargItReq.integrations = integ;        
        ChargItReq.messageId = '52b3947f-23bc-4454-96e6-f33bcbf920ae';
        ChargItReq.timestamp = '2018-08-08T14:29:33.795Z';
        ChargItReq.traits = trai;
        ChargItReq.type= 'identify';
        ChargItReq.userId = '7785551212';
        ChargItReq.writeKey = 'somewritekey';
        ChargItReq.receivedAt = '2018-08-08T14:29:37.795Z';
        ChargItReq.sentAt = '2018-08-08T14:29:37.000Z';
        ChargItReq.originalTimestamp = '2018-08-08T14:29:33+0000';
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String JsonMsg=JSON.serialize(ChargItReq);
        
        req.requestURI = '/services/apexrest/ChargeItSpot/SignUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        String xsig = generateXSignature(req.requestBody);
        //System.debug('xsig: '+xsig);
        req.addHeader('X-Signature', xsig);
        RestContext.request = req;
        RestContext.response= res;
        
        ChargItRes = ChargeItSpotSignUp.doSignup();
        //System.debug(ChargItRes);
        System.assertEquals(res.statusCode, 200);
        System.assertEquals('Success', ChargItRes.message);
        System.assertEquals('OK', ChargItRes.code); 
        Test.stopTest();
    }
    
    //one smsMatched , one emailMatched but not exactMatched
    @isTest 
    static void testdoSignup16(){
        Contact createdCon = createTestData();
        createdCon.Email = 'Email_matched_contact@gmail.com';
        createdCon.EmailOptInStatus__c = 'N'; //false;
        createdCon.SMSOptinStatus__c = 'N'; //false;
        createdCon.SMSNumber__c = '7785551213';
        insert createdCon;
        
        Contact createdConSMS = createTestData();
        createdConSMS.Email = 'SMS_matched_contact@gmail.com';
        createdConSMS.EmailOptInStatus__c = 'N'; //false;
        createdConSMS.SMSOptinStatus__c = 'N'; //false;
        createdConSMS.SMSNumber__c = '7785551212';
        insert createdConSMS;
        
        //Test for Brand id or email present for existing contact for email and sms Opt out
        ChargeItSpotSignUp.ChargItReq ChargItReq = new ChargeItSpotSignUp.ChargItReq();
        ChargeItSpotSignUp.ChargeItResponse ChargItRes = new ChargeItSpotSignUp.ChargeItResponse();
        ChargeItSpotSignUp.context ctx = new ChargeItSpotSignUp.context();
        ChargeItSpotSignUp.library lib = new ChargeItSpotSignUp.library();
        ChargeItSpotSignUp.integration integ = new ChargeItSpotSignUp.integration();
        ChargeItSpotSignUp.trait trai = new ChargeItSpotSignUp.trait();
        
        ctx.locale = 'en_US';
        ctx.timezone = 'PST8PDT';
        
        lib.name = 'analytics-java';
        lib.version = 'analytics/2.0.0-RC3';        
        
        trai.brand = 'TH ABC Store 123';
        trai.email='Email_matched_contact@gmail.com';
        trai.emailExplicitOptinRequired = 'false';
        trai.emailOptin = 'true';        
        trai.location = 'TestLocation';
        trai.serialNumber = '12345';
        trai.site = 'SiteName';
        trai.smsExplicitOptinRequired = 'false';
        trai.smsOptin = 'true';
        trai.source = 'ChargeItSpot';
        trai.storeNumber = '1234';
        
        ChargItReq.context = ctx;
        ChargItReq.context.library = lib;
        ChargItReq.integrations = integ;        
        ChargItReq.messageId = '52b3947f-23bc-4454-96e6-f33bcbf920ae';
        ChargItReq.timestamp = '2018-08-08T14:29:33.795Z';
        ChargItReq.traits = trai;
        ChargItReq.type= 'identify';
        ChargItReq.userId = '7785551212';
        ChargItReq.writeKey = 'somewritekey';
        ChargItReq.receivedAt = '2018-08-08T14:29:37.795Z';
        ChargItReq.sentAt = '2018-08-08T14:29:37.000Z';
        ChargItReq.originalTimestamp = '2018-08-08T14:29:33+0000';
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String JsonMsg=JSON.serialize(ChargItReq);
        
        req.requestURI = '/services/apexrest/ChargeItSpot/SignUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        String xsig = generateXSignature(req.requestBody);
        //System.debug('xsig: '+xsig);
        req.addHeader('X-Signature', xsig);
        RestContext.request = req;
        RestContext.response= res;
        
        ChargItRes = ChargeItSpotSignUp.doSignup();
        //System.debug(ChargItRes);
        System.assertEquals(res.statusCode, 200);
        System.assertEquals('Success', ChargItRes.message);
        System.assertEquals('OK', ChargItRes.code); 
        Test.stopTest();
    }
    
    
}