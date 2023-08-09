/**
 * Created by venkatpenukonda on 2020-01-29.
 */

@IsTest
private class TriggeredSendTest {
    @IsTest
    static void testTriggeredSend() {
        Contact c1 = new Contact(tempEnableTriggeredSend__c=true, LastName='TestExample1',Brand_Id__c='1', Source_System__c = 'WiFi', EmailOptInStatus__c = 'Y');
        Contact c2 = new Contact(tempEnableTriggeredSend__c=true, LastName='TestExample2',Brand_Id__c='1', Source_System__c = 'ChargeItSpot', EmailOptInStatus__c = 'N');
        Test.startTest();
            insert c1;
        	insert c2;
            c2.EmailOptInStatus__c = 'N';
            update c2;
        Integer callouts = Limits.getCallouts();
        Test.stopTest();
        system.assertEquals(0, callouts);

    }
}