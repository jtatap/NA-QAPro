@isTest
private class InboundSignUpTest {
    
    @isTest
    static void newContactSignupTest(){
        InboundSignUp.signupRequest signupRequest = new InboundSignUp.signupRequest();
        List<InboundSignUp.Subscriber> SubscribesList = new List<InboundSignUp.Subscriber>();
        InboundSignUp.Subscriber Subscribes1 = new InboundSignUp.Subscriber();
        Subscribes1.brandId = '1';
        Subscribes1.sourceSystem = 'POS';
        Subscribes1.welcomeSource = '';
        Subscribes1.email = 'test@gmail.com';
        Subscribes1.emailOptinFlag = 'true';
        Subscribes1.loyaltyOptinFlag = 'true';
      //  Subscribes1.smsOptIn = 'true';
        Subscribes1.firstName = 'John';
        Subscribes1.lastName = 'Doe';
      /*  Subscribes1.address1 = '123 E';
        Subscribes1.address2 = '';
        Subscribes1.city = 'Albany';
        Subscribes1.state = 'NY';
        Subscribes1.zip = '14810';
        Subscribes1.country = 'US';
        Subscribes1.phonenumber = '5555555555';
        Subscribes1.homePhone = '5555555555';
        Subscribes1.mobilePhone = '5555555555';
        Subscribes1.birthMonth = '07';
        Subscribes1.birthDay = '20';
        Subscribes1.birthyear = '1995';
        Subscribes1.gender = 'Male';*/
        Subscribes1.region = '';
        Subscribes1.market = '';
        Subscribes1.preferredLanguage = '';
        SubscribesList.add(Subscribes1);
        signupRequest.count = '1';
        signupRequest.Subscribes = SubscribesList;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/subscribers/SignUps';
        req.httpMethod = 'POST';
        req.requestBody = blob.valueOf(JSON.serialize(signupRequest));
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        InboundSignUp.doSignUp();
        integer count = [SELECT COUNT() FROM Contact];
      //  system.assertEquals(1,count);
        Test.stopTest();
    }
    
    @isTest
    static void newContactSignupTest2(){
        InboundSignUp.signupRequest signupRequest = new InboundSignUp.signupRequest();
        List<InboundSignUp.Subscriber> SubscribesList = new List<InboundSignUp.Subscriber>();
        InboundSignUp.Subscriber Subscribes1 = new  InboundSignUp.Subscriber();
        Subscribes1.brandId = '1';
        Subscribes1.sourceSystem = 'POS';
        Subscribes1.welcomeSource = '01';
        Subscribes1.email = 'test1@gmail.com';
        Subscribes1.emailOptinFlag = 'true';
        Subscribes1.loyaltyOptinFlag = 'true';
       // Subscribes1.smsOptIn = 'true';
        Subscribes1.firstName = 'John';
        Subscribes1.lastName = 'Doe';
       /* Subscribes1.address1 = '123 E';
        Subscribes1.address2 = '';
        Subscribes1.city = 'Albany';
        Subscribes1.state = 'NY';
        Subscribes1.zip = '14810';
        Subscribes1.phonenumber = '5555555555';
        Subscribes1.homePhone = '5555555555';
        Subscribes1.mobilePhone = '5555555555';
        Subscribes1.birthMonth = '07';
        Subscribes1.birthDay = '20';
        Subscribes1.birthyear = '1995';
        Subscribes1.gender = 'Male';*/
        Subscribes1.country = 'US';
        Subscribes1.region = '';
        Subscribes1.market = '';
        Subscribes1.preferredLanguage = '';
        SubscribesList.add(Subscribes1);
        signupRequest.count = '1';
        signupRequest.Subscribes = SubscribesList;
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/subscribers/SignUps';
        req.httpMethod = 'POST';
        req.requestBody = blob.valueOf(JSON.serialize(signupRequest));
        RestContext.request = req;
        RestContext.response = res;
        InboundSignUp.signupResponse response = InboundSignUp.doSignUp();
        integer count = [SELECT COUNT() FROM Contact];
        system.assertEquals(1,count);
        Test.stopTest();
    }
    
    @isTest
    static void existingContactSignupTest3(){
        Contact con = new Contact();
        con.FirstName = 'TestFirst';
        con.LastName = 'TestLast';
        con.Email = 'test@gmail.com';
        con.Brand_Id__c = '1';
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId();
        insert con;
        Test.startTest();
        InboundSignUp.signupRequest signupRequest = new InboundSignUp.signupRequest();
        List<InboundSignUp.Subscriber> SubscribesList = new List<InboundSignUp.Subscriber>();
        InboundSignUp.Subscriber Subscribes1 = new  InboundSignUp.Subscriber();
        Subscribes1.brandId = '1';
        Subscribes1.sourceSystem = 'POS';
        Subscribes1.welcomeSource = '';
        Subscribes1.email = 'test@gmail.com';
        Subscribes1.emailOptinFlag = 'true';
        Subscribes1.loyaltyOptinFlag = 'true';
       // Subscribes1.smsOptIn = 'true';
        Subscribes1.firstName = 'John';
        Subscribes1.lastName = 'Doe';
       /* Subscribes1.address1 = '123 E';
        Subscribes1.address2 = '';
        Subscribes1.city = 'Albany';
        Subscribes1.state = 'NY';
        Subscribes1.zip = '14810';
        Subscribes1.phonenumber = '5555555555';
        Subscribes1.homePhone = '5555555555';
        Subscribes1.mobilePhone = '5555555555';
        Subscribes1.birthMonth = '07';
        Subscribes1.birthDay = '20';
        Subscribes1.birthyear = '1995';
        Subscribes1.gender = 'Male';*/
        Subscribes1.country = 'US';
        Subscribes1.region = '';
        Subscribes1.market = '';
        Subscribes1.preferredLanguage = '';
        SubscribesList.add(Subscribes1);
        signupRequest.count = '1';
        signupRequest.Subscribes = SubscribesList;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/subscribers/SignUps';
        req.httpMethod = 'POST';
        req.requestBody = blob.valueOf(JSON.serialize(signupRequest));
        RestContext.request = req;
        RestContext.response = res;
        
        InboundSignUp.doSignUp();
        Contact conDetails = [SELECT Id,lastName,HomePhone,Source_System__c FROM Contact WHERE Id=:con.Id];
        system.assertEquals('Doe',conDetails.lastName);
        Test.stopTest();
    }
    
