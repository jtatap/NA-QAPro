@isTest
public class PrivacyCaseTriggerHandlerTest {
	
    @TestSetup
    static void setupTestData(){
        
        
        List<EmailTemplate> temps = new List<EmailTemplate>();
        EmailTemplate e1 = new EmailTemplate (developerName = 'template1', FolderId =UserInfo.getUserId(), TemplateType= 'Text', Name = SYSTEM.LABEL.U1_Unsubscribe_Verification); 
		temps.add(e1);
        EmailTemplate e2 = new EmailTemplate (developerName = 'template2', FolderId = UserInfo.getUserId(), TemplateType= 'Text', Name = SYSTEM.LABEL.U3_Identity_verification_timeout); 
		temps.add(e2);
        EmailTemplate e3 = new EmailTemplate (developerName = 'template3', FolderId = UserInfo.getUserId(), TemplateType= 'Text', Name = SYSTEM.LABEL.U2_No_Never_requested_an_unsubscribe); 
		temps.add(e3);
        EmailTemplate e4 = new EmailTemplate (developerName = 'template4', FolderId = UserInfo.getUserId(), TemplateType= 'Text', Name = SYSTEM.LABEL.A1_Identity_Verification_Request); 
		temps.add(e4);
        EmailTemplate e5 = new EmailTemplate (developerName = 'template5', FolderId = UserInfo.getUserId(), TemplateType= 'Text', Name = SYSTEM.LABEL.A2_No_never_requested_automated_response_sent_to_the_consumer); 
		temps.add(e5);
        EmailTemplate e6 = new EmailTemplate (developerName =  'template6', FolderId = UserInfo.getUserId(), TemplateType= 'Text', Name =  SYSTEM.LABEL.A10_Automated_email_out_if_consumer_does_not_respond_to_request_for_physical_ad); 
		temps.add(e6);
        EmailTemplate e7 = new EmailTemplate (developerName = 'template7', FolderId = UserInfo.getUserId(), TemplateType= 'Text', Name = SYSTEM.LABEL.A7_CSR_alerts_consumer_that_there_is_no_data); 
		temps.add(e7);
        EmailTemplate e8 = new EmailTemplate (developerName = 'template8', FolderId = UserInfo.getUserId(), TemplateType= 'Text', Name = SYSTEM.LABEL.A8_No_Match_Non_EU_NA_Consumer_CSR_alerts_non_NA_EU); 
		temps.add(e8);       
        EmailTemplate e9 = new EmailTemplate (developerName = 'template9', FolderId =UserInfo.getUserId(), TemplateType= 'Text', Name = SYSTEM.LABEL.D1_SFSC_send_automated_validation_email); 
		temps.add(e9);
        EmailTemplate e11 = new EmailTemplate (developerName = 'template11', FolderId = UserInfo.getUserId(), TemplateType= 'Text', Name = SYSTEM.LABEL.D4_CSR_responds_to_consumer_that_record_has_been_deleted); 
		temps.add(e11);
        EmailTemplate e12 = new EmailTemplate (developerName = 'template12', FolderId = UserInfo.getUserId(), TemplateType= 'Text', Name = SYSTEM.LABEL.D5_CSR_alerts_consumer_that_there_is_not_record_to_be_deleted); 
		temps.add(e12);
        EmailTemplate e13 = new EmailTemplate (developerName = 'template13', FolderId = UserInfo.getUserId(), TemplateType= 'Text', Name = SYSTEM.LABEL.D7_Never_Requested); 
		temps.add(e13);
        EmailTemplate e14 = new EmailTemplate (developerName = 'template14', FolderId = UserInfo.getUserId(), TemplateType= 'Text', Name = SYSTEM.LABEL.D8_Automated_email_out_if_consumer_does_not_respond); 
		temps.add(e14);
        EmailTemplate e15 = new EmailTemplate (developerName =  'template15', FolderId = UserInfo.getUserId(), TemplateType= 'Text', Name =  SYSTEM.LABEL.D9_No_Match_Non_EU_NA_Consumer_CSR_alerts_non_NA_EU_consumer); 
		temps.add(e15);
        EmailTemplate e16 = new EmailTemplate (developerName = 'template16', FolderId = UserInfo.getUserId(), TemplateType= 'Text', Name = SYSTEM.LABEL.D10_Automated_email_out_if_consumer_does_not_respond_to_request_for_phy_address); 
		temps.add(e16);
        EmailTemplate e17 = new EmailTemplate (developerName = 'template17', FolderId = UserInfo.getUserId(), TemplateType= 'Text', Name = 'U4 - CSR responds to consumer that record has been corrected'); 
		temps.add(e17);
        EmailTemplate e22 = new EmailTemplate (developerName = 'template22', FolderId = UserInfo.getUserId(), TemplateType= 'Text', Name = 'U5 - CSR alerts consumer that there is not record to be corrected'); 
		temps.add(e22);
        EmailTemplate e23 = new EmailTemplate (developerName = 'template23', FolderId = UserInfo.getUserId(), TemplateType= 'Text', Name = 'S4 - CSR responds to consumer that record has been deleted'); 
		temps.add(e23);
        EmailTemplate e24 = new EmailTemplate (developerName = 'template24', FolderId = UserInfo.getUserId(), TemplateType= 'Text', Name =  'S5 - CSR alerts consumer that there is not record to be deleted'); 
		temps.add(e24);
        
        insert temps;
        
        List<OrgWideEmailAddress> owaList = [Select DisplayName,Address  From OrgWideEmailAddress];
        System.debug('owa'+owaList);
    }
    
