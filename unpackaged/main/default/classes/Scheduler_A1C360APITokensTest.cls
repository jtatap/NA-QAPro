@isTest
public class Scheduler_A1C360APITokensTest {
    
    static Map<String, String> responseHeaders = new Map<String, String>();    
    @isTest(SeeAllData=true) 
    public static void setC360APITokensTest(){
        Test.startTest();
        responseHeaders.put('Content-Type', 'application/json');
        SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                                 'Complete',
                                                 '{"access_token":"ecdc4492-8a1c-4f03-b9ad-6b9db87f61a1","token_type":"bearer","expires_in":15445210}',
                                                 responseHeaders);
        
        Test.setMock(HttpCalloutMock.class, fakeResponse);   
        Scheduler_A1C360APITokens.setC360APITokens();
        Integer callouts = Limits.getCallouts();
        Test.stopTest();
        system.assertEquals(0, callouts);
    }
    @isTest(SeeAllData=true) 
     public static void setC360APITokenspostTest(){
         Test.startTest();
        responseHeaders.put('Content-Type', 'application/json');
        SingleRequestMock fakeResponse = new SingleRequestMock(100,
                                                 'Complete',
                                                 '{"access_token":"ecdc4492-8a1c-4f03-b9ad-6b9db87f61a1","token_type":"bearer","expires_in":15445210}',
                                                 responseHeaders);
        
        Test.setMock(HttpCalloutMock.class, fakeResponse);   
        Scheduler_A1C360APITokens.setC360APITokens();
        Integer callouts = Limits.getCallouts();
        Test.stopTest();
        system.assertEquals(0, callouts);
    }
    @isTest
    public static void scheduleBatchTest(){
         Test.startTest();
        responseHeaders.put('Content-Type', 'application/json');
        SingleRequestMock fakeResponse = new SingleRequestMock(100,
                                                 'Complete',
                                                 '{"access_token":"ecdc4492-8a1c-4f03-b9ad-6b9db87f61a1","token_type":"bearer","expires_in":15445210}',
                                                 responseHeaders);
        
        Test.setMock(HttpCalloutMock.class, fakeResponse);   
         Scheduler_A1C360APITokens.setC360APITokens();
        Scheduler_A1C360APITokens a360 = new Scheduler_A1C360APITokens();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test c360', sch, a360);
        Integer callouts = Limits.getCallouts();
        Test.stopTest();
        system.assertEquals(0, callouts);
 
    }


    @isTest
    public static void setC360APITokenspostTest_extCall(){
        List<A1_C360API_creds__mdt> credMapping = (List<A1_C360API_creds__mdt>) Json.deserialize(
            '[' + 
                '{"Id": "123", "MasterLabel": "123", "Base64__c": "123", "BrandId__c": "123", "Password__c": "123", "Username__c": "123", "TenantId__c": "123", "DeveloperName": "123"}' + 
            ']', List<A1_C360API_creds__mdt>.class);
        Scheduler_A1C360APITokens.TEST_credListMetadata = credMapping;

        List<A1_C360API_Tokens__mdt> accessTokenMapping = (List<A1_C360API_Tokens__mdt>) Json.deserialize(
            '[' + 
                '{"Id": "123", "access_key__c": "123", "access_token__c": "123", "BrandId__c": "123", "key_expires_at__c": "2018-08-31T06:00:00.000Z", "token_expires_at__c": "2018-08-31T06:00:00.000Z", "token_expires_in__c": "15600000"}' + 
            ']', List<A1_C360API_Tokens__mdt>.class);
        Scheduler_A1C360APITokens.TEST_accessTokenMetadata = accessTokenMapping;

        Test.startTest();


        responseHeaders.put('Content-Type', 'application/json');

        MultiRequestMock fakeResponses = new MultiRequestMock();
        fakeResponses.addRequestMock(SYSTEM.LABEL.callout_A1_C360API_AuthEndPoint_token, 'GET', new SingleRequestMock(200, 'Complete', '{"access_token":"123", "token_type":"123","expires_in":123}', responseHeaders));
        fakeResponses.addRequestMock(SYSTEM.LABEL.callout_A1_C360API_AuthEndPoint_authentication_action_login, SYSTEM.LABEL.POST, new SingleRequestMock(200, 'Complete', '{"access_token":"123", "token_type":"123","expires_in":123}', responseHeaders));

        Test.setMock(HttpCalloutMock.class, fakeResponses);        
        Scheduler_A1C360APITokens.setC360APITokens();
        Integer callouts = Limits.getCallouts();
        Test.stopTest();
        system.assertEquals(0, callouts);
    }



    @isTest
    public static void setC360APITokenspostTest_extCallFail(){
        List<A1_C360API_creds__mdt> credMapping = (List<A1_C360API_creds__mdt>) Json.deserialize(
            '[' + 
                '{"Id": "123", "MasterLabel": "123", "Base64__c": "123", "BrandId__c": "123", "Password__c": "123", "Username__c": "123", "TenantId__c": "123", "DeveloperName": "123"}' + 
            ']', List<A1_C360API_creds__mdt>.class);
        Scheduler_A1C360APITokens.TEST_credListMetadata = credMapping;

        List<A1_C360API_Tokens__mdt> accessTokenMapping = (List<A1_C360API_Tokens__mdt>) Json.deserialize(
            '[' + 
                '{"Id": "123", "access_key__c": "123", "access_token__c": "123", "BrandId__c": "123", "key_expires_at__c": "2018-08-31T06:00:00.000Z", "token_expires_at__c": "2018-08-31T06:00:00.000Z", "token_expires_in__c": "15600000"}' + 
            ']', List<A1_C360API_Tokens__mdt>.class);
        Scheduler_A1C360APITokens.TEST_accessTokenMetadata = accessTokenMapping;

        Test.startTest();


        responseHeaders.put('Content-Type', 'application/json');

        MultiRequestMock fakeResponses = new MultiRequestMock();
        fakeResponses.addRequestMock(SYSTEM.LABEL.callout_A1_C360API_AuthEndPoint_token, 'GET', new SingleRequestMock(405, 'Complete', '{"access_token":"123", "token_type":"123","expires_in":123}', responseHeaders));
        fakeResponses.addRequestMock(SYSTEM.LABEL.callout_A1_C360API_AuthEndPoint_authentication_action_login, SYSTEM.LABEL.POST, new SingleRequestMock(200, 'Complete', '{"access_token":"123", "token_type":"123","expires_in":123}', responseHeaders));

        Test.setMock(HttpCalloutMock.class, fakeResponses);        
        Scheduler_A1C360APITokens.setC360APITokens();
        Integer callouts = Limits.getCallouts();
        Test.stopTest();
        system.assertEquals(0, callouts);
    }
    
    @isTest
    public static void setC360APITokenspostTest_extCall1(){
        List<A1_C360API_creds__mdt> credMapping = (List<A1_C360API_creds__mdt>) Json.deserialize(
            '[' + 
                '{"Id": "123", "MasterLabel": "123", "Base64__c": "123", "BrandId__c": "123", "Password__c": "123", "Username__c": "123", "TenantId__c": "123", "DeveloperName": "123"}' + 
            ']', List<A1_C360API_creds__mdt>.class);
        Scheduler_A1C360APITokens.TEST_credListMetadata = credMapping;

        List<A1_C360API_Tokens__mdt> accessTokenMapping = (List<A1_C360API_Tokens__mdt>) Json.deserialize(
            '[' + 
                '{"Id": "123", "access_key__c": "123", "access_token__c": "123", "BrandId__c": "123", "key_expires_at__c": "2018-08-31T06:00:00.000Z", "token_expires_at__c": "2018-08-31T06:00:00.000Z", "token_expires_in__c": "15600000"}' + 
            ']', List<A1_C360API_Tokens__mdt>.class);
        Scheduler_A1C360APITokens.TEST_accessTokenMetadata = accessTokenMapping;

        Test.startTest();

		List<MultiRequestMock.MockDictionary> abList = new List<MultiRequestMock.MockDictionary>();
        responseHeaders.put('Content-Type', 'application/json');

        MultiRequestMock fakeResponses = new MultiRequestMock(abList);
        fakeResponses.addRequestMock(SYSTEM.LABEL.callout_A1_C360API_AuthEndPoint_token, 'GET', new SingleRequestMock(200, 'Complete', '{"access_token":"123", "token_type":"123","expires_in":123}', responseHeaders));
        fakeResponses.addRequestMock(SYSTEM.LABEL.callout_A1_C360API_AuthEndPoint_authentication_action_login, SYSTEM.LABEL.POST, new SingleRequestMock(200, 'Complete', '{"access_token":"123", "token_type":"123","expires_in":123}', responseHeaders));

        Test.setMock(HttpCalloutMock.class, fakeResponses);        
        Scheduler_A1C360APITokens.setC360APITokens();
        Integer callouts = Limits.getCallouts();
        Test.stopTest();
        system.assertEquals(0, callouts);
    }

}