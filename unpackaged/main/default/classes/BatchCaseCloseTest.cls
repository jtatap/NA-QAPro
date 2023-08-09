/*
Test Class for BatchCaseClose 
class Name : BatchCaseCloseTest
*/

@isTest(isParallel=false)
public class BatchCaseCloseTest {
    
    //setting Test Data
    /*private static void TestData()
    {
        Account genAcc = new Account();
        genAcc.Name = 'generic Account' + Math.random();
        insert genAcc;
        
        Contact genCon = new Contact();
        genCon.email = 'foo@example.com';
        genCon.lastName = 'generic contact ' + Math.random();
        genCon.AccountId = genAcc.id;
        genCon.Brand_Id__c='9';
        insert genCon;
		
        Contact errCon = new Contact();
        errCon.email = 'fooerror@example.com';
        errCon.Brand_Id__c='1';
        List<Contact> errContacts = new List<Contact>();
        errContacts.add(errCon);
        String sourceSystem='SFSC';
        String FileName = 'testname';
        Database.SaveResult[] results = Database.insert(errContacts, false);
        ContactUtility.createErrorLogRecords(results,sourceSystem,FileName);
        
        GenericRecords__c genRec = new GenericRecords__c(
                Name = Constants.privacyContactGenericRecordSettingName,
                recordId__c = genCon.Id
        );
        insert genRec;

        GenericRecords__c genRecAcct = new GenericRecords__c(
                Name = Constants.AccountGenericRecordSettingName,
                recordId__c = genAcc.Id
        );
        insert genRecAcct;
        DateTime dt = utilityClass.strYYYMMDDtoDateTime('2021-10-01T00:00:00Z');
        DateTime dt3 = utilityClass.strYYYMMDDtoDateTime('');
        Date dt1 = utilityClass.strYYYMMDDtoDate('');
        Date dt2 = utilityClass.strYYYMMDDtoDate('2021-10-01T00:00:00Z');
        String dummyAccount = utilityClass.generateRandomString(4);
        account acc = new account(name = dummyAccount);
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
        
    }*/
    
    
    @testSetup
    public static void testData() {
        List<Account> genAcc = TestDataFactory.createAccount(1);
        genAcc[0].Name = 'generic Account' + Math.random();
        insert genAcc;
        
        List<Contact> genCon = TestDataFactory.createContact(1);
        genCon[0].email = 'foo@example.com';
        genCon[0].lastName = 'generic contact ' + Math.random();
        genCon[0].AccountId = genAcc[0].id;
        genCon[0].Brand_Id__c='9';
        insert genCon;
        
        TestDataFactory.createGenericRecords(genAcc[0].Id);
        TestDataFactory.createGenericRecords(genCon[0].Id);
        
        List<Account> accLst = TestDataFactory.createAccount(1);
        insert accLst;
        
        List<Contact> conLst = TestDataFactory.createContact(1);
        conLst[0].AccountId = accLst[0].Id;
        conLst[0].email = 'test@test.com';
        conLst[0].lastName = 'generic contact ' + Math.random();
        conLst[0].Brand_Id__c = '1';
        insert conLst;
        
        List<Case> parentCaseLst = TestDataFactory.createCases(1);
        parentCaseLst[0].Type = 'Support';
        parentCaseLst[0].Status = 'New';
        parentCaseLst[0].ContactId=conLst[0].id;
        parentCaseLst[0].AccountId=accLst[0].id;
        parentCaseLst[0].Brand__c='1';
        parentCaseLst[0].SuppliedEmail='test@gmail.com';
        insert parentCaseLst;
        
        
        
        List<Case> cseLst = TestDataFactory.createCases(1);
        cseLst[0].Type = 'Support';
        cseLst[0].Is_Milestone_Violated__c = true;
        cseLst[0].ContactId=conLst[0].id;
        cseLst[0].AccountId=accLst[0].id;
        cseLst[0].Brand__c='1';
        cseLst[0].parentId = parentCaseLst[0].Id;
        cseLst[0].SuppliedEmail='test@gmail.com';
        insert cseLst; 
        
        Test.setCreatedDate(cseLst[0].Id, DateTime.newInstance(2019,06,06));
    }
    
    @isTest
    public static void runBatch() {
        Id SupportReadOnlyRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support_Case_Read_Only').getRecordTypeId();
        test.startTest();
        id BatchId = Database.executeBatch(new BatchCaseClose());
        test.stopTest();
        Case cse = [SELECT id,Status,RecordTypeId FROM Case WHERE parentId!=null];
        System.assertEquals(true, cse.Status == 'Closed');
        System.assertEquals(true, cse.RecordTypeId == SupportReadOnlyRecordId);
    }
    
}