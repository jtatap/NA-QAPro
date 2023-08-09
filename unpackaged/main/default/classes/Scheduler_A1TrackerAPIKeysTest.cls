@isTest
public class Scheduler_A1TrackerAPIKeysTest {
	static Map<String, String> responseHeaders = new Map<String, String>();    
    @isTest(SeeAllData=true) 
    public static void setC360APITokensTest(){
        Test.startTest();
        responseHeaders.put('Content-Type', 'application/json');
        SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                                 'Complete',
                                                 '{"token":"ecdc4492-8a1c-4f03-b9ad-6b9db87f61a1","key":"werterty"}',
                                                 responseHeaders);
        
        Test.setMock(HttpCalloutMock.class, fakeResponse);   
        Scheduler_A1TrackerAPIKeys.setTrackerAPIKeys();
        Integer callouts = Limits.getCallouts();
        Test.stopTest();
        system.assertEquals(0, callouts);
    }
    
}