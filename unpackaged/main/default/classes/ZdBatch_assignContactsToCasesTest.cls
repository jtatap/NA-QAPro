@isTest
private class ZdBatch_assignContactsToCasesTest {
    static testMethod void testAssignContactsToCases() {
        // Create test data
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

        GenericRecords__c genRecAcct = new GenericRecords__c(
                Name = Constants.AccountGenericRecordSettingName,
                recordId__c = genAcc.Id
        );
        insert genRecAcct;

        Contact con1 = new Contact(ZdTnCUserId__c = 'user1', ZdPVHUserId__c = 'user1', LastName='Test');
        Contact con2 = new Contact(ZdTnCUserId__c = 'user2', ZdPVHUserId__c = 'user2', LastName='Test');
        insert con1;
        insert con2;
        Case case1 = new Case(ZdTnCTicketId__c = 'ticket1', ZdTnCUserId__c = 'user1', ContactId = null, AccountId = null);
        Case case2 = new Case(ZdPVHTicketId__c = 'ticket2', ZdPVHUserId__c = 'user2', ContactId = null, AccountId = null);
        insert case1;
        insert case2;

        // Create a new instance of the batch class and run the test
        Test.startTest();
        ZdBatch_assignContactsToCases batch = new ZdBatch_assignContactsToCases();
        ID batchId = Database.executeBatch(batch);
        Test.stopTest();

        // Verify the results
        List<Case> updatedCases = [SELECT Id, ContactId, AccountId FROM Case WHERE Id IN :new List<Id>{case1.Id, case2.Id}];
        for (Case c : updatedCases) {
            System.assertNotEquals(null, c.ContactId);
            System.assertNotEquals(null, c.AccountId);
        }
    }
}