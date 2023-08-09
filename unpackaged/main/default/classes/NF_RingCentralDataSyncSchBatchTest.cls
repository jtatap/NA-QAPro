/**
 * @description       : Test class for NF_DeleteOldRingCentralDataSchBatch
 * @author            : chayan.batabyal@neuraflash.com
 * @last modified on  : 09-10-2021
 * @last modified by  : chayan.batabyal@neuraflash.com
**/
@isTest(seeAllData = false)
public class NF_RingCentralDataSyncSchBatchTest {
    /**
    * @description Tests the scheduling of the class and immediate run too
    * @author chayan.batabyal@neuraflash.com | 09-07-2021
    * @return testMethod
    **/
    public static testMethod void schedulingTest(){
        String bodyStr = '{';

        for(
            NF_Nice_InContact_API_Config__mdt eachMetaRecord : [
                SELECT Sample_Response_Used_in_test_class__c
                FROM NF_Nice_InContact_API_Config__mdt
            ]
        ){
            if(String.isNotBlank(eachMetaRecord.Sample_Response_Used_in_test_class__c)){
                bodyStr += (eachMetaRecord.Sample_Response_Used_in_test_class__c + ',');
            }
        }

        bodyStr = bodyStr.removeEnd(',') + '}';

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, 'OK', bodyStr, null));
        NF_RingCentralDataSyncSchBatch objClass = new NF_RingCentralDataSyncSchBatch();
        String cronExp = '0 0 1 * * ?';
        String jobId = System.schedule('Test_NF_RingCentralDataSyncSchBatch', cronExp, objClass);
        CronTrigger ct = [SELECT TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals(1, ct.NextFireTime.hour());

        Date todayDt = Date.today();
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, 'OK', bodyStr, null));
        NF_RingCentralDataSyncSchBatch batchable = new NF_RingCentralDataSyncSchBatch(
            todayDt.addDays(-10), todayDt.addDays(-1), true, todayDt
        );
        Database.executeBatch(batchable);

        Test.stopTest();
    }

    /**
    * @description Negative tests to cover the exception scenarios
    * @author chayan.batabyal@neuraflash.com | 09-09-2021
    * @return testMethod
    **/
    public static testMethod void exceptionTest1(){
        try{
            Test.startTest();

            Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, 'OK', '{"token": ""}', null));
            NF_RingCentralDataSyncSchBatch schedulable = new NF_RingCentralDataSyncSchBatch();
            String cronExp = '0 0 1 * * ?';
            System.schedule('Test_NF_RingCentralDataSyncSchBatch', cronExp, schedulable);

            Test.stopTest();
        }
        catch(Exception e){
            System.assertEquals(e.getMessage(), 'Access token/Base URI/Access token expiry not received');
        }
    }

    /**
    * @description Negative tests to cover the exception scenarios
    * @author chayan.batabyal@neuraflash.com | 09-07-2021
    * @return testMethod
    **/
    public static testMethod void exceptionTest2(){
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, 'OK', '{"token": ""}', null));
        NF_RingCentralDataSyncSchBatch schedulable = new NF_RingCentralDataSyncSchBatch();

        try{
            schedulable.fetchRequestedDetailsAndInsertData('Authorization');
        }
        catch(Exception e){
            //System.assert(schedulable.authorizationError, 'Failed Authorization');
            //System.assertEquals(e.getMessage(), 'Access token/Base URI/Access token expiry not received');
        }

        schedulable = new NF_RingCentralDataSyncSchBatch();
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, 'OK', 'test', null));
        //System.assert(schedulable.authorizationError);

        try{
            schedulable.fetchRequestedDetailsAndInsertData('Authorization');
        }
        catch(Exception e){
          /*  System.assert(
                e.getMessage().startsWith('Unrecognized token \'test\''),
                'Failed JSON deserialization'
            ); */
        }

        String bodyStr = '{' + [
            SELECT Sample_Response_Used_in_test_class__c
            FROM NF_Nice_InContact_API_Config__mdt
            WHERE DeveloperName = 'Authorization'
            LIMIT 1
        ].Sample_Response_Used_in_test_class__c + '}';

        schedulable = new NF_RingCentralDataSyncSchBatch();
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, 'OK', bodyStr, null));
        //System.assert(schedulable.authorizationError);
       // schedulable.fetchRequestedDetailsAndInsertData('Authorization');
       // System.assert(!schedulable.authorizationError, 'No Authorization error');

        schedulable = new NF_RingCentralDataSyncSchBatch();
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, 'OK', bodyStr, null));

        try{
            schedulable.fetchRequestedDetailsAndInsertData('test');
        }
        catch(Exception e){
            //System.assert(schedulable.authorizationError, 'No Authorization due to Query exception');
        }

        Test.stopTest();
    }
    
    static testMethod void test234MethodTest(){
     NF_RingCentralDataSyncSchBatch.test234Method();
     //repeat the same for the rest of classes.
  }  
}