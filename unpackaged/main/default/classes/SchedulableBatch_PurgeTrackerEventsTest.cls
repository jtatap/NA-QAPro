@isTest
public class SchedulableBatch_PurgeTrackerEventsTest {
    
    @testsetup
    static void setup(){
    account acc = new account(name = 'DummyAccount');
        insert acc;
        
        contact con = new contact (lastname='Dummycontact' ,email='test@gmail.com',AccountId=acc.id,Brand_Id__c='1');
        insert con;
        
        TrackerEvents__c TestEvent  =new TrackerEvents__c(Customer__c =con.id);
        insert TestEvent;
        Test.setCreatedDate(TestEvent.Id, DateTime.newInstance(2019,06,06));

}
    
     @isTest
    static void scheduleTest(){
        //Dummy CRON expression: midnight on July 25.
        // Because this is a test, job executes
        // immediately after Test.stopTest().
        String CRON_EXP = '0 0 18 ? * 6L';
        Test.startTest();
        String jobId = System.schedule('SchedulableBatch_PurgeTrackerEvents'+System.currentTimeMillis()+'Test',  CRON_EXP, new SchedulableBatch_PurgeTrackerEvents());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        Test.stopTest(); 
        ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
    }
}