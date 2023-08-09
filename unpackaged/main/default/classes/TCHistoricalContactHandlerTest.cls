@isTest
public class TCHistoricalContactHandlerTest {
    /*@isTest
    public static void testTCcontactTriggerUpdate() {

        // Create test data for Account 
        Account acc = new Account(Name = 'Test Parent Account');
        insert acc;

        RecordType emailRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Contact' AND DeveloperName = 'Email'];
        Contact con1 = new Contact(LastName = 'Test1', Email = 'test1@example.com', Brand_Id__c = '11', CreatedDate = system.today(), AccountId = acc.Id, RecordTypeId = emailRecordType.Id);
        Contact con2 = new Contact(LastName = 'Test2', Email = 'test2@example.com', Brand_Id__c = '11', CreatedDate = system.today(), AccountId = acc.Id, RecordTypeId = emailRecordType.Id);
        Contact con3 = new Contact(LastName = 'Test3', Email = 'test3@example.com', Brand_Id__c = '11', CreatedDate = system.today(), AccountId = acc.Id, RecordTypeId = emailRecordType.Id);

        Contact existingCon1 = new Contact(LastName = 'ExistTest1', Email = 'test1@example.com', Brand_Id__c = '11', AccountId = acc.Id, RecordTypeId = emailRecordType.Id);
        insert existingCon1;
        Test.setCreatedDate(existingCon1.Id, System.now().addDays(-10));
        // Create test data for Record Type

        set<ID> conListID = new set<ID>();
        conListID.add(con1.Id);
        conListID.add(con2.Id);
        conListID.add(con3.Id);

        // Call the method and pass test data
        TCHistoricalContactHandler.TCcontactTriggerUpdate(conListID);
    }*/
    @isTest
    static void test1(){
        TCHistoricalContactHandler tch = new TCHistoricalContactHandler();
    }
}