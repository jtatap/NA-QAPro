@isTest(isParallel=false)
public class Schedule_Batch_SAPStoreCodeUpdateTest {

    public static testMethod void testschedule() {

        Test.StartTest();
        Schedule_Batch_SAPStoreCodeUpdate sh1 = new Schedule_Batch_SAPStoreCodeUpdate();
        
        String sch = '0 0 23 * * ?'; system.schedule('Test Schedule Check', sch, sh1); 
        Test.stopTest(); 
    }
            
}