@isTest
public class Batch_purgeIREStagingTableTest {
     //setting Test Data
    @testsetup()
    private static void TestData()
    {
        account acc = new account(name = 'DummyAccount');
        insert acc;
        
        contact con = new contact (lastname='Dummycontact' ,email='test@gmail.com',AccountId=acc.id,Brand_Id__c='1');
        insert con;
        
        IRE_StagingTable__c TestIRE  = new IRE_StagingTable__c(MasterCustomerId__c ='1234567',SubscriberKey__c=con.id,IREDeactivationDate__c=date.parse('01/01/2019'),	IREReactivationDate__c=date.parse('02/02/2019'));
        insert TestIRE;
        Test.setCreatedDate(TestIRE.Id, DateTime.newInstance(2019,06,06));
    }
    
    
    private static testmethod void Batchtest()
    {
        test.startTest();
        id BatchId = Database.executeBatch(new Batch_purgeIREStagingTable());
        test.stopTest();
        
    }
}