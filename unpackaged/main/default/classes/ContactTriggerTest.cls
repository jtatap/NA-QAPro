@isTest
private class ContactTriggerTest {

    /*private static testmethod void ContactTriggerTest() {

        insert new et4ae5__Configuration__c(et4ae5__Support_Ticket_Recipient__c = 'example@example.com');
        Test.startTest();
        Contact c = new Contact(LastName='TestExample',Brand_Id__c='9');
        c.Region__c = 'APAC';
        c.Market__c = 'ANZ';
        c.Country__c = 'AUS';
        insert c;
        System.assert(!String.isBlank(c.Id));
        Test.stopTest();

    }*/

    @isTest static void TestDeleteContact() {
        // Test data setup
        Account acc = new Account();
        acc.Name = 'generic Account' + Math.random();
        
        insert acc;

        Contact con = new Contact();
        con.email = 'foo@example.com';
        con.lastName = 'generic contact ' + Math.random();
        con.AccountId = acc.id;
        con.Brand_Id__c='1';
        
        insert con;

        GenericRecords__c genRec = new GenericRecords__c(
                Name = Constants.privacyContactGenericRecordSettingName,
                recordId__c = con.Id
        );
        insert genRec;

        GenericRecords__c genRecAcct = new GenericRecords__c(
                Name = Constants.AccountGenericRecordSettingName,
                recordId__c = acc.Id
        );
        insert genRecAcct;

        Account acct = new Account(
                Name='Test Account ' + Math.random()
        );
       
        insert acct;
        Contact cont = new Contact(
                LastName='contact ' + Math.random(),
                AccountId=acct.Id,Brand_Id__c='1',
                RecordTypeId=Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId()
        );
        
        insert cont;
        Asset a = new Asset(
                ContactId=cont.Id,
                Name='Asset ' + Math.random()
        );
        insert a;
        Case c = new Case(
                ContactId=cont.Id,
                AccountId=acct.Id,
                Origin='Phone',
                Brand__c='1',
                Status='Open',
                RecordTypeId=Constants.supportCaseRecordTypeId,
                AssetId=a.Id
        );
        insert c;
        Contract ct = new Contract(
                CustomerSignedId=cont.Id,
                AccountId=acct.Id
        );
        insert ct;

        // Perform test
        Test.startTest();
        Database.DeleteResult result = Database.delete(cont, false);
        Test.stopTest();
        
       // System.assert(result.isSuccess());
       System.assertEquals(true,result.isSuccess());
    }
    @isTest
    public static void upsertChildContactOnParentupdateTest(){
        Test.startTest();
        Account acct = new Account(Name='Test Account ' + Math.random());
       
        insert acct;
        Contact cont = new Contact(LastName='contact ' + Math.random(),AccountId=acct.Id,Brand_Id__c='1',
                RecordTypeId=Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId());
        
        insert cont;
        cont.EmailOptInStatus__c = 'N';
        update cont;
        cont.EmailOptInStatus__c = 'Y';
        update cont;
        Test.stopTest();
    }
    @istest
    public static void emailPreferenceTest(){
        Test.startTest();
        Account acct = new Account(Name='Test Account ' + Math.random());
        
        insert acct;
        Contact cont = new Contact(LastName='contact ' + Math.random(),AccountId=acct.Id,Brand_Id__c='2',
                                   StoreOfCapture__c='601',WelcomeSource__c='02',
                                   RecordTypeId=Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId());
       
        insert cont;
        
        Test.stopTest();
    }
    @isTest
    public static void accountAssociationtest(){
        Test.startTest();
        Id recid = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId(); 
        Account acct = new Account(Name='Test Account ' + Math.random());
        
        insert acct;
        Contact cont = new Contact(LastName='contact ' + Math.random(),AccountId=acct.Id,Brand_Id__c='1',
                                   StoreOfCapture__c='601',WelcomeSource__c='02',Email= 'ex@test.com',
                                   RecordTypeId=recid,Status__c ='ACTIVE');
        
        insert cont;
        List<COntact> cntlist = new List<Contact>();
        Contact cnt = new Contact(FirstName = 'Child',LastName ='Brand84',Email ='ex@test.com',
                                  Brand_Id__c='1',Status__c ='ACTIVE');
        Contact cnt1 = new Contact(FirstName = 'Parent',LastName ='Brand4',Email ='ex@test.com',
                                   Brand_Id__c='1',Status__c ='ACTIVE');
        Contact cnt2 = new Contact(FirstName = 'Parent',LastName ='Bramd3',Email ='exp@ex.com',
                                  Brand_Id__c='1',Status__c ='ACTIVE');
        cntlist.add(cnt2);
        cntlist.add(cnt);
        cntlist.add(cnt1);
        insert cntlist;
        
        Test.stopTest();
    }
    
