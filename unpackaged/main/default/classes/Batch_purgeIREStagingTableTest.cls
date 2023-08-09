@isTest
public class Batch_purgeIREStagingTableTest {
     //setting Test Data
    @testsetup()
    private static void TestData()
    {
        /*account acc = new account(name = 'DummyAccount');
        insert acc;
        
        contact con = new contact (lastname='Dummycontact' ,email='test@gmail.com',AccountId=acc.id,Brand_Id__c='1');
        insert con;*/
        
         List<Account> accLst = TestDataFactory.createAccount(1);
        Insert accLst;
        
        List<Contact> conLst = TestDataFactory.createContact(1);
        conLst[0].email = 'foo@example.com';
        conLst[0].lastName = 'generic contact ' + Math.random();
        conLst[0].AccountId = accLst[0].id;
        conLst[0].Brand_Id__c='1';
        Insert conLst;
        
        /*IRE_StagingTable__c TestIRE  = new IRE_StagingTable__c(MasterCustomerId__c ='1234567',SubscriberKey__c=con.id,IREDeactivationDate__c=date.parse('01/01/2019'),	IREReactivationDate__c=date.parse('02/02/2019'));
        insert TestIRE;*/
        
        IRE_StagingTable__c irsStagingTable = TestDataFactory.createIreStagingTable(conLst[0].Id);
        irsStagingTable.IREDeactivationDate__c = date.parse('01/01/2019');
        irsStagingTable.IREReactivationDate__c = date.parse('02/02/2019');
        insert irsStagingTable;
        
        Test.setCreatedDate(irsStagingTable.Id, DateTime.newInstance(2019,06,06));
    }
    
    
    private static testmethod void Batchtest()
    {
        test.startTest();
        id BatchId = Database.executeBatch(new Batch_purgeIREStagingTable());
        test.stopTest();
        List<IRE_StagingTable__c> ireStaging = [SELECT id FROM IRE_StagingTable__c];
        System.assertEquals(false, ireStaging.size() > 0);
        
    }
}