/*
Test Class for BatchCaseClose 
class Name : BatchCaseCloseTest
*/

@isTest
public class BatchCaseCloseTest {
    
    //setting Test Data
    private static void TestData()
    {
        
        account acc = new account(name = 'DummyAccount');
        insert acc;
        
        contact con = new contact (lastname='Dummycontact' ,email='test@gmail.com',Brand_Id__c = '1');
        insert con;
         
        case parentcase =new case(Type='Support',Status='New',SuppliedEmail='test@gmail.com',ContactId=con.id,AccountId=acc.id,Brand__c='1');
        insert parentcase; 
        
        case childcase  =new case(Type='Support', Status='New',SuppliedEmail='test@gmail.com',parentid = parentcase.id,Is_Milestone_Violated__c=true,
                                  ContactId=con.id,AccountId=acc.id,Brand__c='1');
        insert childcase;
        Test.setCreatedDate(childcase.Id, DateTime.newInstance(2019,06,06));
        
        
    }
    
    private static testmethod void Batchtest()
    {
        //calling Test Data Method
        TestData();
        test.startTest();
        id BatchId = Database.executeBatch(new BatchCaseClose());
        test.stopTest();
        
    }
    
}