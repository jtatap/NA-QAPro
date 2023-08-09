/******************************************************************************
 * @Description: Test Class to test A1_PointsDataApexController
 * @Author      : Rounak P
 * @Date          : 09 JAN 2019
 * @JIRA          : NASSC-1146
 *
 ******************************************************************************/
@isTest
public class A1_PointsDataApexControllerTest{
    @TestSetup
    static void makeData(){
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
        listCases[0].PendingPointsAdjustment__c = false;
        listCases[0].Brand__c = '2';
        insert listCases;
    }

    @isTest
    static void checkPendingPointsStatusANDCaseRecordTest(){
        Test.startTest();
        Case getCase = [Select Id, PendingPointsAdjustment__c
                        from Case LIMIT 1];
        A1_PointsDataApexController.checkPendingPointsStatus(getCase.Id);
        A1_PointsDataApexController.getPoints(getCase.Id);
        System.assert(A1_PointsDataApexController.checkPendingPointsStatus(getCase.Id)!=null);
        System.assert(A1_PointsDataApexController.getPoints(getCase.Id)!=null);
        Test.stopTest();
    }

    @isTest
    static void checkContactRecordTest(){
        Test.startTest();
        List<Contact> listContact = TestDataFactory.createContact(1);
        List<Contact> listUpdateContact = new List<Contact>();
        for (Contact con : listContact){
            con.LoyaltyID__c = 'C0021733313';
            con.Brand_Id__c = '2';
            listUpdateContact.add(con);
        }

        insert listUpdateContact;
        Contact getContact = [Select Id, LoyaltyID__c, Brand_Id__c
                              from Contact LIMIT 1];
        A1_PointsDataApexController.getPoints(getContact.Id);
        System.assert(A1_PointsDataApexController.getPoints(getContact.Id)!=null);
        Test.stopTest();
    }
    
      @IsTest
    static void test234MethodTest(){
     A1_PointsDataApexController.test234Method();
     //repeat the same for the rest of classes.
  }  

}