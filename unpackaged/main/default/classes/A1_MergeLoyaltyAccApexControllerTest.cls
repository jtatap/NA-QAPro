/******************************************************************************
 * @Description: Test Class for A1_MergeLoyaltyAccApexController
 * @Author      : Rounak P
 * @Date          : 25 Feb 2020
 * @JIRA          : NASSC-1472
 *
 ******************************************************************************/
@isTest
public class A1_MergeLoyaltyAccApexControllerTest{
    @TestSetup
    static void setupTestData(){
        Account genAcc = new Account();
        genAcc.Name = 'generic Account' + Math.random();
        insert genAcc;

        Contact genCon = new Contact();
        genCon.email = 'foo@example.com';
        genCon.lastName = 'generic contact ' + Math.random();
        genCon.AccountId = genAcc.id;
        genCon.Brand_Id__c = '9';
        insert genCon;

        GenericRecords__c genRec = new GenericRecords__c(Name = Constants.privacyContactGenericRecordSettingName, recordId__c = genCon.Id);
        insert genRec;

        GenericRecords__c genRecAcct = new GenericRecords__c(Name = Constants.AccountGenericRecordSettingName, recordId__c = genAcc.Id);
        insert genRecAcct;

        List<Contact> listContact = TestDataFactory.createContact(1);
        List<Contact> listUpdateContact = new List<Contact>();
        for (Contact con : listContact){
            con.LoyaltyID__c = 'C0021733313';
            con.Brand_Id__c = '2';
            listUpdateContact.add(con);
        }

        insert listUpdateContact;
        Contact getContact = [Select Id, LoyaltyID__c, Brand_Id__c
                              from Contact
                              WHERE LoyaltyId__c = 'C0021733313'];

        List<Case> listCases = TestDataFactory.createCases(1);
        listCases[0].contactId = getContact.Id;
        listCases[0].Brand__c = '2';
        insert listCases;
    }

    @isTest
    static void checkLoyalty(){
        Test.startTest();
        Case getCase = [Select Id
                        from Case];
        Boolean result = A1_MergeLoyaltyAccApexController.checkIsLoyaltyApplicable(getCase.Id);
        System.assert(result, 'returned result');
        Contact getContact = [Select Id, LoyaltyID__c, Brand_Id__c
                              from Contact
                              WHERE LoyaltyId__c = 'C0021733313'];

        Boolean result1 = A1_MergeLoyaltyAccApexController.checkIsLoyaltyApplicable(getContact.Id);
        Test.stopTest();
    }

}