/**
* @author Magnet360
* @date 2019
*
* @group Case
* @group-content ../../ApexDocContent/Case.htm
*
* @description Test Class For Case Queue Handler
*/
@isTest
public class PrivacyCaseQueueHandlerTests {
    static void makeData(){

        SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                         'Complete',
                                         '[{"ResponseMessage":"NEW CUSTOMER","EmailAddress":"test@test.com"}]',
                                         null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        OrgWideEmailAddress owa = [Select DisplayName From OrgWideEmailAddress Limit 1];
        
        Account brandAccount = new Account();
        brandAccount.Name = 'Calvin Klein';
        brandAccount.RecordTypeId = Constants.brandRecordTypeId;
        brandAccount.Brand_Image_Link__c = 'foo.bar';
        brandAccount.Brand_Privacy_Form_Link__c = 'boo.far';
        brandAccount.Brand_Privacy_OWA_Name__c = owa.DisplayName;
        brandAccount.Privacy_Escalation_Email__c = 'foo@example.com';
        insert brandAccount;

        Account acc = new Account();
        acc.Name = 'generic Account';
        insert acc;

        Contact con = new Contact();
        con.email = 'foo@example.com';
        con.lastName = 'generic contact';
        con.AccountId = acc.id;
        con.Brand_Id__c = '1';
        insert con;

        GenericRecords__c genRec = new GenericRecords__c(
            Name = Constants.privacyContactGenericRecordSettingName,
            recordId__c = con.Id
        );
        insert genRec;
        
    }

    @isTest
    public static void test_invocable_send_to_omni() {
        makeData();
        try {
            Group testGroup = new Group(Name = 'Foo', DeveloperName=Constants.lowPriorityPrivacyCaseQueue, Type='Queue');
            insert testGroup;

            System.runAs(new User(Id=UserInfo.getUserId()))
            {
                QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
                insert testQueue;
            }
        } catch(Exception e) {
            System.debug('===group already exists');
        }
        Group existingGroup = [Select Id, DeveloperName, Name From Group Where DeveloperName=:Constants.lowPriorityPrivacyCaseQueue AND Type='Queue'];
        System.debug('===existingGroup? ' + existingGroup);

        Case cse = new Case();
        cse.SuppliedEmail = 'foo@example.com';
        cse.SuppliedName = 'the submitter';
        cse.Type = Constants.privacyCaseType;
        cse.Sub_Type__c = Constants.accessRequestSubType;
        cse.Brand__c = '2';
        cse.RecordTypeId = Constants.privacyRecordTypeId;
        insert cse;
        
         
        Test.startTest();
        PrivacyCaseQueueHandler.invocablePrivacyQueueAssignment(new List<Case>{cse});

        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();
        system.assertEquals(0, invocations);

    }
    
     @isTest
    public static void test_invocable_send_to_omni1() {
        makeData();
        try {
            Group testGroup = new Group(Name = 'Foo', DeveloperName=Constants.lowPriorityPrivacyCaseQueue, Type='Queue');
            insert testGroup;

            System.runAs(new User(Id=UserInfo.getUserId()))
            {
                QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
                insert testQueue;
            }
        } catch(Exception e) {
            System.debug('===group already exists');
        }
        Group existingGroup = [Select Id, DeveloperName, Name From Group Where DeveloperName=:Constants.lowPriorityPrivacyCaseQueue AND Type='Queue'];
        System.debug('===existingGroup? ' + existingGroup);

        Case cse1 = new Case();
        cse1.SuppliedEmail = 'foo@example.com';
        cse1.SuppliedName = 'the submitter';
        cse1.Type = Constants.privacyCaseType;
        cse1.Sub_Type__c = Constants.deletionRequestSubType;
        cse1.State_of_Residence__c='California';
        cse1.Brand__c = '2';
        cse1.RecordTypeId = Constants.privacyRecordTypeId;
        insert cse1;
        
         
        Test.startTest();
        PrivacyCaseQueueHandler.invocablePrivacyQueueAssignment(new List<Case>{cse1});

        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();
        system.assertEquals(0, invocations);

    }
     @isTest
    public static void test_invocable_send_to_omni2() {
        makeData();
        try {
            Group testGroup = new Group(Name = 'Foo', DeveloperName=Constants.lowPriorityPrivacyCaseQueue, Type='Queue');
            insert testGroup;

            System.runAs(new User(Id=UserInfo.getUserId()))
            {
                QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
                insert testQueue;
            }
        } catch(Exception e) {
            System.debug('===group already exists');
        }
        Group existingGroup = [Select Id, DeveloperName, Name From Group Where DeveloperName=:Constants.lowPriorityPrivacyCaseQueue AND Type='Queue'];
        System.debug('===existingGroup? ' + existingGroup);

        Case cse2 = new Case();
        cse2.SuppliedEmail = 'foo@example.com';
        cse2.SuppliedName = 'the submitter';
        //cse2.Type = Constants.privacyCaseType;
       // cse2.Sub_Type__c = Constants.deletionRequestSubType;
        cse2.State_of_Residence__c='California';
       // cse1.Brand__c = '2';
        cse2.RecordTypeId = Constants.privacyRecordTypeId;
        insert cse2;
        
         
        Test.startTest();
        PrivacyCaseQueueHandler.invocablePrivacyQueueAssignment(new List<Case>{cse2});

        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();
        system.assertEquals(0, invocations);

    }


}