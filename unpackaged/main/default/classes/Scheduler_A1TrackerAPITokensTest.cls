@isTest
public class Scheduler_A1TrackerAPITokensTest {
    
    static Map<String, String> responseHeaders = new Map<String, String>(); 
    
	@isTest(SeeAllData=false) 
    public static void setA1TrackerAPITokensTest(){
        Test.startTest();
        responseHeaders.put('Content-Type', 'application/json');
        SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                                 'Complete',
                                                 '{"access_token":"ecdc4492-8a1c-4f03-b9ad-6b9db87f61a1","token_type":"bearer","expires_in":15445210}',
                                                 responseHeaders);
        
        Test.setMock(HttpCalloutMock.class, fakeResponse);        
        Scheduler_A1TrackerAPITokens.setTrackerAPITokens();
        Integer callouts = Limits.getCallouts();
        Test.stopTest();
        system.assertEquals(0, callouts);

    }

    @isTest(SeeAllData=false) 
     public static void setCA1TrackerAPITokensPostTest(){   
        Test.startTest();
        responseHeaders.put('Content-Type', 'application/json');
        SingleRequestMock fakeResponse = new SingleRequestMock(100,
                                                 'Complete',
                                                 '{"access_token":"ecdc4492-8a1c-4f03-b9ad-6b9db87f61a1","token_type":"bearer","expires_in":15445210}',
                                                 responseHeaders);
         
        Test.setMock(HttpCalloutMock.class, fakeResponse);  
        Scheduler_A1TrackerAPITokens.setTrackerAPITokens();
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
        Scheduler_A1TrackerAPITokens.setTrackerAPITokens();
        Scheduler_A1TrackerAPITokens at = new Scheduler_A1TrackerAPITokens();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test c360', sch, at);
        Integer callouts = Limits.getCallouts();
        Test.stopTest();
        system.assertEquals(0, callouts);
    }

    @isTest(SeeAllData=false) 
    public static void setA1TrackerAPITokensTestRetry(){
        Test.startTest();
        responseHeaders.put('Content-Type', 'application/json');
        SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                                 'Complete',
                                                 '{"access_token":"ecdc4492-8a1c-4f03-b9ad-6b9db87f61a1","token_type":"bearer","expires_in":15445210}',
                                                 responseHeaders);
        
        Test.setMock(HttpCalloutMock.class, fakeResponse);        
        Scheduler_A1TrackerAPITokens.setTrackerAPITokens();
        Integer callouts = Limits.getCallouts();
        Test.stopTest();
        system.assertEquals(0, callouts);

    }

    @isTest
    public static void testCalloutMethod() {
        Test.startTest();
        responseHeaders.put('Content-Type', 'application/json');
        SingleRequestMock fakeResponse = new SingleRequestMock(100,
                                                 'Complete',
                                                 '{"access_token":"ecdc4492-8a1c-4f03-b9ad-6b9db87f61a1","token_type":"bearer","expires_in":15445210}',
                                                 responseHeaders);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        HttpResponse res = Scheduler_A1TrackerAPITokens.httpCalloutMethod(SYSTEM.LABEL.callout_A1_TrackerAPI_AuthEndPointCreate, 'test', 'GET');
        System.debug(res);
        Test.stopTest();
    }


	@isTest(SeeAllData=false) 
    public static void setA1TrackerAPITokensTestCustomMdt(){
        List<A1_TrackerAPI_creds__mdt> credMapping = (List<A1_TrackerAPI_creds__mdt>) Json.deserialize(
            '[' + 
                '{"Id": "123", "MasterLabel": "123", "Base64__c": "123", "BrandId__c": "123", "Password__c": "123", "Username__c": "123", "TenantId__c": "123", "DeveloperName": "123"}' + 
            ']', List<A1_TrackerAPI_creds__mdt>.class);
        

        List<A1_TrackerAPI_tokens__mdt> accessTokenMapping = (List<A1_TrackerAPI_tokens__mdt>) Json.deserialize(
            '[' + 
                '{"Id": "123", "access_key__c": "123", "access_token__c": "123", "BrandId__c": "123", "key_expires_at__c": "2018-08-31T06:00:00.000Z", "token_expires_at__c": "2018-08-31T06:00:00.000Z", "token_expires_in__c": "15600000"}' + 
            ']', List<A1_TrackerAPI_tokens__mdt>.class);
        Test.startTest();


        responseHeaders.put('Content-Type', 'application/json');
        SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                                 'Complete',
                                                 '{"access_token":"ecdc4492-8a1c-4f03-b9ad-6b9db87f61a1","token_type":"bearer","expires_in":15445210}',
                                                 responseHeaders);
        
        Test.setMock(HttpCalloutMock.class, fakeResponse);        
        Scheduler_A1TrackerAPITokens.setTrackerAPITokens();
        Integer callouts = Limits.getCallouts();
        Test.stopTest();
        system.assertEquals(0, callouts);
    }


    @isTest
    public static void setA1TrackerAPITokensTestCustomMdt_extCall(){
        List<A1_TrackerAPI_creds__mdt> credMapping = (List<A1_TrackerAPI_creds__mdt>) Json.deserialize(
            '[' + 
                '{"Id": "123", "MasterLabel": "123", "Base64__c": "123", "BrandId__c": "123", "Password__c": "123", "Username__c": "123", "TenantId__c": "123", "DeveloperName": "123"}' + 
            ']', List<A1_TrackerAPI_creds__mdt>.class);

        List<A1_TrackerAPI_tokens__mdt> accessTokenMapping = (List<A1_TrackerAPI_tokens__mdt>) Json.deserialize(
            '[' + 
                '{"Id": "123", "access_key__c": "123", "access_token__c": "123", "BrandId__c": "123", "key_expires_at__c": "2018-08-31T06:00:00.000Z", "token_expires_at__c": "2018-08-31T06:00:00.000Z", "token_expires_in__c": "15600000"}' + 
            ']', List<A1_TrackerAPI_tokens__mdt>.class);
      
        Test.startTest();


        responseHeaders.put('Content-Type', 'application/json');

        MultiRequestMock fakeResponses = new MultiRequestMock();
        fakeResponses.addRequestMock('callout:A1_TrackerAPI_AuthEndPoint', 'GET', new SingleRequestMock(200, 'Complete', '{"access_token":"123", "token_type":"123","expires_in":123}', responseHeaders));
        fakeResponses.addRequestMock(SYSTEM.LABEL.callout_A1_TrackerAPI_AuthEndPointCreate, SYSTEM.LABEL.POST, new SingleRequestMock(200, 'Complete', '{"access_token":"123", "token_type":"123","expires_in":123}', responseHeaders));

        Test.setMock(HttpCalloutMock.class, fakeResponses);        
        Scheduler_A1TrackerAPITokens.setTrackerAPITokens();
        Integer callouts = Limits.getCallouts();
        Test.stopTest();
        system.assertEquals(0, callouts);
    }


    @isTest
    public static void setA1TrackerAPITokensTestCustomMdt_extCallFail(){
        List<A1_TrackerAPI_creds__mdt> credMapping = (List<A1_TrackerAPI_creds__mdt>) Json.deserialize(
            '[' + 
                '{"Id": "123", "MasterLabel": "123", "Base64__c": "123", "BrandId__c": "123", "Password__c": "123", "Username__c": "123", "TenantId__c": "123", "DeveloperName": "123"}' + 
            ']', List<A1_TrackerAPI_creds__mdt>.class);

        List<A1_TrackerAPI_tokens__mdt> accessTokenMapping = (List<A1_TrackerAPI_tokens__mdt>) Json.deserialize(
            '[' + 
                '{"Id": "123", "access_key__c": "123", "access_token__c": "123", "BrandId__c": "123", "key_expires_at__c": "2018-08-31T06:00:00.000Z", "token_expires_at__c": "2018-08-31T06:00:00.000Z", "token_expires_in__c": "15600000"}' + 
            ']', List<A1_TrackerAPI_tokens__mdt>.class);
        Test.startTest();


        responseHeaders.put('Content-Type', 'application/json');

        MultiRequestMock fakeResponses = new MultiRequestMock();
        fakeResponses.addRequestMock('callout:A1_TrackerAPI_AuthEndPoint', 'GET', new SingleRequestMock(405, 'Complete', '{"access_token":"123", "token_type":"123","expires_in":123}', responseHeaders));
        fakeResponses.addRequestMock(SYSTEM.LABEL.callout_A1_TrackerAPI_AuthEndPointCreate, SYSTEM.LABEL.POST, new SingleRequestMock(200, 'Complete', '{"access_token":"123", "token_type":"123","expires_in":123}', responseHeaders));

        Test.setMock(HttpCalloutMock.class, fakeResponses);        
        Scheduler_A1TrackerAPITokens.setTrackerAPITokens();
        Integer callouts = Limits.getCallouts();
        Test.stopTest();
        system.assertEquals(0, callouts);
    }
    
    @isTest
    public static void setA1TrackerAPITokensTestCustomMdt_extCallFail1(){
        List<A1_TrackerAPI_creds__mdt> credMapping = (List<A1_TrackerAPI_creds__mdt>) Json.deserialize(
            '[' + 
                '{"Id": "123", "MasterLabel": "123", "Base64__c": "123", "BrandId__c": "123", "Password__c": "123", "Username__c": "123", "TenantId__c": "123", "DeveloperName": "123"}' + 
            ']', List<A1_TrackerAPI_creds__mdt>.class);

        List<A1_TrackerAPI_tokens__mdt> accessTokenMapping = (List<A1_TrackerAPI_tokens__mdt>) Json.deserialize(
            '[' + 
                '{"Id": "123", "access_key__c": "123", "access_token__c": "123", "BrandId__c": "123", "key_expires_at__c": "2018-08-31T06:00:00.000Z", "token_expires_at__c": "2018-08-31T06:00:00.000Z", "token_expires_in__c": "15600000"}' + 
            ']', List<A1_TrackerAPI_tokens__mdt>.class);
        Test.startTest();


        responseHeaders.put('Content-Type', 'application/json');

        MultiRequestMock fakeResponses = new MultiRequestMock();
        fakeResponses.addRequestMock('callout:A1_TrackerAPI_AuthEndPoint', 'GET', new SingleRequestMock(405, 'Complete', '{"access_token":"123", "token_type":"123","expires_in":123}', responseHeaders));
        fakeResponses.addRequestMock(SYSTEM.LABEL.callout_A1_TrackerAPI_AuthEndPointCreate, SYSTEM.LABEL.POST, new SingleRequestMock(200, 'Complete', '{"access_token":"123", "token_type":"123","expires_in":123}', responseHeaders));

        Test.setMock(HttpCalloutMock.class, fakeResponses);        
        Scheduler_A1TrackerAPITokens.setTrackerAPITokens();
        Integer callouts = Limits.getCallouts();
        Test.stopTest();
        system.assertEquals(0, callouts);
    }
}