    @isTest
    static void existingContactSignupTest4(){
        Contact con = new Contact();
        con.FirstName = 'TestFirst';
        con.LastName = 'TestLast';
        con.Email = 'test@gmail.com';
        con.Brand_Id__c = '1';
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId();
        insert con;
        Test.startTest();
        InboundSignUp.signupRequest signupRequest = new InboundSignUp.signupRequest();
        List<InboundSignUp.Subscriber> SubscribesList = new List<InboundSignUp.Subscriber>();
        InboundSignUp.Subscriber Subscribes1 = new  InboundSignUp.Subscriber();
        Subscribes1.brandId = '';
        Subscribes1.sourceSystem = 'POS';
        Subscribes1.welcomeSource = '';
        Subscribes1.email = 'test@gmail.com';
        Subscribes1.emailOptinFlag = 'true';
        Subscribes1.loyaltyOptinFlag = 'true';
       // Subscribes1.smsOptIn = 'true';
        Subscribes1.firstName = 'John';
        Subscribes1.lastName = 'Doe';
       /* Subscribes1.address1 = '123 E';
        Subscribes1.address2 = '';
        Subscribes1.city = 'Albany';
        Subscribes1.state = 'NY';
        Subscribes1.zip = '14810';*/
        Subscribes1.country = 'US';
       /* Subscribes1.phonenumber = '5555555555';
        Subscribes1.homePhone = '5555555555';
        Subscribes1.mobilePhone = '5555555555';
        Subscribes1.birthMonth = '07';
        Subscribes1.birthDay = '20';
        Subscribes1.birthyear = '1995';
        Subscribes1.gender = 'Male';*/
        Subscribes1.region = '';
        Subscribes1.market = '';
        Subscribes1.preferredLanguage = '';
        SubscribesList.add(Subscribes1);
        signupRequest.count = '1';
        signupRequest.Subscribes = SubscribesList;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/subscribers/SignUps';
        req.httpMethod = 'POST';
        req.requestBody = blob.valueOf(JSON.serialize(signupRequest));
        RestContext.request = req;
        RestContext.response = res;
        
        InboundSignUp.doSignUp();
        Test.stopTest();
    }
    
    @isTest
    static void existingContactSignupTestNegative(){
        Contact con = new Contact();
        con.FirstName = 'TestFirst';
        con.LastName = 'TestLast';
        con.Email = '';
        con.Brand_Id__c = '1';
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId();
        insert con;
        Test.startTest();
        InboundSignUp.signupRequest signupRequest = new InboundSignUp.signupRequest();
        List<InboundSignUp.Subscriber> SubscribesList = new List<InboundSignUp.Subscriber>();
        InboundSignUp.Subscriber Subscribes1 = new  InboundSignUp.Subscriber();
        Subscribes1.brandId = '';
        Subscribes1.sourceSystem = 'POS';
        Subscribes1.welcomeSource = '';
        Subscribes1.email = 'test@gmail.com';
        Subscribes1.emailOptinFlag = 'true';
        Subscribes1.loyaltyOptinFlag = 'true';
       // Subscribes1.smsOptIn = 'true';
        Subscribes1.firstName = 'John';
        Subscribes1.lastName = 'Doe';
        /*Subscribes1.address1 = '123 E';
        Subscribes1.address2 = '';
        Subscribes1.city = 'Albany';
        Subscribes1.state = 'NY';
        Subscribes1.zip = '14810';
        Subscribes1.phonenumber = '5555555555';
        Subscribes1.homePhone = '5555555555';
        Subscribes1.mobilePhone = '5555555555';
        Subscribes1.birthMonth = '07';
        Subscribes1.birthDay = '20';
        Subscribes1.birthyear = '1995';
        Subscribes1.gender = 'Male';*/
        Subscribes1.country = 'US';
        Subscribes1.region = '';
        Subscribes1.market = '';
        Subscribes1.preferredLanguage = '';
        SubscribesList.add(Subscribes1);
        signupRequest.count = '1';
        signupRequest.Subscribes = SubscribesList;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/subscribers/SignUps';
        req.httpMethod = 'POST';
        req.requestBody = blob.valueOf(JSON.serialize(signupRequest));
        RestContext.request = req;
        RestContext.response = res;
        
        InboundSignUp.doSignUp();
        Test.stopTest();
    }
}