    @isTest
    static void processNewEmailPrivacyCasesTest(){
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
        listCases[0].Status = Constants.newPrivacyStatus;
        listCases[0].Type = Constants.privacyCaseType;
        listCases[0].Sub_Type__c = Constants.accessRequestSubType;
        insert listCases;
        
        
        
         List<Case> caseList = [SELECT Id,SuppliedEmail,Resolution_Code__c,Brand__c,Brand_Privacy_OWA_Name__c,Status from Case];
         PrivacyEmailHandler emailHandler = new PrivacyEmailHandler();
         Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
         string[] to = new string[] {'test@test.com'};
         string[] cc = new string[] {'test@test.com'};
         email.setToAddresses(to);
         email.setCcAddresses(cc);
         email.setSubject('test');
         email.setHtmlBody('test');
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>{email};
        
        try{
            PrivacyCaseTriggerHandler.processNewEmailPrivacyCases(caseList);

              }
        catch(Exception e){
            system.debug('error' + e);
        }
        try{
                       PrivacyCaseTriggerHandler.processUnsubCases(caseList);

              }
        catch(Exception e){
            system.debug('error' + e);
        }
        try{
                       PrivacyCaseTriggerHandler.processDataOwnerCases(caselist[0], emails,emailHandler, new Map<Id, Case>(),new Map<Id, List<String>>(), new Map<Id,String>());

              }
        catch(Exception e){
            system.debug('error' + e);
        }
        try{
                       PrivacyCaseTriggerHandler.processdoNotSellShareCase(caselist[0], emails,emailHandler);

              }
        catch(Exception e){
            system.debug('error' + e);
        }
        try{
                       PrivacyCaseTriggerHandler.processUpdationCase(caselist[0], emails,emailHandler);

              }
        catch(Exception e){
            system.debug('error' + e);
        }
        try{
                       PrivacyCaseTriggerHandler.processDeletionCase(caselist[0], emails,emailHandler);

              }
        catch(Exception e){
            system.debug('error' + e);
        }
        try{
                       PrivacyCaseTriggerHandler.processAccessCases(caselist[0], emails,emailHandler);

              }
        catch(Exception e){
            system.debug('error' + e);
        }
        try{
            PrivacyCaseTriggerHandler.sendPrivacyEmailsIfNeeded(caseList, new List<Id>{caselist[0].id}, new List<Id>());
        }
        catch(Exception e){
            system.debug('error' + e);
        }
         try{
            PrivacyCaseTriggerHandler.createChildCasesIfNeeded(caseList);
        }
        catch(Exception e){
            system.debug('error' + e);
        }
        
    }
    
    @isTest
    static void sendEmailsIfNecessaryTest(){
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

        List<Case> listCases = TestDataFactory.createCases(10);
        listCases[0].contactId = getContact.Id;
        listCases[0].Brand__c = '2';
        listCases[0].Status = Constants.newPrivacyStatus;
        listCases[0].Type = Constants.privacyCaseType;
        listCases[0].Sub_Type__c = Constants.accessRequestSubType;
        listCases[0].Brand_Privacy_OWA_Name__c = 'Calvin Klein Privacy Support';
        listCases[0].SuppliedEmail = 'test@test.com';
        //second case
        listCases[1].contactId = getContact.Id;
        listCases[1].Brand__c = '2';
        listCases[1].Type = Constants.privacyCaseType;
        listCases[1].Sub_Type__c = Constants.unsubscribeRequestSubType;
        listCases[1].Brand_Privacy_OWA_Name__c = 'Calvin Klein Privacy Support';
        listCases[1].SuppliedEmail = 'test@test.com';
        //third case
        listCases[2].contactId = getContact.Id;
        listCases[2].Brand__c = '2';
        listCases[2].Type = Constants.privacyCaseType;
        listCases[2].Sub_Type__c = Constants.unsubscribeRequestSubType;
        listCases[2].RecordTypeId = Constants.privacyReadOnlyRecordTypeId;
        listCases[2].Brand_Privacy_OWA_Name__c = 'Calvin Klein Privacy Support';
        listCases[2].SuppliedEmail = 'test@test.com';
        //fourth case
        listCases[3].contactId = getContact.Id;
        listCases[3].Brand__c = '2';
        listCases[3].Type = Constants.privacyCaseType;
        listCases[3].Sub_Type__c = Constants.privacyEmailSubType;
        listCases[3].RecordTypeId = Constants.privacyReadOnlyRecordTypeId;
        listCases[3].Status = Constants.newPrivacyStatus;
        listCases[3].Brand_Privacy_OWA_Name__c = 'Calvin Klein Privacy Support';
        listCases[3].SuppliedEmail = 'test@test.com';
        //fourth case
        listCases[4].contactId = getContact.Id;
        listCases[4].Brand__c = '2';
        listCases[4].Type = Constants.privacyCaseType;
        listCases[4].Sub_Type__c = Constants.dataOwnerRequestSubType;
        listCases[4].RecordTypeId = Constants.privacyReadOnlyRecordTypeId;
        listCases[4].Status = Constants.newPrivacyStatus;
        listCases[4].Brand_Privacy_OWA_Name__c = 'Calvin Klein Privacy Support';
        listCases[4].SuppliedEmail = 'test@test.com';
        insert listCases;
        
       
        
        
    }
    
    @isTest
    public static void processUnsubCasesTest() {
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
        listCases[0].Status = Constants.newPrivacyStatus;
        listCases[0].Type = Constants.privacyCaseType;
        listCases[0].Sub_Type__c = Constants.unsubscribeRequestSubType;
        listCases[0].Brand_Privacy_OWA_Name__c = 'Calvin Klein Privacy Support';
        listCases[0].SuppliedEmail = 'test@test.com';
        insert listCases;
        PrivacyCaseTriggerHandler.isFirstRun = true;
        listCases[0].Status = Constants.resolved;
        listCases[0].Resolution_Code__c = Constants.privacyResolvedNoResponse;
        update listCases;
    }
    
    @isTest
    public static void processUnsubCasesTest2() {
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
        listCases[0].Status = Constants.newPrivacyStatus;
        listCases[0].Type = Constants.privacyCaseType;
        listCases[0].Sub_Type__c = Constants.unsubscribeRequestSubType;
        listCases[0].Brand_Privacy_OWA_Name__c = 'Calvin Klein Privacy Support';
        listCases[0].SuppliedEmail = 'test@test.com';
        insert listCases;
        PrivacyCaseTriggerHandler.isFirstRun = true;
        listCases[0].Status = Constants.resolved;
        listCases[0].Resolution_Code__c = Constants.privacyResolvedRejectedRequest;
        update listCases;
    }
    
    @isTest
    public static void createChildCasesIfNeededTest() {
        Account genAcc = new Account();
        genAcc.Name = 'generic Account' + Math.random();
        insert genAcc;

        Contact genCon = new Contact();
        genCon.email = 'foo@example.com';
        genCon.lastName = 'generic contact ' + Math.random();
        genCon.AccountId = genAcc.id;
        genCon.Brand_Id__c = '9';
        genCon.RecordTypeId = Constants.dataOwnerContactRecordTypeId;
        genCon.System_Type__c = Constants.dataOwnerSupplemental;
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
        listCases[0].Status = Constants.newPrivacyStatus;
        listCases[0].Type = Constants.privacyCaseType;
        listCases[0].Sub_Type__c = Constants.accessRequestSubType;
        listCases[0].Brand_Privacy_OWA_Name__c = 'Calvin Klein Privacy Support';
        listCases[0].SuppliedEmail = 'test@test.com';
        insert listCases;
        PrivacyCaseTriggerHandler.isFirstRun = true;
        listCases[0].Status = Constants.dataOwnersContacted;
        listCases[0].Resolution_Code__c = Constants.privacyResolvedRejectedRequest;
        listCases[0].Perfect_Match_Found__c = true;
        update listCases;
    }
    
