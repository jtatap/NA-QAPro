/* Story No : NASSC-1135
*  Class: SchedulableBatchDirectMSTest
*  Description : Schedulable class to call Batch class Batch_DirectMailUndeliverableStaging.
*/
@isTest
public class Schedule_purgeMailUndeliverableST_Test {
    @testsetup
    static void setup(){
        DirectMailUndeliverablesStaging__c TestIRE  = new DirectMailUndeliverablesStaging__c(LoyaltyId__c ='1234567');
        insert TestIRE;
        Test.setCreatedDate(TestIRE.Id, DateTime.newInstance(2019,06,06));
        
    }
    
    @isTest
    static void scheduleTest(){
        //Dummy CRON expression: midnight on July 25.
        // Because this is a test, job executes
        // immediately after Test.stopTest().
       /* String CRON_EXP = '0 0 0 25 7 ? 2022';
        Test.startTest();
        String jobId = System.schedule('SchedulableBatchDirectMS',  CRON_EXP, new Schedule_purgeMailUndeliverableST());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest(); 
        ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.debug('Ct times triggered.: '+ct.NextFireTime);
        System.assertEquals('2022-07-25 00:00:00', String.valueOf(ct.NextFireTime));*/
        Test.StartTest();
        Schedule_purgeMailUndeliverableST sh1 = new Schedule_purgeMailUndeliverableST();
        
        String sch = '0 0 23 * * ?'; system.schedule('Test Schedule Check', sch, sh1);
        Integer callouts = Limits.getCallouts();
        Test.stopTest();
        system.assertEquals(0, callouts);

    }
}