@isTest
public class EmailPublisherLoaderTest {
    
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
    static void coverClass(){
        EmailPublisherLoader epl = new EmailPublisherLoader();
        
    }
    @isTest
    static void getTemplateIdHelperTest(){
        EmailPublisherLoader epl = new EmailPublisherLoader();
        epl.getTemplateIdHelper('Test');
    }
    
    @isTest
    static void getBccAddressTest(){
        EmailPublisherLoader epl = new EmailPublisherLoader();
        epl.getBccAddress('Technical');
        epl.getBccAddress('Billing');
        epl.getBccAddress('Test');
        
    }
    @isTest
    static void onInitDefaultsTest(){
        EmailPublisherLoader epl = new EmailPublisherLoader();
        List<Case> caseList = [SELECT Id from Case];
        //create QuickActionDefaults
        List<Map<String, Object>> defaultSettingAsObject = new List<Map<String, Object>>
        {
          new Map<String, Object>
          {
                'targetSObject' => new EmailMessage(),
                'contextId' => caseList[0].Id,
                'actionType' => 'SendEmail',
                'actionName' => 'Case.SendEmail',
                'fromAddressList' => new List<String> { 'salesforce@test.com' }
          }
        };

        List<QuickAction.SendEmailQuickActionDefaults> defaultsSettings = 
            (List<QuickAction.SendEmailQuickActionDefaults>)JSON.deserialize(JSON.serialize(defaultSettingAsObject), List<QuickAction.SendEmailQuickActionDefaults>.class);
        
        
        List<QuickAction.QuickActionDefaults> tempList = new List<QuickAction.QuickActionDefaults>();
        
        epl.onInitDefaults(defaultsSettings);
    }
}