    @isTest
    public static void createChildCasesIfNeededTest2() {
        Account genAcc = new Account();
        genAcc.Name = 'generic Account' + Math.random();
        insert genAcc;

        Contact genCon = new Contact();
        genCon.email = 'foo@example.com';
        genCon.lastName = 'generic contact ' + Math.random();
        genCon.AccountId = genAcc.id;
        genCon.Brand_Id__c = '9';
        genCon.RecordTypeId = Constants.dataOwnerContactRecordTypeId;
        genCon.System_Type__c = Constants.dataOwnerSupplemental;
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
        listCases[0].Status = Constants.newPrivacyStatus;
        listCases[0].Type = Constants.privacyCaseType;
        listCases[0].Sub_Type__c = Constants.accessRequestSubType;
        listCases[0].Brand_Privacy_OWA_Name__c = 'Calvin Klein Privacy Support';
        listCases[0].SuppliedEmail = 'test@test.com';
        insert listCases;
        PrivacyCaseTriggerHandler.isFirstRun = true;
        listCases[0].Status = Constants.dataOwnersContacted;
        listCases[0].Resolution_Code__c = Constants.privacyResolvedRejectedRequest;
        listCases[0].Perfect_Match_Found__c = false;
        listCases[0].Country_of_Residence__c = 'India';
        update listCases;
    }
    
    @isTest
    public static void createChildCasesIfNeededTest3() {
        Account genAcc = new Account();
        genAcc.Name = 'Calvin Klein';
        insert genAcc;

        Contact genCon = new Contact();
        genCon.email = 'foo@example.com';
        genCon.lastName = 'generic contact ' + Math.random();
        genCon.AccountId = genAcc.id;
        genCon.Brand_Id__c = '9';
        genCon.RecordTypeId = Constants.dataOwnerContactRecordTypeId;
        genCon.System_Type__c = Constants.dataOwnerSupplemental;
        genCon.DataOwner_Subtype__c  = 'Unsubscribe';
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
            con.DataOwner_Subtype__c  = 'Unsubscribe';
            listUpdateContact.add(con);
        }

        insert listUpdateContact;
        Contact getContact = [Select Id, LoyaltyID__c, Brand_Id__c
                              from Contact
                              WHERE LoyaltyId__c = 'C0021733313'];

