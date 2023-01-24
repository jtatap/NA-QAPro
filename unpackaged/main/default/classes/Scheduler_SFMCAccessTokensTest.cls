@isTest
public class Scheduler_SFMCAccessTokensTest {
	static Map<String, String> responseHeaders = new Map<String, String>(); 
    
	@isTest(SeeAllData=true) 
    public static void getSFMCAccessTokenTest(){
        
        responseHeaders.put('Content-Type','application/json');
        SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                                 'Complete',
                                                 '{"access_token":"ecdc4492-8a1c-4f03-b9ad-6b9db87f61a1","expires_in":15445210}',
                                                 responseHeaders);
        
        System.debug('*** fake response = '+fakeResponse);
        Test.setMock(HttpCalloutMock.class, fakeResponse);        
        Scheduler_SFMCAccessTokens.getSFMCAccessToken();
        CKScheduler_SFMCAccessTokens.getSFMCAccessToken();
    }
}