@isTest
public class Batch_purgeMailUndeliverableST_Test {
    //setting Test Data
    @testsetup()
    private static void TestData()
    {
        account acc = new account(name = 'DummyAccount');
        insert acc;
        
        contact con = new contact (lastname='Dummycontact' ,Brand_Id__c='2',email='test@gmail.com',AccountId=acc.id,LoyaltyID__c='1234567',DirectMailUndeliverable__c=false);
        insert con;
        
        DirectMailUndeliverablesStaging__c TestIRE  = new DirectMailUndeliverablesStaging__c(LoyaltyId__c ='1234567');
        insert TestIRE;
        Test.setCreatedDate(TestIRE.Id, DateTime.newInstance(2019,06,06));
    }
    
    
    private static testmethod void Batchtest()
    {
        test.startTest();
        id BatchId = Database.executeBatch(new Batch_purgeMailUndeliverableST());
        test.stopTest();
        
    }
}