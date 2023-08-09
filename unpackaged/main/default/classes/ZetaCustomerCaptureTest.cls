@isTest
private class ZetaCustomerCaptureTest {

    static testMethod void testSendCustomerData() {
        // Create test data
        Contact con = new Contact(FirstName='Test', LastName='User', Email='testuser@example.com', Brand_Id__c ='11');
        insert con;

        // Test the method
        Test.startTest();
        ZetaCustomerCapture.sendCustomerData(new List<Id> {con.Id});
        Test.stopTest();
    }


    static testMethod void testMakeCallOut() {
        // Create test data
        Contact con = new Contact(FirstName='Test', LastName='User', Email='testuser@example.com', Brand_Id__c ='11',Channel__c='6',Source__c='Web',Salutation__c='Mr',MiddleName='Test',MailingState='KA',MailingCity='Bangalore',MailingPostalCode='562125',MailingCountry='INDIA',
                                 HomePhone='8888888888',MobilePhone='8888888888',HomeStore__c='Test',StoreOfCapture__c='Test',Language__c='E');
        insert con;

        // Create a mock response
        String mockResponse = '{"ZetaGUID":"1234567890"}';
        HttpResponse res = new HttpResponse();
        res.setBody(mockResponse);
        res.setStatusCode(200);

        // Create a mock callout
        Test.setMock(HttpCalloutMock.class, new ZetaCustomerCaptureMock(res));

        Test.startTest();
        // Call the method and pass in the test contact ID
        ZetaCustomerCapture.makeCallOut(con.Id, '1234567890');
        Test.stopTest();
    }

    class ZetaCustomerCaptureMock implements HttpCalloutMock {
        HttpResponse res;
        public ZetaCustomerCaptureMock(HttpResponse res) {
            this.res = res;
        }
        public HTTPResponse respond(HTTPRequest req) {
            return res;
        }
    }

}