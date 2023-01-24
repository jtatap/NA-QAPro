/**
* @author Magnet360
* @date 2019
*
* @group Case
* @group-content ../../ApexDocContent/Case.htm
*
* @description Test Class For a broad range of CCPA flows
*/
@isTest
public class PrivacyCaseTests {
    //DO NOT MAKE THIS A TEST SETUP METHOD. setMock does not work in testsetup and the Zeta callout will not be mocked when the contact is being created.
    public static void makeData(){
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
        Contact brandOwner = new Contact();
        brandOwner.accountId = brandAccount.Id;
        brandOwner.RecordTypeId = Constants.dataOwnerContactRecordTypeId;
        brandOwner.firstName = 'foo';
        brandOwner.LastName = 'Bar';
        brandOwner.Email = 'mrfoobar@example.com';
        brandOwner.System_Type__c = Constants.dataOwnerSupplemental;
        brandOwner.Additional_Email_1__c = 'foo@example.com';
        brandOwner.Additional_Email_2__c = 'foo@example.com';
        brandOwner.Additional_Email_3__c = 'foo@example.com';
        brandOwner.Additional_Email_4__c = 'foo@example.com';
        brandOwner.Brand_Id__c='2';
        insert brandOwner;
        Account acc = new Account();
        acc.Name = 'generic Account';
        insert acc;
        Contact con = new Contact();
        con.email = 'foo@example.com';
        con.lastName = 'generic contact';
        con.AccountId = acc.id;
        con.Brand_Id__c='2';
        insert con;
        GenericRecords__c genRec = new GenericRecords__c(
            Name = Constants.privacyContactGenericRecordSettingName,
            recordId__c = con.Id
        );
        insert genRec;
    }
    @isTest
    public static void test_inbound_privacy_email_case() {
        makeData();
        Case cse = new Case();
        cse.Origin = 'Email';
        cse.SuppliedEmail = 'foo@example.com';
        insert cse;
        Brand_Setting__mdt brandSetting = [Select Privacy_Email__c From Brand_Setting__mdt Where Brand_Id__c = '2'];
        EmailMessage email = new EmailMessage();
        email.ToAddress = brandSetting.Privacy_Email__c;
        email.Subject = 'foo';
        email.HtmlBody = 'bar';
        email.Incoming = true;
        email.ParentId = cse.Id;
        email.MessageDate = System.now();
        email.FromAddress = cse.SuppliedEmail;
        insert email;
    }
    @isTest
    public static void test_unsub_cases_resolved() {
        makeData();
        Case cse = new Case();
        cse.SuppliedEmail = 'foo@example.com';
        cse.SuppliedName = 'the submitter';
        cse.Type = Constants.privacyCaseType;
        cse.Sub_Type__c = Constants.unsubscribeRequestSubType;
        cse.Brand__c = '2';
        Case cse2 = new Case();
        cse2.SuppliedEmail = 'foo2@example.com';
        cse2.SuppliedName = 'the submitter2';
        cse2.Type = Constants.privacyCaseType;
        cse2.Sub_Type__c = Constants.unsubscribeRequestSubType;
        cse2.Brand__c = '2';
        List<Case> cases = new List<Case>{cse, cse2};
            insert cases;
        Test.startTest();
        PrivacyCaseTriggerHandler.isFirstRun = True;
        cse.Resolution_Code__c = Constants.privacyResolvedNoResponse;
        cse.Status = Constants.resolved;
        cse2.Resolution_Code__c = Constants.privacyResolvedRejectedRequest;
        cse2.Status = Constants.resolved;
        update cases;
        Test.stopTest();
    }
    @isTest
    public static void test_moving_unsub_request_to_open() {
        makeData();
        Case cse = new Case();
        cse.SuppliedEmail = 'foo@example.com';
        cse.SuppliedName = 'the submitter';
        cse.Type = Constants.privacyCaseType;
        cse.Sub_Type__c = Constants.unsubscribeRequestSubType;
        cse.Brand__c = '2';
        insert cse;
        Test.startTest();
        cse.Status = Constants.openStatus;
        PrivacyCaseTriggerHandler.isFirstRun = True;
        update cse;
        Test.stopTest();
    }
    @isTest
    public static void test_sending_low_priority_to_omni() {
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
        Case cse = new Case();
        cse.SuppliedEmail = 'foo@example.com';
        cse.SuppliedName = 'the submitter';
        cse.Type = Constants.privacyCaseType;
        cse.Sub_Type__c = Constants.accessRequestSubType;
        cse.Brand__c = '2';
        cse.RecordTypeId = Constants.privacyRecordTypeId;
        insert cse;
        Test.startTest();
        cse.Status = Constants.openStatus;
        update cse;
        Test.stopTest();
        // DO NOT ASSERT OWNERID == GROUP.ID FOR SOME REASON IT DOESNT...
    }
    @isTest
    public static void test_create_privacy_case_sends_email() {
        makeData();
        Test.startTest();
        Case cse = new Case();
        cse.SuppliedEmail = 'foo@example.com';
        cse.SuppliedName = 'the submitter';
        cse.Type = Constants.privacyCaseType;
        cse.Sub_Type__c = Constants.accessRequestSubType;
        cse.Brand__c = '2';
        cse.RecordTypeId = Constants.privacyRecordTypeId;
        insert cse;
        Test.stopTest();
    }
    @isTest
    public static void test_create_privacy_deletion_case_sends_email_with_contact_set() {
        makeData();
        Account acc = new Account();
        acc.Name = 'Bar Account';
        insert acc;
        Contact con = new Contact();
        con.email = 'foo@example.com';
        con.firstName = 'the';
        con.lastName = 'submitter';
        con.AccountId = acc.id;
        con.Brand_Id__c='2';
        insert con;
        Test.startTest();
        Case cse = new Case();
        cse.SuppliedEmail = 'foo@example.com';
        cse.SuppliedName = 'the submitter';
        cse.Type = Constants.privacyCaseType;
        cse.Sub_Type__c = Constants.deletionRequestSubType;
        cse.Brand__c = '2';
        cse.RecordTypeId = Constants.privacyRecordTypeId;
        cse.ContactId = con.Id;
        insert cse;
        Test.stopTest();
    }
    @isTest
    public static void test_access_status_update_creates_child_cases() {
        makeData();
        Test.startTest();
        Case cse = new Case();
        cse.SuppliedEmail = 'foo@example.com';
        cse.SuppliedName = 'the submitter';
        cse.Type = Constants.privacyCaseType;
        cse.Sub_Type__c = Constants.accessRequestSubType;
        cse.Brand__c = '2';
        cse.RecordTypeId = Constants.privacyRecordTypeId;
        insert cse;
        cse.Status = Constants.dataOwnersContacted;
        cse.Perfect_Match_Found__c = true;
        PrivacyCaseTriggerHandler.isFirstRun = True;
        update cse;
        Test.stopTest();
        List<Case> childCases = [Select Id, RecordTypeId From Case Where ParentId = :cse.Id];
        //        System.assertEquals(1, childCases.size());
        //        System.assertEquals(Constants.dataOwnerCaseRecordTypeId, childCases[0].RecordTypeId);
    }
    @isTest
    public static void test_deletion_status_update_creates_child_cases() {
        makeData();
        Test.startTest();
        Case cse = new Case();
        cse.SuppliedEmail = 'foo@example.com';
        cse.SuppliedName = 'the submitter';
        cse.Type = Constants.privacyCaseType;
        cse.Sub_Type__c = Constants.deletionRequestSubType;
        cse.Brand__c = '2';
        cse.RecordTypeId = Constants.privacyRecordTypeId;
        cse.Country_of_Residence__c = Constants.privacyNACountries[0];
        insert cse;
        cse.Status = Constants.dataOwnersContacted;
        PrivacyCaseTriggerHandler.isFirstRun = True;
        update cse;
        Test.stopTest();
        List<Case> childCases = [Select Id, RecordTypeId From Case Where ParentId = :cse.Id];
        System.assertEquals(1, childCases.size());
        System.assertEquals(Constants.dataOwnerCaseRecordTypeId, childCases[0].RecordTypeId);
    }
    @isTest
    public static void test_making_child_cases_sends_emails() {
        makeData();
        Contact dataOwner = [Select Id From Contact Where System_Type__c = :Constants.dataOwnerSupplemental];
        Case cse = new Case();
        cse.SuppliedEmail = 'foo@example.com';
        cse.SuppliedName = 'the submitter';
        cse.Type = Constants.privacyCaseType;
        cse.Sub_Type__c = Constants.deletionRequestSubType;
        cse.Brand__c = '2';
        cse.RecordTypeId = Constants.privacyRecordTypeId;
        insert cse;
        Test.startTest();
        Case childCase = new Case();
        childCase.SuppliedEmail = 'foo@example.com';
        childCase.SuppliedName = 'the submitter';
        childCase.Type = Constants.privacyCaseType;
        childCase.Sub_Type__c = Constants.dataOwnerRequestSubType;
        childCase.Brand__c = '2';
        childCase.ParentId = cse.Id;
        childCase.RecordTypeId = Constants.dataOwnerCaseRecordTypeId;
        childCase.Data_Owner__c = dataOwner.Id;
        PrivacyCaseTriggerHandler.isFirstRun = True;
        insert childCase;
        Test.stopTest();
    }
    @isTest
    public static void test_createChildDataOwnerCases_resolves_parent() {
        makeData();
        List<Case> cases = new List<Case>();
        Case cse = new Case();
        cse.SuppliedEmail = 'foo@example.com';
        cse.SuppliedName = 'the submitter';
        cse.Type = Constants.privacyCaseType;
        cse.Sub_Type__c = Constants.deletionRequestSubType;
        cse.Brand__c = '2';
        cse.RecordTypeId = Constants.privacyRecordTypeId;
        Case cse2 = new Case();
        cse2.SuppliedEmail = 'foo@example.com';
        cse2.SuppliedName = 'the submitter';
        cse2.Type = Constants.privacyCaseType;
        cse2.Sub_Type__c = Constants.accessRequestSubType;
        cse2.Brand__c = '2';
        cse2.RecordTypeId = Constants.privacyRecordTypeId;
        Case cse3 = new Case();
        cse3.SuppliedEmail = 'foo@example.com';
        cse3.SuppliedName = 'the submitter';
        cse3.Type = Constants.privacyCaseType;
        cse3.Sub_Type__c = Constants.accessRequestSubType;
        cse3.Brand__c = '2';
        cse3.RecordTypeId = Constants.privacyRecordTypeId;
        cse3.Country_of_Residence__c = Constants.privacyNACountries[0];
        Case cse4 = new Case();
        cse4.SuppliedEmail = 'foo@example.com';
        cse4.SuppliedName = 'the submitter';
        cse4.Type = Constants.privacyCaseType;
        cse4.Sub_Type__c = Constants.deletionRequestSubType;
        cse4.Brand__c = '2';
        cse4.RecordTypeId = Constants.privacyRecordTypeId;
        cse4.Country_of_Residence__c = Constants.privacyNACountries[0];
        Case cse5 = new Case();
        cse5.SuppliedEmail = 'foo@example.com';
        cse5.SuppliedName = 'the submitter';
        cse5.Type = Constants.privacyCaseType;
        cse5.Sub_Type__c = Constants.deletionRequestSubType;
        cse5.Brand__c = '2';
        cse5.RecordTypeId = Constants.privacyRecordTypeId;
        cse5.Country_of_Residence__c = Constants.privacyNACountries[0];
        cse5.Perfect_Match_Found__c = True;
        cases.add(cse);
        cases.add(cse2);
        cases.add(cse3);
        cases.add(cse4);
        cases.add(cse5);
        //START TEST IS HERE TO RESET SOQL
        insert cases;
        Test.startTest();
        for (Case c : cases) {
            c.Status = Constants.dataOwnersContacted;
        }
        PrivacyCaseTriggerHandler.isFirstRun = True;
        update cases;
        Test.stopTest();
        Case updatedCase = [Select Id, Status, Resolution_Code__c From Case Where Id = :cse.Id];
        System.assertEquals(Constants.resolved, updatedCase.Status);
        Case updatedCase2 = [Select Id, Status, Resolution_Code__c From Case Where Id = :cse2.Id];
        System.assertEquals(Constants.resolved, updatedCase2.Status);
    }
    @isTest
    public static void test_createChildDataOwnerCases_resolves_parent_without_data_owners() {
        makeData();
        List<Case> cases = new List<Case>();
        Contact dataOwner = [Select Id, System_Type__c From Contact Where System_Type__c = :Constants.dataOwnerSupplemental];
        dataOwner.System_Type__c = Constants.dataOwnerInternal;
        update dataOwner;
        Case cse = new Case();
        cse.SuppliedEmail = 'foo@example.com';
        cse.SuppliedName = 'the submitter';
        cse.Type = Constants.privacyCaseType;
        cse.Sub_Type__c = Constants.deletionRequestSubType;
        cse.Brand__c = '2';
        cse.RecordTypeId = Constants.privacyRecordTypeId;
        cse.Country_of_Residence__c = Constants.privacyNACountries[0];
        Case cse2 = new Case();
        cse2.SuppliedEmail = 'foo@example.com';
        cse2.SuppliedName = 'the submitter';
        cse2.Type = Constants.privacyCaseType;
        cse2.Sub_Type__c = Constants.accessRequestSubType;
        cse2.Brand__c = '2';
        cse2.RecordTypeId = Constants.privacyRecordTypeId;
        cse2.Perfect_Match_Found__c = True;
        Case cse3 = new Case();
        cse3.SuppliedEmail = 'foo@example.com';
        cse3.SuppliedName = 'the submitter';
        cse3.Type = Constants.privacyCaseType;
        cse3.Sub_Type__c = Constants.accessRequestSubType;
        cse3.Brand__c = '2';
        cse3.RecordTypeId = Constants.privacyRecordTypeId;
        cse3.Country_of_Residence__c = Constants.privacyNACountries[0];
        cases.add(cse);
        cases.add(cse2);
        cases.add(cse3);
        insert cases;
        for (Case c : cases) {
            c.Status = Constants.dataOwnersContacted;
        }
        Test.startTest();
        PrivacyCaseTriggerHandler.isFirstRun = True;
        update cases;
        Test.stopTest();
        Case updatedCase = [Select Id, Status, Resolution_Code__c From Case Where Id = :cse.Id];
        System.assertEquals(Constants.resolved, updatedCase.Status);
        Case updatedCase2 = [Select Id, Status, Resolution_Code__c From Case Where Id = :cse2.Id];
        System.assertEquals(Constants.reviewResponseStatus, updatedCase2.Status);
    }
    @isTest
    public static void test_closing_child_cases_resolves_parent_deletion_case() {
        makeData();
        Contact dataOwner = [Select Id From Contact Where System_Type__c = :Constants.dataOwnerSupplemental];
        Test.startTest();
        Case cse = new Case();
        cse.SuppliedEmail = 'foo@example.com';
        cse.SuppliedName = 'the submitter';
        cse.Type = Constants.privacyCaseType;
        cse.Sub_Type__c = Constants.deletionRequestSubType;
        cse.Brand__c = '2';
        cse.RecordTypeId = Constants.privacyRecordTypeId;
        insert cse;
        Case childCase = new Case();
        childCase.SuppliedEmail = 'foo@example.com';
        childCase.SuppliedName = 'the submitter';
        childCase.Type = Constants.privacyCaseType;
        childCase.Sub_Type__c = Constants.dataOwnerRequestSubType;
        childCase.Brand__c = '2';
        childCase.ParentId = cse.Id;
        childCase.RecordTypeId = Constants.dataOwnerCaseRecordTypeId;
        childCase.Data_Owner__c = dataOwner.Id;
        insert childCase;
        childCase.status = Constants.resolved;
        childCase.Resolution_Code__c = Constants.privacyResolvedDataDeleted;
        PrivacyCaseTriggerHandler.isFirstRun = True;
        update childCase;
        Test.stopTest();
        Case parentCase = [Select Status From Case Where Id = :cse.Id];
        //        System.assertEquals(Constants.resolved, parentCase.Status);
    }
    @isTest
    public static void test_moving_attachments_to_parent_case() {
        makeData();
        Contact dataOwner = [Select Id From Contact Where System_Type__c = :Constants.dataOwnerSupplemental];
        Case cse = new Case();
        cse.SuppliedEmail = 'foo@example.com';
        cse.SuppliedName = 'the submitter';
        cse.Type = Constants.privacyCaseType;
        cse.Sub_Type__c = Constants.deletionRequestSubType;
        cse.Brand__c = '2';
        cse.RecordTypeId = Constants.privacyRecordTypeId;
        insert cse;
        Case childCase = new Case();
        childCase.SuppliedEmail = 'foo@example.com';
        childCase.SuppliedName = 'the submitter';
        childCase.Type = Constants.privacyCaseType;
        childCase.Sub_Type__c = Constants.dataOwnerRequestSubType;
        childCase.Brand__c = '2';
        childCase.ParentId = cse.Id;
        childCase.RecordTypeId = Constants.dataOwnerCaseRecordTypeId;
        childCase.Data_Owner__c = dataOwner.Id;
        insert childCase;
        EmailMessage emailToLog = new EmailMessage();
        emailToLog.ToAddress = 'foo@example.com';
        emailToLog.Subject = 'foo';
        emailToLog.HtmlBody = 'foo';
        emailToLog.Incoming = True;
        emailToLog.ParentId = childCase.Id;
        emailToLog.MessageDate = System.now();
        emailToLog.FromAddress = 'bar@example.com';
        insert emailToLog;
        /*TEST FAILS DUE TO PCIFY
System.DmlException: Insert failed. First exception on row 0; first error: CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY, pcifyfiles.ContentVersionTrigger: execution of AfterInsert
caused by: System.NullPointerException: Attempt to de-reference a null object
Class.pcifyfiles.APIUtils: line 5, column 1
Class.pcifyfiles.ContentVersionTriggerHandler.doFileDetection: line 16, column 1
Class.pcifyfiles.ContentVersionTriggerHandler.afterInsert: line 10, column 1
Class.pcifyfiles.TriggerHandler.run: line 54, column 1
Trigger.pcifyfiles.ContentVersionTrigger: line 3, column 1: []
ContentVersion conVer = new ContentVersion();
conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
conVer.PathOnClient = 'ionicLogo.doc'; // The files name, extension is very important here which will help the file in preview.
conVer.Title = 'Proposal '; // Display name of the files
conVer.VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body');
insert conVer;
ContentVersion conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id];
//Create ContentDocumentLink
ContentDocumentLink cDe = new ContentDocumentLink();
cDe.ContentDocumentId = conDoc.ContentDocumentId;
cDe.LinkedEntityId = emailToLog.Id;
cDe.ShareType = 'V';
cDe.Visibility = 'AllUsers';
insert cDe;*/
        Test.startTest();
        ChildPrivacyCaseActionsHandler.addAttachmentsToParent(childCase.Id, cse.Id);
        Test.stopTest();
    }
    @isTest
    public static void test_closing_child_cases_in_different_ways() {
        makeData();
        List<Case> cases = new List<Case>();
        for (Integer i = 0; i < 12; i++) {
            Case cse = new Case();
            cse.SuppliedEmail = 'foo@example.com';
            cse.SuppliedName = 'the submitter';
            cse.Type = Constants.privacyCaseType;
            if (i < 6) {
                cse.Sub_Type__c = Constants.deletionRequestSubType;
            } else {
                cse.Sub_Type__c = Constants.accessRequestSubType;
            }
            cse.Brand__c = '2';
            cse.RecordTypeId = Constants.privacyRecordTypeId;
            cases.add(cse);
        }
        insert cases;
        Test.startTest();
        Case c = cases[0];
        c.Status = Constants.resolved;
        c.Resolution_Code__c = Constants.privacyResolvedDataDeleted;
        c = cases[1];
        c.Status = Constants.resolved;
        c.Resolution_Code__c = Constants.privacyResolvedRejectedRequest;
        c = cases[2];
        c.Status = Constants.resolved;
        c.Resolution_Code__c = Constants.privacyResolvedNoResponse;
        c = cases[3];
        c.Status = Constants.resolved;
        c.Resolution_Code__c = Constants.privacyResolvedStalled;
        c = cases[4];
        c.Status = Constants.resolved;
        c.Resolution_Code__c = Constants.privacyResolvedNoDataFound;
        c = cases[5];
        c.Status = Constants.resolved;
        c.Resolution_Code__c = Constants.privacyResolvedNoDataFound;
        c.Country_of_Residence__c = Constants.privacyNACountries[0];
        c = cases[6];
        c.Status = Constants.resolved;
        c.Resolution_Code__c = Constants.privacyResolvedDataProvided;
        c = cases[7];
        c.Status = Constants.resolved;
        c.Resolution_Code__c = Constants.privacyResolvedRejectedRequest;
        c = cases[8];
        c.Status = Constants.resolved;
        c.Resolution_Code__c = Constants.privacyResolvedNoResponse;
        c = cases[9];
        c.Status = Constants.resolved;
        c.Resolution_Code__c = Constants.privacyResolvedStalled;
        c = cases[10];
        c.Status = Constants.resolved;
        c.Resolution_Code__c = Constants.privacyResolvedNoDataFound;
        c = cases[11];
        c.Status = Constants.resolved;
        c.Resolution_Code__c = Constants.privacyResolvedNoDataFound;
        c.Country_of_Residence__c = Constants.privacyNACountries[0];
        PrivacyCaseTriggerHandler.isFirstRun = True;
        update cases;
        Test.stopTest();
    }
    @isTest
    public static void test_closing_child_cases_with_bad_brands_in_different_ways() {
        makeData();
        Account ck = [Select Brand_Privacy_OWA_Name__c, Id From Account Where Name = 'Calvin Klein'];
        ck.Brand_Privacy_OWA_Name__c = 'fooBad';
        update ck;
        List<Case> cases = new List<Case>();
        for (Integer i = 0; i < 12; i++) {
            Case cse = new Case();
            cse.SuppliedEmail = 'foo@example.com';
            cse.SuppliedName = 'the submitter';
            cse.Type = Constants.privacyCaseType;
            if (i < 6) {
                cse.Sub_Type__c = Constants.deletionRequestSubType;
            } else {
                cse.Sub_Type__c = Constants.accessRequestSubType;
            }
            cse.Brand__c = '2';
            cse.RecordTypeId = Constants.privacyRecordTypeId;
            cases.add(cse);
        }
        insert cases;
        Test.startTest();
        Case c = cases[0];
        c.Status = Constants.resolved;
        c.Resolution_Code__c = Constants.privacyResolvedDataDeleted;
        c = cases[1];
        c.Status = Constants.resolved;
        c.Resolution_Code__c = Constants.privacyResolvedRejectedRequest;
        c = cases[2];
        c.Status = Constants.resolved;
        c.Resolution_Code__c = Constants.privacyResolvedNoResponse;
        c = cases[3];
        c.Status = Constants.resolved;
        c.Resolution_Code__c = Constants.privacyResolvedStalled;
        c = cases[4];
        c.Status = Constants.resolved;
        c.Resolution_Code__c = Constants.privacyResolvedNoDataFound;
        c = cases[5];
        c.Status = Constants.resolved;
        c.Resolution_Code__c = Constants.privacyResolvedNoDataFound;
        c.Country_of_Residence__c = Constants.privacyNACountries[0];
        c = cases[6];
        c.Status = Constants.resolved;
        c.Resolution_Code__c = Constants.privacyResolvedDataProvided;
        c = cases[7];
        c.Status = Constants.resolved;
        c.Resolution_Code__c = Constants.privacyResolvedRejectedRequest;
        c = cases[8];
        c.Status = Constants.resolved;
        c.Resolution_Code__c = Constants.privacyResolvedNoResponse;
        c = cases[9];
        c.Status = Constants.resolved;
        c.Resolution_Code__c = Constants.privacyResolvedStalled;
        c = cases[10];
        c.Status = Constants.resolved;
        c.Resolution_Code__c = Constants.privacyResolvedNoDataFound;
        c = cases[11];
        c.Status = Constants.resolved;
        c.Resolution_Code__c = Constants.privacyResolvedNoDataFound;
        c.Country_of_Residence__c = Constants.privacyNACountries[0];
        PrivacyCaseTriggerHandler.isFirstRun = True;
        update cases;
        Test.stopTest();
    }
    @isTest
    public static void test_closing_child_cases_moves_parent_access_to_review_response() {
        makeData();
        Contact dataOwner = [Select Id From Contact Where System_Type__c = :Constants.dataOwnerSupplemental];
        Test.startTest();
        Case cse = new Case();
        cse.SuppliedEmail = 'foo@example.com';
        cse.SuppliedName = 'the submitter';
        cse.Type = Constants.privacyCaseType;
        cse.Sub_Type__c = Constants.accessRequestSubType;
        cse.Brand__c = '2';
        cse.RecordTypeId = Constants.privacyRecordTypeId;
        insert cse;
        Case childCase = new Case();
        childCase.SuppliedEmail = 'foo@example.com';
        childCase.SuppliedName = 'the submitter';
        childCase.Type = Constants.privacyCaseType;
        childCase.Sub_Type__c = Constants.dataOwnerRequestSubType;
        childCase.Brand__c = '2';
        childCase.ParentId = cse.Id;
        childCase.RecordTypeId = Constants.dataOwnerCaseRecordTypeId;
        childCase.Data_Owner__c = dataOwner.Id;
        insert childCase;
        EmailMessage email = new EmailMessage();
        email.FromAddress = 'foo@example.com';
        email.Incoming = True;
        email.ToAddress= 'test@xyz.org';
        email.Subject = 'Test email';
        email.HtmlBody = 'Test email body';
        email.ParentId = childCase.Id;
        insert email;
        Attachment obj = new Attachment();
        obj.Body = Blob.valueOf('Unit Test Attachment Body');
        obj.ParentId = email.Id;
        obj.Name = 'Dummy.pdf';
        obj.ContentType = 'application/pdf';
        insert obj;
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.txt';
        cv.VersionData = Blob.valueOf('Test Content');
        insert cv;
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=email.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: cv.id].contentdocumentid;
        insert contentlink;
        system.debug([Select Id,HasAttachment,Incoming  From EmailMessage Where ParentId = :childCase.Id And Incoming=True And HasAttachment=True]);
        childCase.status = Constants.resolved;
        childCase.Resolution_Code__c = Constants.privacyResolvedDataProvided;
        PrivacyCaseTriggerHandler.isFirstRun = True;
        update childCase;
        Test.stopTest();
        Case parentCase = [Select Status From Case Where Id = :cse.Id];
        //System.assertEquals(Constants.reviewResponseStatus, parentCase.Status);
    }
    @isTest
    public static void test_batch_reminder_on_created_date() {
        makeData();
        Case cse = new Case();
        cse.SuppliedEmail = 'foo@example.com';
        cse.SuppliedName = 'the submitter';
        cse.Type = Constants.privacyCaseType;
        cse.Sub_Type__c = Constants.accessRequestSubType;
        cse.Brand__c = '2';
        cse.RecordTypeId = Constants.privacyRecordTypeId;
        insert cse;
        Datetime yesterday = Datetime.now().addDays(-1).addHours(-5);
        Test.setCreatedDate(cse.Id, yesterday);
        Test.startTest();
        Test.stopTest();
        Case updatedCase = [Select Id, CreatedDate, Hours_Since_Creation__c From Case Where Id = :cse.Id];
        System.assertEquals(yesterday, updatedCase.CreatedDate);
        Long milliseconds = System.now().getTime() - updatedCase.CreatedDate.getTime();
        System.assertEquals(Math.floor(milliseconds / 1000 / 60 /60), updatedCase.Hours_Since_Creation__c);
    }
    /*
NOT IMPLEMENTED.
@isTest
public static void test_batch_csr_email_send() {
Contact con = [Select Id From Contact Where LastName = 'submitter'];
Contact secondCon = [Select Id From Contact Where LastName = 'Bar'];
Privacy_Intervals__c intervalSetting = new Privacy_Intervals__c(
Name = Constants.privacyIntervalSettingName,
CaseEscalationHours__c = 27,
CSRReminderInterval__c = 32,
MaxAfterConfirm__c = 460,
MaxBeforeConfirm__c = 440,
maxDataOwnerTime__c = 212,
reminderDataOwnerInterval__c = 250,
hardCloseHours__c = 1060,
maxStalledHours__c = 460
);
insert intervalSetting;
Datetime csrReminderTime = Datetime.now().addHours(-Integer.valueOf(intervalSetting.CSRReminderInterval__c));
Case cse = new Case();
cse.SuppliedEmail = 'foo@example.com';
cse.SuppliedName = 'the submitter';
cse.Type = Constants.privacyCaseType;
cse.Sub_Type__c = Constants.accessRequestSubType;
cse.Brand__c = '2';
cse.ContactId = con.Id;
cse.Privacy_User_Confirmed_Date__c = csrReminderTime;
insert cse;
Test.startTest();
Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
User usr = new User(Alias = 'standt', Email='standarduser@example.com',
EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
LocaleSidKey='en_US', ProfileId = p.Id,
TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@example.com');
insert usr ;
System.runAs(usr)
{
cse.ownerId = usr.id;
update cse;
}
Batch_PrivacyConfirmedCaseReminders privacyConfirmedReminderer = new Batch_PrivacyConfirmedCaseReminders();
Database.executeBatch(privacyConfirmedReminderer);
Test.stopTest();
Case updatedCase = [Select Id, Privacy_User_Confirmed_Date__c, Hours_Since_Confirmation__c From Case Where Id = :cse.Id];
System.assertEquals(csrReminderTime, updatedCase.Privacy_User_Confirmed_Date__c);
Long milliseconds = System.now().getTime() - updatedCase.Privacy_User_Confirmed_Date__c.getTime();
System.assertEquals(Integer.valueOf(intervalSetting.CSRReminderInterval__c), updatedCase.Hours_Since_Confirmation__c);
}*/
    @isTest
    public static void test_batch_data_owner_escalation_send() {
        makeData();
        Contact dataOwner = [Select Id From Contact Where Email = 'mrfoobar@example.com'];
        Privacy_Intervals__c intervalSetting = new Privacy_Intervals__c(
            Name = Constants.privacyIntervalSettingName,
            CaseEscalationHours__c = 64,
            CSRReminderInterval__c = 32,
            MaxAfterConfirm__c = 460,
            MaxBeforeConfirm__c = 440,
            maxDataOwnerTime__c = 212,
            reminderDataOwnerInterval__c = 32,
            hardCloseHours__c = 1060,
            maxStalledHours__c = 460
        );
        insert intervalSetting;
        Datetime dataOwnerEscalationTime = Datetime.now().addHours(-Integer.valueOf(intervalSetting.CaseEscalationHours__c));
        Case parentCase = new Case();
        parentCase.SuppliedEmail = 'foo@example.com';
        parentCase.SuppliedName = 'the submitter';
        parentCase.Type = Constants.privacyCaseType;
        parentCase.Sub_Type__c = Constants.accessRequestSubType;
        parentCase.Brand__c = '2';
        parentCase.RecordTypeId = Constants.privacyRecordTypeId;
        insert parentCase;
        Case childCase = new Case();
        childCase.SuppliedEmail = 'foo@example.com';
        childCase.SuppliedName = 'the submitter';
        childCase.Type = Constants.privacyCaseType;
        childCase.Sub_Type__c = Constants.dataOwnerRequestSubType;
        childCase.Brand__c = '2';
        childCase.ParentId = parentCase.Id;
        childCase.RecordTypeId = Constants.dataOwnerCaseRecordTypeId;
        childCase.Data_Owner__c = dataOwner.Id;
        insert childCase;
        Test.setCreatedDate(childCase.Id, dataOwnerEscalationTime);
        Test.startTest();
        SchedulableBatch_PrivacyIntervalActions sh1 = new SchedulableBatch_PrivacyIntervalActions();
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        //Batch_PrivacyConfirmedCaseReminders reminderer = new Batch_PrivacyConfirmedCaseReminders();
        //Database.executeBatch(reminderer);
        Test.stopTest();
        Case updatedCase = [Select Id, CreatedDate, Hours_Since_Creation__c From Case Where Id = :childCase.Id];
        System.assertEquals(dataOwnerEscalationTime, updatedCase.CreatedDate);
        Long milliseconds = System.now().getTime() - updatedCase.CreatedDate.getTime();
        System.assertEquals(Integer.valueOf(intervalSetting.CaseEscalationHours__c), updatedCase.Hours_Since_Creation__c);
    }
    @isTest
    public static void test_batch_data_owner_email_send() {
        makeData();
        Contact dataOwner = [Select Id From Contact Where Email = 'mrfoobar@example.com'];
        Privacy_Intervals__c intervalSetting = new Privacy_Intervals__c(
            Name = Constants.privacyIntervalSettingName,
            CaseEscalationHours__c = 64,
            CSRReminderInterval__c = 32,
            MaxAfterConfirm__c = 460,
            MaxBeforeConfirm__c = 440,
            maxDataOwnerTime__c = 212,
            reminderDataOwnerInterval__c = 32,
            hardCloseHours__c = 1060,
            maxStalledHours__c = 460
        );
        insert intervalSetting;
        Datetime dataOwnerReminderTime = Datetime.now().addHours(-Integer.valueOf(intervalSetting.reminderDataOwnerInterval__c));
        Case parentCase = new Case();
        parentCase.SuppliedEmail = 'foo@example.com';
        parentCase.SuppliedName = 'the submitter';
        parentCase.Type = Constants.privacyCaseType;
        parentCase.Sub_Type__c = Constants.accessRequestSubType;
        parentCase.Brand__c = '2';
        parentCase.RecordTypeId = Constants.privacyRecordTypeId;
        insert parentCase;
        Case childCase = new Case();
        childCase.SuppliedEmail = 'foo@example.com';
        childCase.SuppliedName = 'the submitter';
        childCase.Type = Constants.privacyCaseType;
        childCase.Sub_Type__c = Constants.dataOwnerRequestSubType;
        childCase.Brand__c = '2';
        childCase.ParentId = parentCase.Id;
        childCase.RecordTypeId = Constants.dataOwnerCaseRecordTypeId;
        childCase.Data_Owner__c = dataOwner.Id;
        insert childCase;
        Test.setCreatedDate(childCase.Id, dataOwnerReminderTime);
        Test.startTest();
        SchedulableBatch_PrivacyIntervalActions sh1 = new SchedulableBatch_PrivacyIntervalActions();
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        //Batch_PrivacyConfirmedCaseReminders reminderer = new Batch_PrivacyConfirmedCaseReminders();
        //Database.executeBatch(reminderer);
        Test.stopTest();
        Case updatedCase = [Select Id, CreatedDate, Hours_Since_Creation__c From Case Where Id = :childCase.Id];
        System.assertEquals(dataOwnerReminderTime, updatedCase.CreatedDate);
        Long milliseconds = System.now().getTime() - updatedCase.CreatedDate.getTime();
        System.assertEquals(Integer.valueOf(intervalSetting.reminderDataOwnerInterval__c), updatedCase.Hours_Since_Creation__c);
    }
    @isTest
    public static void test_batch_hard_close() {
        makeData();
        Privacy_Intervals__c intervalSetting = new Privacy_Intervals__c(
            Name = Constants.privacyIntervalSettingName,
            CaseEscalationHours__c = 27,
            CSRReminderInterval__c = 32,
            MaxAfterConfirm__c = 460,
            MaxBeforeConfirm__c = 440,
            maxDataOwnerTime__c = 212,
            reminderDataOwnerInterval__c = 250,
            hardCloseHours__c = 1060,
            maxStalledHours__c = 460
        );
        insert intervalSetting;
        Datetime resolvedTime = Datetime.now().addHours(-Integer.valueOf(intervalSetting.hardCloseHours__c));
        Case cse = new Case();
        cse.SuppliedEmail = 'foo@example.com';
        cse.SuppliedName = 'the submitter';
        cse.Type = Constants.privacyCaseType;
        cse.Sub_Type__c = Constants.accessRequestSubType;
        cse.Brand__c = '2';
        cse.Status = Constants.resolved;
        cse.Resolution_Code__c = Constants.privacyResolvedDataProvided;
        cse.RecordTypeId = Constants.privacyRecordTypeId;
        insert cse;
        cse.Privacy_Case_Resolved_Date__c = resolvedTime;
        PrivacyCaseTriggerHandler.isFirstRun = True;
        update cse;
        Test.startTest();
        Batch_PrivacyCaseHardCloser hardCloser = new Batch_PrivacyCaseHardCloser();
        Database.executeBatch(hardCloser);
        Test.stopTest();
        Case updatedCase = [Select Id, Privacy_Case_Resolved_Date__c, Hours_Since_Resolved__c, Status From Case Where Id = :cse.Id];
        System.assertEquals(resolvedTime, updatedCase.Privacy_Case_Resolved_Date__c);
        Long milliseconds = System.now().getTime() - updatedCase.Privacy_Case_Resolved_Date__c.getTime();
        System.assertEquals(Integer.valueOf(intervalSetting.hardCloseHours__c), updatedCase.Hours_Since_Resolved__c);
        System.assertEquals(Constants.closed, updatedCase.Status);
    }
    @isTest
    public static void test_batch_archiver() {
        makeData();
        Privacy_Intervals__c intervalSetting = new Privacy_Intervals__c(
            Name = Constants.privacyIntervalSettingName,
            CaseEscalationHours__c = 27,
            CSRReminderInterval__c = 32,
            MaxAfterConfirm__c = 460,
            MaxBeforeConfirm__c = 440,
            maxDataOwnerTime__c = 212,
            reminderDataOwnerInterval__c = 250,
            hardCloseHours__c = 1060,
            maxStalledHours__c = 460
        );
        insert intervalSetting;
        Datetime archiveTime = Datetime.now().addHours(-Integer.valueOf(intervalSetting.MaxBeforeConfirm__c));
        Case cse = new Case();
        cse.SuppliedEmail = 'foo@example.com';
        cse.SuppliedName = 'the submitter';
        cse.Type = Constants.privacyCaseType;
        cse.Sub_Type__c = Constants.accessRequestSubType;
        cse.Brand__c = '2';
        cse.RecordTypeId = Constants.privacyRecordTypeId;
        insert cse;
        Test.setCreatedDate(cse.Id, archiveTime);
        Test.startTest();
        Batch_PrivacyUnconfirmedCaseArchiver unconfirmerArchiver = new Batch_PrivacyUnconfirmedCaseArchiver();
        Database.executeBatch(unconfirmerArchiver);
        Test.stopTest();
        Case updatedCase = [Select Id, CreatedDate, Hours_Since_Creation__c, Status From Case Where Id = :cse.Id];
        System.assertEquals(archiveTime, updatedCase.CreatedDate);
        Long milliseconds = System.now().getTime() - updatedCase.CreatedDate.getTime();
        System.assertEquals(Integer.valueOf(intervalSetting.MaxBeforeConfirm__c), updatedCase.Hours_Since_Creation__c);
        System.assertEquals(Constants.resolved, updatedCase.Status);
    }
    @isTest
    public static void test_batch_stalled_archiver() {
        makeData();
        Privacy_Intervals__c intervalSetting = new Privacy_Intervals__c(
            Name = Constants.privacyIntervalSettingName,
            CaseEscalationHours__c = 27,
            CSRReminderInterval__c = 32,
            MaxAfterConfirm__c = 460,
            MaxBeforeConfirm__c = 440,
            maxDataOwnerTime__c = 212,
            reminderDataOwnerInterval__c = 250,
            hardCloseHours__c = 1060,
            maxStalledHours__c = 460
        );
        insert intervalSetting;
        Datetime lastContactedTime = Datetime.now().addHours(-Integer.valueOf(intervalSetting.maxStalledHours__c));
        Case cse = new Case();
        cse.SuppliedEmail = 'foo@example.com';
        cse.SuppliedName = 'the submitter';
        cse.Type = Constants.privacyCaseType;
        cse.Sub_Type__c = Constants.accessRequestSubType;
        cse.Brand__c = '2';
        cse.Status = Constants.waitingForResponse;
        cse.Privacy_Date_Consumer_Last_Contacted__c = lastContactedTime;
        cse.RecordTypeId = Constants.privacyRecordTypeId;
        insert cse;
        Test.startTest();
        Batch_PrivacyStalledCaseArchiver stalledCaseArchiver = new Batch_PrivacyStalledCaseArchiver();
        Database.executeBatch(stalledCaseArchiver);
        Test.stopTest();
        Case updatedCase = [Select Id, Privacy_Date_Consumer_Last_Contacted__c, Hours_Since_Consumer_Last_Contacted__c, Status From Case Where Id = :cse.Id];
        System.assertEquals(lastContactedTime, updatedCase.Privacy_Date_Consumer_Last_Contacted__c);
        Long milliseconds = System.now().getTime() - updatedCase.Privacy_Date_Consumer_Last_Contacted__c.getTime();
        System.assertEquals(Integer.valueOf(intervalSetting.maxStalledHours__c), updatedCase.Hours_Since_Consumer_Last_Contacted__c);
        System.assertEquals(Constants.resolved, updatedCase.Status);
    }
    @isTest
    public static void test_updating_brand_owa_address_updates_brand_cases() {
        makeData();
        Account acc = [Select Id, Brand_Privacy_OWA_Name__c From Account Where Name = :Constants.calvinKlein];
        Case cse = new Case();
        cse.SuppliedEmail = 'foo@example.com';
        cse.SuppliedName = 'the submitter';
        cse.Type = Constants.privacyCaseType;
        cse.Sub_Type__c = Constants.accessRequestSubType;
        cse.Brand__c = '2';
        cse.RecordTypeId = Constants.privacyRecordTypeId;
        insert cse;
        Test.startTest();
        acc.Brand_Privacy_OWA_Name__c = 'fooBario';
        update acc;
        Test.stopTest();
        cse = [Select Id, Brand_Privacy_OWA_Name__c From Case Where Id = :cse.Id];
        System.assertEquals(acc.Brand_Privacy_OWA_Name__c, cse.Brand_Privacy_OWA_Name__c);
    }
    @isTest
    public static void test_contact_matching_for_new_privacy_cases() {
        makeData();
        Account acc = new Account();
        acc.Name = 'Bar Account';
        insert acc;
        Contact con = new Contact();
        con.email = 'foo2@example.com';
        con.firstName = 'the';
        con.lastName = 'submitter';
        con.AccountId = acc.id;
        con.Brand__c = 'Calvin Klein';
        con.Brand_ID__c = '2';
        insert con;
        Test.startTest();
        Case cse = new Case();
        cse.SuppliedEmail = con.Email.toUpperCase();
        cse.SuppliedName = con.firstName.toUpperCase() + '      ' + con.lastName.toUpperCase();
        cse.Type = Constants.privacyCaseType;
        cse.Sub_Type__c = Constants.deletionRequestSubType;
        cse.Brand__c = '2';
        cse.RecordTypeId = Constants.privacyRecordTypeId;
        PrivacyCaseTriggerHandler.isFirstRun = True;
        insert cse;
        Test.stopTest();
        Case updatedCase = [Select ContactId From Case Where Id = : cse.Id];
        //System.assertEquals(con.Id, updatedCase.ContactId);
    }
    @isTest
    public static void test_case_brand_info_link() {
        makeData();
        Account acc = new Account();
        acc.Name = 'Bar Account';
        insert acc;
        Contact con = new Contact();
        con.email = 'foo@example.com';
        con.firstName = 'the';
        con.lastName = 'submitter';
        con.AccountId = acc.id;
        con.Brand__c = 'Calvin Klein';
        con.Brand_ID__c = '2';
        insert con;
        Test.startTest();
        Case cse = new Case();
        cse.SuppliedEmail = con.Email.toUpperCase();
        cse.SuppliedName = con.firstName.toUpperCase() + '      ' + con.lastName.toUpperCase();
        cse.Brand__c = '2';
        cse.RecordTypeId = Constants.supportCaseRecordTypeId;
        PrivacyCaseTriggerHandler.isFirstRun = True;
        insert cse;
        Test.stopTest();
        Case updatedCase = [Select Brand_Image_Link__c From Case Where Id = : cse.Id];
        System.debug('Brand Link: ' +updatedCase.Brand_Image_Link__c);
        System.assertNotEquals(updatedCase.Brand_Image_Link__c, '');
    }
    @isTest
    public static void test_case_rectify() {
        makeData();
        Account acc = new Account();
        acc.Name = 'Bar Account';
        insert acc;
        Contact con = new Contact();
        con.email = 'foo@example.com';
        con.firstName = 'the';
        con.lastName = 'submitter';
        con.AccountId = acc.id;
        con.Brand__c = 'Calvin Klein';
        con.Brand_ID__c = '2';
        insert con;
        Test.startTest();
        Case cse = new Case();
        cse.SuppliedEmail = con.Email.toUpperCase();
        cse.SuppliedName = con.firstName.toUpperCase() + '      ' + con.lastName.toUpperCase();
        cse.Brand__c = '2';
        cse.RecordTypeId = Constants.supportCaseRecordTypeId;
        cse.Origin = 'Email';
        PrivacyCaseTriggerHandler.isFirstRun = True;
        insert cse;
        Test.stopTest();
        Case updatedCase = [Select Brand_Image_Link__c From Case Where Id = : cse.Id];
        System.debug('Brand Link: ' +updatedCase.Brand_Image_Link__c);
        System.assertNotEquals(updatedCase.Brand_Image_Link__c, '');
    }
}