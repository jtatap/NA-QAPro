@isTest
private class ZetaCustomerCaptureQueueableTest {
    static testMethod void testZetaCustomerCapture() {
        // Create test data
        Contact con = new Contact(FirstName='Test', LastName='User', Email='testuser@example.com', Brand_Id__c ='11');
        insert con;

        // Create a mock response
        ZetaCustomerCaptureMock mock = new ZetaCustomerCaptureMock();
        Test.setMock(HttpCalloutMock.class, mock);

        // Create a new instance of the queueable class and run the test
        Test.startTest();
        ZetaCustomerCaptureQueueable queueable = new ZetaCustomerCaptureQueueable(con.Id, '1234567890');
        System.enqueueJob(queueable);
        Test.stopTest();

    }

    class ZetaCustomerCaptureMock implements HttpCalloutMock {
        // Implement the interface methods
        public HttpResponse respond(HttpRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('Mock callout response');
            return res;
        }
    }
}