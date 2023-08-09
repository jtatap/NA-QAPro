@isTest
public class Privacy_ProcessResponse_API_Test {

 static testmethod void testrestGet() {
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = 'https://privacy';

    req.addHeader('Content-Type', 'application/json');
    req.httpMethod = 'GET';
    req.requestBody = Blob.valueof('{}');

    RestContext.request = req;
    RestContext.response= res;


    Test.startTest();
    Privacy_ProcessResponse_API.restGet();
    Integer callouts = Limits.getCallouts();
    Test.stopTest();
    system.assertEquals(0, callouts);


 }
    
}