    @istest
    public static void searchContactTset(){
        Test.startTest();
        Account acct = new Account(Name='Test Account ' + Math.random());
        
        insert acct;
        Contact cont = new Contact(LastName='contact ' + Math.random(),AccountId=acct.Id,Brand_Id__c='2',
                                   StoreOfCapture__c='601',WelcomeSource__c='02',Source_System__c='Test',
                                   RecordTypeId=Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId());
        
        insert cont;
        
        cont.Status__c ='ACTIVE';
        update cont;
        
        Test.stopTest();
    }
    
     @istest
    public static void testData1(){
        
        Account acct = new Account(Name='Test Account ' + Math.random());
        
        insert acct;
        Contact cont = new Contact(LastName='contact ' + Math.random(),AccountId=acct.Id,Brand_Id__c='11',
                                   StoreOfCapture__c='601',WelcomeSource__c='02',Source_System__c='Test',Email='test@pvh.com',
                                   RecordTypeId=Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId());
        
        insert cont;
        
    }
    
   public static testmethod void TCHistoricalContactHandlerTest(){
       Test.startTest();
       
        Account acct = new Account(Name='Test Account123 ' + Math.random());
        
        insert acct;
        datetime createdDate= Datetime.now().addDays(-1);
       // List<Contact> conList=new List<Contact>();
       Map<Id,Contact> conList=new Map<Id,Contact>(); 
        Contact cont = new Contact(LastName='contact11 ' + Math.random(),AccountId=acct.Id,Brand_Id__c='11',FirstName='Test',EmailOptInStatus__c='N',
                                   T_C_Fit_Quiz_Token__c='test123',T_C_Purchaser__c=true,Phone='123456789',MailingCity='test',StoreOfCapture__c='601',WelcomeSource__c='02',Source_System__c='Test',Email='testHistorical@pvh.com',CreatedDate=createdDate,
                                   MailingState='test',MailingStreet='test',MailingPostalCode='23456',RecordTypeId=Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId());
      
        
        insert cont;
         conList.put(cont.ID,cont);
     
        
        if(conList.values().size()>0){
            update conList.values();
        }
      

      List<Contact> conoldList=new List<Contact>();
      conoldList=[Select Id ,Brand_Id__c, Email from Contact where Brand_Id__c='11' AND Email='testHistorical@pvh.com'] ;
        Contact cont3 = new Contact(LastName='contact1234 ' + Math.random(),AccountId=acct.Id,Brand_Id__c='11',
                                   StoreOfCapture__c='601',WelcomeSource__c='02',Source_System__c='Test3',Email='testHistorical@pvh.com',
                                   RecordTypeId=Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId());
   
       
       insert cont3;
     Test.stopTest();                
    }
     @istest
    public static void loyaltyTest(){
        Test.startTest();
        Account acct = new Account(Name='Test Account ' + Math.random());
        
        insert acct;
        Contact cont = new Contact(LastName='contact ' + Math.random(),AccountId=acct.Id,Brand_Id__c='2',
                                   StoreOfCapture__c='601',WelcomeSource__c='02',Email='test.1@pvh.com',LoyaltyID__c='',
                                   RecordTypeId=Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId());
        
        insert cont;
        
        Test.stopTest();
    }
    @isTest public static void TestLoyaltyId() {
         list<User> lstUser =  new list<User>();
        Id p = [select id from profile where name='Tier I CSR PVH'].id;
        system.debug('p**'+P);
        User U = new User(alias = 'test1233', email='test123@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing567', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p, country='United States',IsActive =true,
         timezonesidkey='America/Los_Angeles', username='testerPVH123@noemail.com');       
          lstUser.add(U);       
          insert lstUser; 
        system.runAs(U){
        // Test data setup
        Account acc = new Account();
        acc.Name = 'LoyaltyAccount';
       
        insert acc;

       
        Test.startTest();
         Contact cont1 = new Contact();
               cont1.LastName='Parent contact ';
                cont1.AccountId=acc.Id;
                cont1.Brand_Id__c='1';
                cont1.Email='LoyaltyId@example.com';
                cont1.HasOptedOutOfEmail=true;
                
                cont1.RecordTypeId=Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId();
       
        insert cont1;
        cont1.HasOptedOutOfEmail=false;
          update cont1;
        Contact con = new Contact();
        con.email = 'LoyaltyId@example.com';
        con.lastName = 'Loyaltycontact';
        con.AccountId = acc.id;
        con.LoyaltyID__c='';
        con.Brand_Id__c='1';
       
        insert con;
        //con.LoyaltyID__c='';
        //update con;
        
        Test.stopTest();
        }
 }

