@isTest
public class WaitTime_Test {
    @isTest
    public static void testDataForWaitTime(){
        Long startTime = DateTime.now().getTime();
        Test.startTest();
        WaitTime.wait();
        Test.stopTest();
        Long finishTime = DateTime.now().getTime();
        System.assert(finishTime - startTime>10000);
    }

}