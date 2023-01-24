/*
Test Class for Batch_PurgeTrackerEvents 
class Name : Batch_PurgeTrackerEventsTest
*/

@isTest
public class Batch_PurgeTrackerEventsTest {
    
    //setting Test Data
    private static void TestData()
    {
        
        account acc = new account(name = 'DummyAccount');
        insert acc;
        
        contact con = new contact (lastname='Dummycontact' ,email='test@gmail.com',AccountId=acc.id,Brand_Id__c='1');
        insert con;
        
        TrackerEvents__c TestEvent  =new TrackerEvents__c(Customer__c =con.id);
        insert TestEvent;
        Test.setCreatedDate(TestEvent.Id, DateTime.newInstance(2019,06,06));
        
        
    }
    
    private static testmethod void Batchtest()
    {
        //calling Test Data Method
        TestData();
        test.startTest();
        id BatchId = Database.executeBatch(new Batch_PurgeTrackerEvents());
        test.stopTest();
        
    }
}