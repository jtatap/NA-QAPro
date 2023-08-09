@isTest(isParallel=false)
public class SchedulableBatch_IREStagingTableTest {
     @testsetup
    static void setup(){
        account acc = new account(name = 'DummyAccount');
        insert acc;
        
        contact con = new contact (lastname='Dummycontact' ,email='test@gmail.com',AccountId=acc.id,Brand_Id__c='1');
        insert con;
        
        IRE_StagingTable__c TestIRE  = new IRE_StagingTable__c(MasterCustomerId__c ='1234567',SubscriberKey__c=con.id,IREDeactivationDate__c=date.parse('01/01/2019'),  IREReactivationDate__c=date.parse('02/02/2019'));
        insert TestIRE;
        Test.setCreatedDate(TestIRE.Id, DateTime.newInstance(2019,06,06));
        
    }
    
    @isTest
    static void scheduleTest(){
        //Dummy CRON expression: midnight on July 25.
        // Because this is a test, job executes
        // immediately after Test.stopTest().
        String CRON_EXP = '0 0 0 25 9 ? 2023';
        Test.startTest();
        String jobId = System.schedule('SchedulableBatch_purgeIREStagingTable15',  CRON_EXP, new SchedulableBatch_purgeIREStagingTable());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest(); 
        ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals('2023-09-25 00:00:00', String.valueOf(ct.NextFireTime));
    }
}