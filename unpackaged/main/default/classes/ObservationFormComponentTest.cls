@isTest()
public class ObservationFormComponentTest {
@isTest()
    static void testGetCaseOrigin(){
        Account genAcc = new Account();
        genAcc.Name = 'generic Account' + Math.random();
        insert genAcc;

        Contact genCon = new Contact();
        genCon.email = 'foo@example.com';
        genCon.lastName = 'generic contact ' + Math.random();
        genCon.AccountId = genAcc.id;
        genCon.Brand_Id__c='9';
        insert genCon;
        
        GenericRecords__c genRec = new GenericRecords__c(
                Name = Constants.privacyContactGenericRecordSettingName,
                recordId__c = genCon.Id
        );
        insert genRec;
        
        List<Case> caseList = TestDataFactory.createCases(1);
        Case cse = caseList[0];
        
        insert cse;
        
        Test.startTest();
        ObservationFormComponentApexController.getCaseOrigin(cse.Id);
        cse.Origin = 'Phone';
        //cse.Brand__c = '10';
        update cse;
        ObservationFormComponentApexController.getCaseOrigin(cse.Id);

        Test.stopTest();
    }
}