/******************************************************************************
 * @Description: Test Class to test A1_RewardsDataApexController
 * @Author      : Rounak P
 * @Date          : 26:12.2019
 * @JIRA          : NASSC-1176,1178,1180
 *
 ******************************************************************************/
@isTest
public class A1_RewardsDataApexControllerTest{
    @TestSetup
    static void makeData(){
        List<Reward__c> listRewards = TestDataFactory.createRewards(1);
        List<Reward__c> listRewardsUpdated = new List<Reward__c>();
        for (Reward__c rew : listRewards){
            rew.ExpireDate__c = System.now();
            listRewardsUpdated.add(rew);
        }
        insert listRewardsUpdated;

        List<Contact> listContact = TestDataFactory.createContact(1);
        List<Contact> listUpdateContact = new List<Contact>();
        for (Contact con : listContact){
            con.LoyaltyID__c = 'C0021733313';
            con.Brand_Id__c = '2';
            listUpdateContact.add(con);
        }

        insert listUpdateContact;

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

        Contact getContact = [Select Id, LoyaltyID__c, Brand_Id__c
                              from Contact
                              WHERE LoyaltyId__c = 'C0021733313'];
        List<Case> listCases = TestDataFactory.createCases(1);
        listCases[0].contactId = getContact.Id;
        insert listCases;
    }

    @isTest
    static void checkOnContact(){
        Test.startTest();
        Contact getContact = [Select Id, LoyaltyID__c, Brand_Id__c
                              from Contact LIMIT 1];

        A1_RewardsDataApexController.getLoyaltyId(getContact.Id);
        System.assert(A1_RewardsDataApexController.getLoyaltyId(getContact.Id)!=null);
        Test.stopTest();
    }

    @isTest
    static void checkOnCase(){
        Test.startTest();
        Case getCase = [Select Id
                        from Case];
        A1_RewardsDataApexController.getLoyaltyId(getCase.Id);
        System.assert(A1_RewardsDataApexController.getLoyaltyId(getCase.Id)!=null);
        Test.stopTest();
    }

}