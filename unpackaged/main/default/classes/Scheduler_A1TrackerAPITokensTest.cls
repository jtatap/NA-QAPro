@isTest
public class Scheduler_A1TrackerAPITokensTest {
    
    static Map<String, String> responseHeaders = new Map<String, String>(); 
    
	@isTest(SeeAllData=true) 
    public static void setA1TrackerAPITokensTest(){
        
        responseHeaders.put('Content-Type', 'application/json');
        SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                                 'Complete',
                                                 '{"access_token":"ecdc4492-8a1c-4f03-b9ad-6b9db87f61a1","token_type":"bearer","expires_in":15445210}',
                                                 responseHeaders);
        
        Test.setMock(HttpCalloutMock.class, fakeResponse);        
        Scheduler_A1TrackerAPITokens.setTrackerAPITokens();
    }

    @isTest(SeeAllData=true) 
     public static void setCA1TrackerAPITokensPostTest(){   
         
        responseHeaders.put('Content-Type', 'application/json');
        SingleRequestMock fakeResponse = new SingleRequestMock(100,
                                                 'Complete',
                                                 '{"access_token":"ecdc4492-8a1c-4f03-b9ad-6b9db87f61a1","token_type":"bearer","expires_in":15445210}',
                                                 responseHeaders);
         
        Test.setMock(HttpCalloutMock.class, fakeResponse);  
        Scheduler_A1TrackerAPITokens.setTrackerAPITokens(); 
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
        Test.stopTest(); 
 
    }
}