 @isTest public static void TestMcInte() {
    list<User> lstUser =  new list<User>();
   Id p = [select id from profile where name='PVHIntegrationAPIUser'].id;
   system.debug('p**'+P);
   User U = new User(alias = 'MC1233', email='MCIntegration@noemail.com',
   emailencodingkey='UTF-8', lastname='MC Integration', languagelocalekey='en_US',
   localesidkey='en_US', profileid = p, country='United States',IsActive =true,
    timezonesidkey='America/Los_Angeles', username='MCIntegration@noemail.com');
    lstUser.add(U);
    
   
     insert lstUser; 
   system.runAs(U){
   Account acc1 = new Account();
   acc1.Name = 'LoyaltyAccount';
   insert acc1;

  
   Test.startTest();
    Contact cont2 = new Contact();
          cont2.LastName='Parent contact ';
           cont2.AccountId=acc1.Id;
           cont2.Brand_Id__c='2';
           cont2.Email='LoyaltyId@example.com';
           cont2.HasOptedOutOfEmail=false;
           cont2.RecordTypeId=Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId();
  
   insert cont2;
    cont2.HasOptedOutOfEmail=true;
   update cont2;
   Test.stopTest();
   }   
}

@isTest public static void TestSFCCInte() {
    list<User> lstUser =  new list<User>();
   Id p = [select id from profile where name='PVHIntegrationAPIUser'].id;
   system.debug('p**'+P);
   User U = new User(alias = 'MC1233', email='SFCCIntegrationUser@noemail.com',
   emailencodingkey='UTF-8', lastname='SFCC Integration User', languagelocalekey='en_US',
   localesidkey='en_US', profileid = p, country='United States',IsActive =true,
    timezonesidkey='America/Los_Angeles', username='SFCCIntegrationUser@noemail.com');
    lstUser.add(U);
    
   
     insert lstUser; 
   system.runAs(U){
   Account acc1 = new Account();
   acc1.Name = 'LoyaltyAccount';
   insert acc1;

  
   Test.startTest();
    Contact cont2 = new Contact();
          cont2.LastName='Parent contact ';
           cont2.AccountId=acc1.Id;
           cont2.Brand_Id__c='2';
           cont2.Email='LoyaltyId@example.com';
           cont2.B2C_Customer_No__c = '12345';
           cont2.HasOptedOutOfEmail=false;
           cont2.B2C_Is_Enabled__c = false;
           cont2.RecordTypeId=Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId();
  
   insert cont2;
    cont2.HasOptedOutOfEmail=true;
   update cont2;
   Test.stopTest();
   }   
}
   @isTest
   public static void handleBeforeUpdateTest(){
      // Account acc = new Account();
       // acc.Name = 'generic Account1111' + Math.random();
        
        //insert acc;
      // acc.Customer_Id__c = 'C04013020814';
        Contact con = new Contact();
        con.email = 'foo111@example.com';
        con.lastName = 'generic contact11 ' + Math.random();
        //con.AccountId = acc.id;
        con.Brand_Id__c='1';
       	con.Customer_Id__c = 'Cxx04013020812';
        
        insert con;
       Map<Id,Contact> oldMap = new Map<Id,Contact>{con.Id => con};
       con.email = 'foo111@example.com';
       
       update con;
        
    } 
    
    @isTest
    public static void searchParentBrandContactTest(){
         Account acc = new Account();
        acc.Name = 'generic Account12' + Math.random();
        
        insert acc;
      // acc.Customer_Id__c = 'C04013020814';
       update acc;

        Contact con = new Contact();
        con.email = 'foo@example.com';
        con.lastName = 'generic contact11 ' + Math.random();
        con.AccountId = acc.id;
        con.Brand_Id__c='1';
       	con.Customer_Id__c = 'C04013020812';
        
        insert con;
        List<Contact> conList = new List<Contact>();
        
        NF_ContactTriggerHelper.searchParentBrandContact(conList);
        
    }
}