        List<Case> listCases = TestDataFactory.createCases(1);
        listCases[0].contactId = getContact.Id;
        listCases[0].Brand__c = '2';
        listCases[0].Status = Constants.newPrivacyStatus;
        listCases[0].Type = Constants.privacyCaseType;
        listCases[0].Sub_Type__c = Constants.accessRequestSubType;
        listCases[0].Brand_Privacy_OWA_Name__c = 'Calvin Klein Privacy Support';
        listCases[0].SuppliedEmail = 'test@test.com';
        insert listCases;
        PrivacyCaseTriggerHandler.isFirstRun = true;
        listCases[0].Status = Constants.dataOwnersContacted;
        listCases[0].Resolution_Code__c = Constants.privacyResolvedRejectedRequest;
        listCases[0].Perfect_Match_Found__c = false;
        listCases[0].Country_of_Residence__c = 'Canada';
        update listCases;
    }
    
    @isTest
    public static void createChildCasesIfNeededTest4() {
        Account genAcc = new Account();
        genAcc.Name = 'Test'+Math.random();
        insert genAcc;

        Contact genCon = new Contact();
        genCon.email = 'foo@example.com';
        genCon.lastName = 'generic contact ' + Math.random();
        genCon.AccountId = genAcc.id;
        genCon.Brand_Id__c = '9';
        genCon.RecordTypeId = Constants.dataOwnerContactRecordTypeId;
        genCon.System_Type__c = Constants.dataOwnerSupplemental;
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
        listCases[0].Status = Constants.newPrivacyStatus;
        listCases[0].Type = Constants.privacyCaseType;
        listCases[0].Sub_Type__c = Constants.accessRequestSubType;
        listCases[0].Brand_Privacy_OWA_Name__c = 'Calvin Klein Privacy Support';
        listCases[0].SuppliedEmail = 'test@test.com';
        insert listCases;
        PrivacyCaseTriggerHandler.isFirstRun = true;
        listCases[0].Status = Constants.dataOwnersContacted;
        listCases[0].Resolution_Code__c = Constants.privacyResolvedRejectedRequest;
        listCases[0].Perfect_Match_Found__c = false;
        listCases[0].Country_of_Residence__c = 'Canada';
        update listCases;
    }
    
    @isTest
    public static void sendPrivacyEmailsIfNeededTest() {
        Account genAcc = new Account();
        genAcc.Name = 'Test'+Math.random();
        insert genAcc;

        Contact genCon = new Contact();
        genCon.email = 'foo@example.com';
        genCon.lastName = 'generic contact ' + Math.random();
        genCon.AccountId = genAcc.id;
        genCon.Brand_Id__c = '9';
        genCon.RecordTypeId = Constants.dataOwnerContactRecordTypeId;
        genCon.System_Type__c = Constants.dataOwnerSupplemental;
        genCon.Additional_Email_1__c = 'test@test.com';
        genCon.Additional_Email_2__c = 'test@test.com';
        genCon.Additional_Email_3__c = 'test@test.com';
        genCon.Additional_Email_4__c = 'test@test.com';
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

        //Parent case
        listCases[0].contactId = getContact.Id;
        listCases[0].Brand__c = '2';
        listCases[0].Status = Constants.newPrivacyStatus;
        listCases[0].Type = Constants.privacyCaseType;
        listCases[0].Sub_Type__c = Constants.accessRequestSubType;
        listCases[0].Brand_Privacy_OWA_Name__c = 'Calvin Klein Privacy Support';
        listCases[0].SuppliedEmail = 'test@test.com';
        insert listCases;
        PrivacyCaseTriggerHandler.isFirstRun = True;
        //Child case
        List<Case> listCasesChild = TestDataFactory.createCases(1);
        listCasesChild[0].contactId = getContact.Id;
        listCasesChild[0].Brand__c = '2';
        listCasesChild[0].Status = Constants.newPrivacyStatus;
        listCasesChild[0].Type = Constants.privacyCaseType;
        listCasesChild[0].Sub_Type__c = Constants.dataOwnerRequestSubType;
        listCasesChild[0].Brand_Privacy_OWA_Name__c = 'Calvin Klein Privacy Support';
        listCasesChild[0].SuppliedEmail = 'test@test.com';
        listCasesChild[0].ParentId = listCases[0].Id;
        listCasesChild[0].Data_Owner__c = genCon.Id;
        insert listCasesChild;
        
    }
    
    @isTest
    public static void sendPrivacyEmailsIfNeededTest1() {
        Account genAcc = new Account();
        genAcc.Name = 'Test'+Math.random();
        insert genAcc;

        Contact genCon = new Contact();
        genCon.email = 'foo@example.com';
        genCon.lastName = 'generic contact ' + Math.random();
        genCon.AccountId = genAcc.id;
        genCon.Brand_Id__c = '9';
        genCon.RecordTypeId = Constants.dataOwnerContactRecordTypeId;
        genCon.System_Type__c = Constants.dataOwnerSupplemental;
        genCon.Additional_Email_1__c = 'test@test.com';
        genCon.Additional_Email_2__c = 'test@test.com';
        genCon.Additional_Email_3__c = 'test@test.com';
        genCon.Additional_Email_4__c = 'test@test.com';
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

        //Parent case
        listCases[0].contactId = getContact.Id;
        listCases[0].Brand__c = '2';
        listCases[0].Status = Constants.newPrivacyStatus;
        listCases[0].Type = Constants.privacyCaseType;
        listCases[0].Sub_Type__c = Constants.accessRequestSubType;
        listCases[0].Brand_Privacy_OWA_Name__c = 'Calvin Klein Privacy Support';
        listCases[0].SuppliedEmail = 'test@test.com';
        insert listCases;
        PrivacyCaseTriggerHandler.isFirstRun = True;
        //Child case
        List<Case> listCasesChild = TestDataFactory.createCases(1);
        listCasesChild[0].contactId = getContact.Id;
        listCasesChild[0].Brand__c = '2';
        listCasesChild[0].Status = Constants.newPrivacyStatus;
        listCasesChild[0].Type = Constants.privacyCaseType;
        listCasesChild[0].Sub_Type__c = Constants.deletionRequestSubType;
        listCasesChild[0].Brand_Privacy_OWA_Name__c = 'Calvin Klein Privacy Support';
        listCasesChild[0].SuppliedEmail = 'test@test.com';
        listCasesChild[0].ParentId = listCases[0].Id;
        listCasesChild[0].Data_Owner__c = genCon.Id;
        insert listCasesChild;
        
    }
    
    @isTest
    public static void sendPrivacyEmailsIfNeededTest2() {
        Account genAcc = new Account();
        genAcc.Name = 'Test'+Math.random();
        insert genAcc;

        Contact genCon = new Contact();
        genCon.email = 'foo@example.com';
        genCon.lastName = 'generic contact ' + Math.random();
        genCon.AccountId = genAcc.id;
        genCon.Brand_Id__c = '9';
        genCon.RecordTypeId = Constants.dataOwnerContactRecordTypeId;
        genCon.System_Type__c = Constants.dataOwnerSupplemental;
        genCon.Additional_Email_1__c = 'test@test.com';
        genCon.Additional_Email_2__c = 'test@test.com';
        genCon.Additional_Email_3__c = 'test@test.com';
        genCon.Additional_Email_4__c = 'test@test.com';
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

        //Parent case
        listCases[0].contactId = getContact.Id;
        listCases[0].Brand__c = '2';
        listCases[0].Status = Constants.newPrivacyStatus;
        listCases[0].Type = Constants.privacyCaseType;
        listCases[0].Sub_Type__c = Constants.accessRequestSubType;
        listCases[0].Brand_Privacy_OWA_Name__c = 'Calvin Klein Privacy Support';
        listCases[0].SuppliedEmail = 'test@test.com';
        insert listCases;
        PrivacyCaseTriggerHandler.isFirstRun = True;
        //Child case
        List<Case> listCasesChild = TestDataFactory.createCases(1);
        listCasesChild[0].contactId = getContact.Id;
        listCasesChild[0].Brand__c = '2';
        listCasesChild[0].Status = Constants.newPrivacyStatus;
        listCasesChild[0].Type = Constants.privacyCaseType;
        listCasesChild[0].Sub_Type__c = Constants.rectifyRequestSubType;
        listCasesChild[0].Brand_Privacy_OWA_Name__c = 'Calvin Klein Privacy Support';
        listCasesChild[0].SuppliedEmail = 'test@test.com';
        listCasesChild[0].ParentId = listCases[0].Id;
        listCasesChild[0].Data_Owner__c = genCon.Id;
        insert listCasesChild;
        
    }
    
    @isTest
    public static void sendPrivacyEmailsIfNeededTest3() {
        Account genAcc = new Account();
        genAcc.Name = 'Test'+Math.random();
        insert genAcc;

        Contact genCon = new Contact();
        genCon.email = 'foo@example.com';
        genCon.lastName = 'generic contact ' + Math.random();
        genCon.AccountId = genAcc.id;
        genCon.Brand_Id__c = '9';
        genCon.RecordTypeId = Constants.dataOwnerContactRecordTypeId;
        genCon.System_Type__c = Constants.dataOwnerSupplemental;
        genCon.Additional_Email_1__c = 'test@test.com';
        genCon.Additional_Email_2__c = 'test@test.com';
        genCon.Additional_Email_3__c = 'test@test.com';
        genCon.Additional_Email_4__c = 'test@test.com';
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

        //Parent case
        listCases[0].contactId = getContact.Id;
        listCases[0].Brand__c = '2';
        listCases[0].Status = Constants.newPrivacyStatus;
        listCases[0].Type = Constants.privacyCaseType;
        listCases[0].Sub_Type__c = Constants.accessRequestSubType;
        listCases[0].Brand_Privacy_OWA_Name__c = 'Calvin Klein Privacy Support';
        listCases[0].SuppliedEmail = 'test@test.com';
        insert listCases;
        PrivacyCaseTriggerHandler.isFirstRun = True;
        //Child case
        List<Case> listCasesChild = TestDataFactory.createCases(1);
        listCasesChild[0].contactId = getContact.Id;
        listCasesChild[0].Brand__c = '2';
        listCasesChild[0].Status = Constants.newPrivacyStatus;
        listCasesChild[0].Type = Constants.privacyCaseType;
        listCasesChild[0].Sub_Type__c = Constants.doNotSellorShare;
        listCasesChild[0].Brand_Privacy_OWA_Name__c = 'Calvin Klein Privacy Support';
        listCasesChild[0].SuppliedEmail = 'test@test.com';
        listCasesChild[0].ParentId = listCases[0].Id;
        listCasesChild[0].Data_Owner__c = genCon.Id;
        insert listCasesChild;
        
    }
    
    @isTest
    public static void processAccessCases() {
        Account genAcc = new Account();
        genAcc.Name = 'Test'+Math.random();
        insert genAcc;

        Contact genCon = new Contact();
        genCon.email = 'foo@example.com';
        genCon.lastName = 'generic contact ' + Math.random();
        genCon.AccountId = genAcc.id;
        genCon.Brand_Id__c = '9';
        genCon.RecordTypeId = Constants.dataOwnerContactRecordTypeId;
        genCon.System_Type__c = Constants.dataOwnerSupplemental;
        genCon.Additional_Email_1__c = 'test@test.com';
        genCon.Additional_Email_2__c = 'test@test.com';
        genCon.Additional_Email_3__c = 'test@test.com';
        genCon.Additional_Email_4__c = 'test@test.com';
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

        //Parent case
        listCases[0].contactId = getContact.Id;
        listCases[0].Brand__c = '2';
        listCases[0].Status = Constants.newPrivacyStatus;
        listCases[0].Type = Constants.privacyCaseType;
        listCases[0].Sub_Type__c = Constants.doNotSellorShare;
        listCases[0].Brand_Privacy_OWA_Name__c = 'Calvin Klein Privacy Support';
        listCases[0].SuppliedEmail = 'test@test.com';
        insert listCases;
        PrivacyCaseTriggerHandler.isFirstRun = True;
        listCases[0].Status = Constants.resolved;
        listCases[0].Sub_Type__c = Constants.privacyResolvedRejectedRequest;
        listCases[0].Resolution_Code__c = 'No Response';
        listCases[0].Sub_Type__c = Constants.accessRequestSubType;
        update listCases[0];
    }
    
    @isTest
    public static void processAccessCases1() {
        Account genAcc = new Account();
        genAcc.Name = 'Test'+Math.random();
        insert genAcc;

        Contact genCon = new Contact();
        genCon.email = 'foo@example.com';
        genCon.lastName = 'generic contact ' + Math.random();
        genCon.AccountId = genAcc.id;
        genCon.Brand_Id__c = '9';
        genCon.RecordTypeId = Constants.dataOwnerContactRecordTypeId;
        genCon.System_Type__c = Constants.dataOwnerSupplemental;
        genCon.Additional_Email_1__c = 'test@test.com';
        genCon.Additional_Email_2__c = 'test@test.com';
        genCon.Additional_Email_3__c = 'test@test.com';
        genCon.Additional_Email_4__c = 'test@test.com';
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

        //Parent case
        listCases[0].contactId = getContact.Id;
        listCases[0].Brand__c = '2';
        listCases[0].Status = Constants.newPrivacyStatus;
        listCases[0].Type = Constants.privacyCaseType;
        listCases[0].Sub_Type__c = Constants.doNotSellorShare;
        listCases[0].Brand_Privacy_OWA_Name__c = 'Calvin Klein Privacy Support';
        listCases[0].SuppliedEmail = 'test@test.com';
        insert listCases;
        PrivacyCaseTriggerHandler.isFirstRun = True;
        listCases[0].Status = Constants.resolved;
        listCases[0].Sub_Type__c = Constants.privacyResolvedRejectedRequest;
        listCases[0].Resolution_Code__c = Constants.privacyResolvedRejectedRequest;
        listCases[0].Sub_Type__c = Constants.accessRequestSubType;
        update listCases[0];
    }
    
    @isTest
    public static void processAccessCases2() {
        Account genAcc = new Account();
        genAcc.Name = 'Test'+Math.random();
        insert genAcc;

        Contact genCon = new Contact();
        genCon.email = 'foo@example.com';
        genCon.lastName = 'generic contact ' + Math.random();
        genCon.AccountId = genAcc.id;
        genCon.Brand_Id__c = '9';
        genCon.RecordTypeId = Constants.dataOwnerContactRecordTypeId;
        genCon.System_Type__c = Constants.dataOwnerSupplemental;
        genCon.Additional_Email_1__c = 'test@test.com';
        genCon.Additional_Email_2__c = 'test@test.com';
        genCon.Additional_Email_3__c = 'test@test.com';
        genCon.Additional_Email_4__c = 'test@test.com';
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

        //Parent case
        listCases[0].contactId = getContact.Id;
        listCases[0].Brand__c = '2';
        listCases[0].Status = Constants.newPrivacyStatus;
        listCases[0].Type = Constants.privacyCaseType;
        listCases[0].Sub_Type__c = Constants.doNotSellorShare;
        listCases[0].Brand_Privacy_OWA_Name__c = 'Calvin Klein Privacy Support';
        listCases[0].SuppliedEmail = 'test@test.com';
        insert listCases;
        PrivacyCaseTriggerHandler.isFirstRun = True;
        listCases[0].Status = Constants.resolved;
        listCases[0].Sub_Type__c = Constants.privacyResolvedRejectedRequest;
        listCases[0].Resolution_Code__c = Constants.privacyResolvedStalled;
        listCases[0].Sub_Type__c = Constants.accessRequestSubType;
        update listCases[0];
    }
    
    @isTest
    public static void processAccessCases3() {
        Account genAcc = new Account();
        genAcc.Name = 'Test'+Math.random();
        insert genAcc;

        Contact genCon = new Contact();
        genCon.email = 'foo@example.com';
        genCon.lastName = 'generic contact ' + Math.random();
        genCon.AccountId = genAcc.id;
        genCon.Brand_Id__c = '9';
        genCon.RecordTypeId = Constants.dataOwnerContactRecordTypeId;
        genCon.System_Type__c = Constants.dataOwnerSupplemental;
        genCon.Additional_Email_1__c = 'test@test.com';
        genCon.Additional_Email_2__c = 'test@test.com';
        genCon.Additional_Email_3__c = 'test@test.com';
        genCon.Additional_Email_4__c = 'test@test.com';
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

        //Parent case
        listCases[0].contactId = getContact.Id;
        listCases[0].Brand__c = '2';
        listCases[0].Status = Constants.newPrivacyStatus;
        listCases[0].Type = Constants.privacyCaseType;
        listCases[0].Sub_Type__c = Constants.doNotSellorShare;
        listCases[0].Brand_Privacy_OWA_Name__c = 'Calvin Klein Privacy Support';
        listCases[0].SuppliedEmail = 'test@test.com';
        insert listCases;
        PrivacyCaseTriggerHandler.isFirstRun = True;
        listCases[0].Status = Constants.resolved;
        listCases[0].Sub_Type__c = Constants.privacyResolvedRejectedRequest;
        listCases[0].Resolution_Code__c = Constants.privacyResolvedNoDataFound;
        listCases[0].Sub_Type__c = Constants.accessRequestSubType;
        listCases[0].Country_of_Residence__c = 'India';
        update listCases[0];
    }
    
    @isTest
    public static void processAccessCases4() {
        Account genAcc = new Account();
        genAcc.Name = 'Test'+Math.random();
        insert genAcc;

        Contact genCon = new Contact();
        genCon.email = 'foo@example.com';
        genCon.lastName = 'generic contact ' + Math.random();
        genCon.AccountId = genAcc.id;
        genCon.Brand_Id__c = '9';
        genCon.RecordTypeId = Constants.dataOwnerContactRecordTypeId;
        genCon.System_Type__c = Constants.dataOwnerSupplemental;
        genCon.Additional_Email_1__c = 'test@test.com';
        genCon.Additional_Email_2__c = 'test@test.com';
        genCon.Additional_Email_3__c = 'test@test.com';
        genCon.Additional_Email_4__c = 'test@test.com';
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

        //Parent case
        listCases[0].contactId = getContact.Id;
        listCases[0].Brand__c = '2';
        listCases[0].Status = Constants.newPrivacyStatus;
        listCases[0].Type = Constants.privacyCaseType;
        listCases[0].Sub_Type__c = Constants.doNotSellorShare;
        listCases[0].Brand_Privacy_OWA_Name__c = 'Calvin Klein Privacy Support';
        listCases[0].SuppliedEmail = 'test@test.com';
        insert listCases;
        PrivacyCaseTriggerHandler.isFirstRun = True;
        listCases[0].Status = Constants.resolved;
        listCases[0].Sub_Type__c = Constants.privacyResolvedRejectedRequest;
        listCases[0].Resolution_Code__c = Constants.privacyResolvedNoDataFound;
        listCases[0].Sub_Type__c = Constants.accessRequestSubType;
        listCases[0].Country_of_Residence__c = 'Canada';
        update listCases[0];
    }
    
    @isTest
    public static void processDeletionCase() {
        Account genAcc = new Account();
        genAcc.Name = 'Test'+Math.random();
        insert genAcc;

        Contact genCon = new Contact();
        genCon.email = 'foo@example.com';
        genCon.lastName = 'generic contact ' + Math.random();
        genCon.AccountId = genAcc.id;
        genCon.Brand_Id__c = '9';
        genCon.RecordTypeId = Constants.dataOwnerContactRecordTypeId;
        genCon.System_Type__c = Constants.dataOwnerSupplemental;
        genCon.Additional_Email_1__c = 'test@test.com';
        genCon.Additional_Email_2__c = 'test@test.com';
        genCon.Additional_Email_3__c = 'test@test.com';
        genCon.Additional_Email_4__c = 'test@test.com';
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

        //Parent case
        listCases[0].contactId = getContact.Id;
        listCases[0].Brand__c = '2';
        listCases[0].Status = Constants.newPrivacyStatus;
        listCases[0].Type = Constants.privacyCaseType;
        listCases[0].Sub_Type__c = Constants.doNotSellorShare;
        listCases[0].Brand_Privacy_OWA_Name__c = 'Calvin Klein Privacy Support';
        listCases[0].SuppliedEmail = 'test@test.com';
        insert listCases;
        PrivacyCaseTriggerHandler.isFirstRun = True;
        listCases[0].Status = Constants.resolved;
        listCases[0].Sub_Type__c = Constants.privacyResolvedRejectedRequest;
        listCases[0].Resolution_Code__c = Constants.privacyResolvedDataDeleted;
        listCases[0].Sub_Type__c = Constants.deletionRequestSubType;
        listCases[0].Country_of_Residence__c = 'Canada';
        update listCases[0];
    }
    
    @isTest
    public static void processDeletionCase1() {
        Account genAcc = new Account();
        genAcc.Name = 'Test'+Math.random();
        insert genAcc;

        Contact genCon = new Contact();
        genCon.email = 'foo@example.com';
        genCon.lastName = 'generic contact ' + Math.random();
        genCon.AccountId = genAcc.id;
        genCon.Brand_Id__c = '9';
        genCon.RecordTypeId = Constants.dataOwnerContactRecordTypeId;
        genCon.System_Type__c = Constants.dataOwnerSupplemental;
        genCon.Additional_Email_1__c = 'test@test.com';
        genCon.Additional_Email_2__c = 'test@test.com';
        genCon.Additional_Email_3__c = 'test@test.com';
        genCon.Additional_Email_4__c = 'test@test.com';
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

        //Parent case
        listCases[0].contactId = getContact.Id;
        listCases[0].Brand__c = '2';
        listCases[0].Status = Constants.newPrivacyStatus;
        listCases[0].Type = Constants.privacyCaseType;
        listCases[0].Sub_Type__c = Constants.doNotSellorShare;
        listCases[0].Brand_Privacy_OWA_Name__c = 'Calvin Klein Privacy Support';
        listCases[0].SuppliedEmail = 'test@test.com';
        insert listCases;
        PrivacyCaseTriggerHandler.isFirstRun = True;
        listCases[0].Status = Constants.resolved;
        listCases[0].Sub_Type__c = Constants.privacyResolvedRejectedRequest;
        listCases[0].Resolution_Code__c = Constants.privacyResolvedRejectedRequest;
        listCases[0].Sub_Type__c = Constants.deletionRequestSubType;
        listCases[0].Country_of_Residence__c = 'Canada';
        update listCases[0];
    }
    
    @isTest
    public static void processDeletionCase2() {
        Account genAcc = new Account();
        genAcc.Name = 'Test'+Math.random();
        insert genAcc;

        Contact genCon = new Contact();
        genCon.email = 'foo@example.com';
        genCon.lastName = 'generic contact ' + Math.random();
        genCon.AccountId = genAcc.id;
        genCon.Brand_Id__c = '9';
        genCon.RecordTypeId = Constants.dataOwnerContactRecordTypeId;
        genCon.System_Type__c = Constants.dataOwnerSupplemental;
        genCon.Additional_Email_1__c = 'test@test.com';
        genCon.Additional_Email_2__c = 'test@test.com';
        genCon.Additional_Email_3__c = 'test@test.com';
        genCon.Additional_Email_4__c = 'test@test.com';
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

        //Parent case
        listCases[0].contactId = getContact.Id;
        listCases[0].Brand__c = '2';
        listCases[0].Status = Constants.newPrivacyStatus;
        listCases[0].Type = Constants.privacyCaseType;
        listCases[0].Sub_Type__c = Constants.doNotSellorShare;
        listCases[0].Brand_Privacy_OWA_Name__c = 'Calvin Klein Privacy Support';
        listCases[0].SuppliedEmail = 'test@test.com';
        insert listCases;
        PrivacyCaseTriggerHandler.isFirstRun = True;
        listCases[0].Status = Constants.resolved;
        listCases[0].Sub_Type__c = Constants.privacyResolvedRejectedRequest;
        listCases[0].Resolution_Code__c = Constants.privacyResolvedNoResponse;
        listCases[0].Sub_Type__c = Constants.deletionRequestSubType;
        listCases[0].Country_of_Residence__c = 'Canada';
        update listCases[0];
    }
    
     @isTest
    public static void processDeletionCase3() {
        Account genAcc = new Account();
        genAcc.Name = 'Test'+Math.random();
        insert genAcc;

        Contact genCon = new Contact();
        genCon.email = 'foo@example.com';
        genCon.lastName = 'generic contact ' + Math.random();
        genCon.AccountId = genAcc.id;
        genCon.Brand_Id__c = '9';
        genCon.RecordTypeId = Constants.dataOwnerContactRecordTypeId;
        genCon.System_Type__c = Constants.dataOwnerSupplemental;
        genCon.Additional_Email_1__c = 'test@test.com';
        genCon.Additional_Email_2__c = 'test@test.com';
        genCon.Additional_Email_3__c = 'test@test.com';
        genCon.Additional_Email_4__c = 'test@test.com';
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

        //Parent case
        listCases[0].contactId = getContact.Id;
        listCases[0].Brand__c = '2';
        listCases[0].Status = Constants.newPrivacyStatus;
        listCases[0].Type = Constants.privacyCaseType;
        listCases[0].Sub_Type__c = Constants.doNotSellorShare;
        listCases[0].Brand_Privacy_OWA_Name__c = 'Calvin Klein Privacy Support';
        listCases[0].SuppliedEmail = 'test@test.com';
        insert listCases;
        PrivacyCaseTriggerHandler.isFirstRun = True;
        listCases[0].Status = Constants.resolved;
        listCases[0].Sub_Type__c = Constants.privacyResolvedRejectedRequest;
        listCases[0].Resolution_Code__c = Constants.privacyResolvedStalled;
        listCases[0].Sub_Type__c = Constants.deletionRequestSubType;
        listCases[0].Country_of_Residence__c = 'Canada';
        update listCases[0];
    }
    
    @isTest
    public static void processDeletionCase4() {
        Account genAcc = new Account();
        genAcc.Name = 'Test'+Math.random();
        insert genAcc;

        Contact genCon = new Contact();
        genCon.email = 'foo@example.com';
        genCon.lastName = 'generic contact ' + Math.random();
        genCon.AccountId = genAcc.id;
        genCon.Brand_Id__c = '9';
        genCon.RecordTypeId = Constants.dataOwnerContactRecordTypeId;
        genCon.System_Type__c = Constants.dataOwnerSupplemental;
        genCon.Additional_Email_1__c = 'test@test.com';
        genCon.Additional_Email_2__c = 'test@test.com';
        genCon.Additional_Email_3__c = 'test@test.com';
        genCon.Additional_Email_4__c = 'test@test.com';
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

        //Parent case
        listCases[0].contactId = getContact.Id;
        listCases[0].Brand__c = '2';
        listCases[0].Status = Constants.newPrivacyStatus;
        listCases[0].Type = Constants.privacyCaseType;
        listCases[0].Sub_Type__c = Constants.doNotSellorShare;
        listCases[0].Brand_Privacy_OWA_Name__c = 'Calvin Klein Privacy Support';
        listCases[0].SuppliedEmail = 'test@test.com';
        insert listCases;
        PrivacyCaseTriggerHandler.isFirstRun = True;
        listCases[0].Status = Constants.resolved;
        listCases[0].Sub_Type__c = Constants.privacyResolvedRejectedRequest;
        listCases[0].Resolution_Code__c = Constants.privacyResolvedNoDataFound;
        listCases[0].Sub_Type__c = Constants.deletionRequestSubType;
        listCases[0].Country_of_Residence__c = 'India';
        update listCases[0];
    }
    
    @isTest
    public static void processDeletionCase5() {
        Account genAcc = new Account();
        genAcc.Name = 'Test'+Math.random();
        insert genAcc;

        Contact genCon = new Contact();
        genCon.email = 'foo@example.com';
        genCon.lastName = 'generic contact ' + Math.random();
        genCon.AccountId = genAcc.id;
        genCon.Brand_Id__c = '9';
        genCon.RecordTypeId = Constants.dataOwnerContactRecordTypeId;
        genCon.System_Type__c = Constants.dataOwnerSupplemental;
        genCon.Additional_Email_1__c = 'test@test.com';
        genCon.Additional_Email_2__c = 'test@test.com';
        genCon.Additional_Email_3__c = 'test@test.com';
        genCon.Additional_Email_4__c = 'test@test.com';
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

        //Parent case
        listCases[0].contactId = getContact.Id;
        listCases[0].Brand__c = '2';
        listCases[0].Status = Constants.newPrivacyStatus;
        listCases[0].Type = Constants.privacyCaseType;
        listCases[0].Sub_Type__c = Constants.doNotSellorShare;
        listCases[0].Brand_Privacy_OWA_Name__c = 'Calvin Klein Privacy Support';
        listCases[0].SuppliedEmail = 'test@test.com';
        insert listCases;
        PrivacyCaseTriggerHandler.isFirstRun = True;
        listCases[0].Status = Constants.resolved;
        listCases[0].Sub_Type__c = Constants.privacyResolvedRejectedRequest;
        listCases[0].Resolution_Code__c = Constants.privacyResolvedNoDataFound;
        listCases[0].Sub_Type__c = Constants.deletionRequestSubType;
        listCases[0].Country_of_Residence__c = 'Canada';
        update listCases[0];
    }
    
    @isTest
    public static void processUpdationCase() {
        Account genAcc = new Account();
        genAcc.Name = 'Test'+Math.random();
        insert genAcc;

        Contact genCon = new Contact();
        genCon.email = 'foo@example.com';
        genCon.lastName = 'generic contact ' + Math.random();
        genCon.AccountId = genAcc.id;
        genCon.Brand_Id__c = '9';
        genCon.RecordTypeId = Constants.dataOwnerContactRecordTypeId;
        genCon.System_Type__c = Constants.dataOwnerSupplemental;
        genCon.Additional_Email_1__c = 'test@test.com';
        genCon.Additional_Email_2__c = 'test@test.com';
        genCon.Additional_Email_3__c = 'test@test.com';
        genCon.Additional_Email_4__c = 'test@test.com';
        genCon.DataOwner_Subtype__c  = 'Unsubscribe';
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

        //Parent case
        listCases[0].contactId = getContact.Id;
        listCases[0].Brand__c = '2';
        listCases[0].Status = Constants.newPrivacyStatus;
        listCases[0].Type = Constants.privacyCaseType;
        listCases[0].Sub_Type__c = Constants.doNotSellorShare;
        listCases[0].Brand_Privacy_OWA_Name__c = 'Calvin Klein Privacy Support';
        listCases[0].SuppliedEmail = 'test@test.com';
        
        insert listCases;
        PrivacyCaseTriggerHandler.isFirstRun = True;
        listCases[0].Status = Constants.resolved;
        Id recId = [SELECT Id from RecordType WHERE sObjectType = 'Case' And RecordType.DeveloperName = 'Privacy_Request' LIMIT 1].Id;
        listCases[0].Sub_Type__c = Constants.privacyResolvedRejectedRequest;
        listCases[0].RecordTypeId = recId;
        listCases[0].Resolution_Code__c = Constants.privacyResolvedDataUpdated;
        listCases[0].Sub_Type__c = Constants.rectifyRequestSubType;
        listCases[0].Country_of_Residence__c = 'Canada';
        update listCases[0];
    }
    
    @isTest
    public static void processUpdationCase1() {
        Account genAcc = new Account();
        genAcc.Name = 'Test'+Math.random();
        insert genAcc;

        Contact genCon = new Contact();
        genCon.email = 'foo@example.com';
        genCon.lastName = 'generic contact ' + Math.random();
        genCon.AccountId = genAcc.id;
        genCon.Brand_Id__c = '9';
        genCon.RecordTypeId = Constants.dataOwnerContactRecordTypeId;
        genCon.System_Type__c = Constants.dataOwnerSupplemental;
        genCon.Additional_Email_1__c = 'test@test.com';
        genCon.Additional_Email_2__c = 'test@test.com';
        genCon.Additional_Email_3__c = 'test@test.com';
        genCon.Additional_Email_4__c = 'test@test.com';
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

        //Parent case
        listCases[0].contactId = getContact.Id;
        listCases[0].Brand__c = '2';
        listCases[0].Status = Constants.newPrivacyStatus;
        listCases[0].Type = Constants.privacyCaseType;
        listCases[0].Sub_Type__c = Constants.doNotSellorShare;
        listCases[0].Brand_Privacy_OWA_Name__c = 'Calvin Klein Privacy Support';
        listCases[0].SuppliedEmail = 'test@test.com';
        insert listCases;
        PrivacyCaseTriggerHandler.isFirstRun = True;
        listCases[0].Status = Constants.resolved;
        listCases[0].Sub_Type__c = Constants.privacyResolvedRejectedRequest;
        listCases[0].Resolution_Code__c = Constants.privacyResolvedNoDataFound;
        listCases[0].Sub_Type__c = Constants.rectifyRequestSubType;
        listCases[0].Country_of_Residence__c = 'Canada';
        update listCases[0];
    }
    
    @isTest
    public static void processUpdationCase2() {
        Account genAcc = new Account();
        genAcc.Name = 'Test'+Math.random();
        insert genAcc;

        Contact genCon = new Contact();
        genCon.email = 'foo@example.com';
        genCon.lastName = 'generic contact ' + Math.random();
        genCon.AccountId = genAcc.id;
        genCon.Brand_Id__c = '9';
        genCon.RecordTypeId = Constants.dataOwnerContactRecordTypeId;
        genCon.System_Type__c = Constants.dataOwnerSupplemental;
        genCon.Additional_Email_1__c = 'test@test.com';
        genCon.Additional_Email_2__c = 'test@test.com';
        genCon.Additional_Email_3__c = 'test@test.com';
        genCon.Additional_Email_4__c = 'test@test.com';
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

        //Parent case
        listCases[0].contactId = getContact.Id;
        listCases[0].Brand__c = '2';
        listCases[0].Status = Constants.newPrivacyStatus;
        listCases[0].Type = Constants.privacyCaseType;
        listCases[0].Sub_Type__c = Constants.doNotSellorShare;
        listCases[0].Brand_Privacy_OWA_Name__c = 'Calvin Klein Privacy Support';
        listCases[0].SuppliedEmail = 'test@test.com';
        insert listCases;
        PrivacyCaseTriggerHandler.isFirstRun = True;
        listCases[0].Status = Constants.resolved;
        listCases[0].Sub_Type__c = Constants.privacyResolvedRejectedRequest;
        listCases[0].Resolution_Code__c = Constants.privacyResolvedNoDataFound;
        listCases[0].Sub_Type__c = Constants.rectifyRequestSubType;
        listCases[0].Country_of_Residence__c = 'India';
        update listCases[0];
    }
    
    
    @isTest
    public static void processdoNotSellShareCase2() {
        Account genAcc = new Account();
        genAcc.Name = 'Test'+Math.random();
        insert genAcc;

        Contact genCon = new Contact();
        genCon.email = 'foo@example.com';
        genCon.lastName = 'generic contact ' + Math.random();
        genCon.AccountId = genAcc.id;
        genCon.Brand_Id__c = '9';
        genCon.RecordTypeId = Constants.dataOwnerContactRecordTypeId;
        genCon.System_Type__c = Constants.dataOwnerSupplemental;
        genCon.Additional_Email_1__c = 'test@test.com';
        genCon.Additional_Email_2__c = 'test@test.com';
        genCon.Additional_Email_3__c = 'test@test.com';
        genCon.Additional_Email_4__c = 'test@test.com';
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

        //Parent case
        listCases[0].contactId = getContact.Id;
        listCases[0].Brand__c = '2';
        listCases[0].Status = Constants.newPrivacyStatus;
        listCases[0].Type = Constants.privacyCaseType;
        listCases[0].Sub_Type__c = Constants.doNotSellorShare;
        listCases[0].Brand_Privacy_OWA_Name__c = 'Calvin Klein Privacy Support';
        listCases[0].SuppliedEmail = 'test@test.com';
        insert listCases;
        PrivacyCaseTriggerHandler.isFirstRun = True;
        listCases[0].Status = Constants.resolved;
        listCases[0].Sub_Type__c = Constants.privacyResolvedRejectedRequest;
        listCases[0].Resolution_Code__c = Constants.privacyResolvedNoDataFound;
        listCases[0].Sub_Type__c = Constants.doNotSellorShare;
        listCases[0].Country_of_Residence__c = 'India';
        update listCases[0];
    }
    
}