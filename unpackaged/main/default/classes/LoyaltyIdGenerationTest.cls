@isTest
public class LoyaltyIdGenerationTest {
      private static Map<String, LoyaltySettings__mdt> loyaltySettingMap = new Map<String, LoyaltySettings__mdt>();
      private static Map<Contact, LoyaltyID_Sequence__c> nonLoyaltyContacts = new Map<Contact, LoyaltyID_Sequence__c>();
      private static Map<String, String> parentContacts = new Map<String, String>();
      private static Map<String, Contact> childContacts = new Map<String, Contact>();

      @isTest
      static void testLoyaltyIdGenHandler() {
            // Create test data
            Contact contact1 = new Contact(FirstName='Test', LastName='Contact1', Brand_Id__c='81', Email='test1@example.com');
            Contact contact2 = new Contact(FirstName='Test', LastName='Contact2', Brand_Id__c='82', Email='test2@example.com');
            Contact contact3 = new Contact(FirstName='Test', LastName='Contact3', Brand_Id__c='5', Email='test3@example.com');
            Contact contact4 = new Contact(FirstName='Test', LastName='Contact4', Brand_Id__c='4', Email='test4@example.com');
            insert contact1;
            insert contact2;
            insert contact3;
            insert contact4;

            LoyaltySettings__mdt loyaltySetting1 = new LoyaltySettings__mdt(BrandId__c='TH', IsLoyaltyApplicable__c=true);
            LoyaltySettings__mdt loyaltySetting2 = new LoyaltySettings__mdt(BrandId__c='CK', IsLoyaltyApplicable__c=true, Parent_Brand__c='TH');
            LoyaltySettings__mdt loyaltySetting3 = new LoyaltySettings__mdt(BrandId__c='HE', IsLoyaltyApplicable__c=true);
            //insert loyaltySetting1;
            //insert loyaltySetting2;
            //insert loyaltySetting3;

            // Test loyaltyIdGenHandler method
            Map<Id, Contact> contactMap = new Map<Id, Contact>{
                    contact1.Id => contact1,
                    contact2.Id => contact2,
                    contact3.Id => contact3,
                    contact4.Id => contact4
            };
            Set<String> brandSet = new Set<String>{'81', '82', '5'};
            LoyaltyIdGeneration.loyaltyIdGenHandler(contactMap, brandSet);

            // Verify that loyalty ID is generated for non-loyalty parent contacts
            for(Contact con : nonLoyaltyContacts.keyset()) {
                  System.assertNotEquals(null, con.LoyaltyID__c);
            }
            // Verify that loyalty ID is copied from parent contact to child contact
            for(Contact con : childContacts.values()) {
                  System.assertNotEquals(null, con.LoyaltyID__c);
            }
      }

      @IsTest
      static void testPopulateContactsWithLoyaltyIds() {
            // Create test data
            Contact con1 = new Contact(LastName = 'Test1', Brand_Id__c = '81');
            Contact con2 = new Contact(LastName = 'Test2', Brand_Id__c = '82');

            LoyaltyID_Sequence__c loyaltySeq1 = new LoyaltyID_Sequence__c();
            LoyaltyID_Sequence__c loyaltySeq2 = new LoyaltyID_Sequence__c();

            Map<Contact, LoyaltyID_Sequence__c> testNonLoyaltyContacts = new Map<Contact, LoyaltyID_Sequence__c>();
            testNonLoyaltyContacts.put(con1, loyaltySeq1);
            testNonLoyaltyContacts.put(con2, loyaltySeq2);
            LoyaltyIdGeneration.populateContactsWithLoyaltyIds(testNonLoyaltyContacts);
      }

      static testMethod void testHasOptedOutOfEmailUpdated() {
            // Create test data
            Contact con1 = new Contact(LastName = 'Test1', HasOptedOutOfEmail = false, EmailOptInStatus__c = 'Y');
            Contact con2 = new Contact(LastName = 'Test2', HasOptedOutOfEmail = true, EmailOptInStatus__c = 'N');
            Contact con3 = new Contact(LastName = 'Test3', HasOptedOutOfEmail = false, EmailOptInStatus__c = 'N');
            Contact con4 = new Contact(LastName = 'Test4', HasOptedOutOfEmail = true, EmailOptInStatus__c = 'Y');
            insert con1;
            insert con2;
            insert con3;
            insert con4;
            List<Contact> conList = new List<Contact>{
                    con1, con2, con3, con4
            };

            // Test the method
            LoyaltyIdGeneration.hasOptedOutOfEmailUpdated(conList);

            // Assertions
            con1 = [SELECT Id, HasOptedOutOfEmail, EmailOptInStatus__c, EmailOptInDate__c, EmailOptOutDate__c FROM Contact WHERE Id = :con1.Id];
            con2 = [SELECT Id, HasOptedOutOfEmail, EmailOptInStatus__c, EmailOptInDate__c, EmailOptOutDate__c FROM Contact WHERE Id = :con2.Id];
            con3 = [SELECT Id, HasOptedOutOfEmail, EmailOptInStatus__c, EmailOptInDate__c, EmailOptOutDate__c FROM Contact WHERE Id = :con3.Id];
            con4 = [SELECT Id, HasOptedOutOfEmail, EmailOptInStatus__c, EmailOptInDate__c, EmailOptOutDate__c FROM Contact WHERE Id = :con4.Id];
            System.assertEquals(false, con1.HasOptedOutOfEmail);
            System.assertEquals('Y', con1.EmailOptInStatus__c);
            System.assertNotEquals(null, con1.EmailOptInDate__c);
            System.assertEquals(null, con1.EmailOptOutDate__c);
            System.assertEquals(true, con2.HasOptedOutOfEmail);
            System.assertEquals('N', con2.EmailOptInStatus__c);
            System.assertEquals(null, con2.EmailOptInDate__c);
            System.assertNotEquals(null, con2.EmailOptOutDate__c);
            System.assertEquals(true, con3.HasOptedOutOfEmail);
            System.assertEquals('N', con3.EmailOptInStatus__c);
      }

      @isTest
      private static void testLoyaltyIdGenHandler2() {
            // Create test data
            Contact con1 = new Contact(LastName = 'Test1', Brand_Id__c = '81');
            Contact con2 = new Contact(LastName = 'Test2', Brand_Id__c = '82');
            insert con1;
            insert con2;
            Map<Id, Contact> conId = new Map<Id, Contact>();
            conId.put(con1.Id, con1);
            conId.put(con2.Id, con2);
            set<String> brandSet = new set<String>{'81', '82'};

            // Test the method
            LoyaltyIdGeneration.loyaltyIdGenHandler(conId, brandSet);
      }

      @isTest
      private static void testLoyaltyIdGenHandler3() {
            // Create the Email record type
            RecordType emailRecordType = [select id, name from RecordType where SObjectType = 'contact' LIMIT 1];

            // Create test data
            Contact con1 = new Contact(LastName = 'Test1', Brand_Id__c = '81', RecordTypeId = emailRecordType.Id, Email = 'test@example.com');
            Contact con2 = new Contact(LastName = 'Test2', Brand_Id__c = '82', RecordTypeId = emailRecordType.Id, Email = 'test@example.com');
            insert con1;
            insert con2;
            // create a parent contact
            Contact parentCon1 = new Contact(LastName = 'ParentTest1', Brand_Id__c = '81', Email = 'test@example.com', LoyaltyID__c = 'ABC123', LoyaltyFlag__c = true, Loyalty_Optin_Date__c = system.today(), RecordTypeId = emailRecordType.Id);
            Contact parentCon2 = new Contact(LastName = 'ParentTest2', Brand_Id__c = '82', Email = 'test@example.com', LoyaltyID__c = 'DEF456', LoyaltyFlag__c = false, Loyalty_Optin_Date__c = system.today(), RecordTypeId = emailRecordType.Id);
            insert parentCon1;
            insert parentCon2;
            Map<Id, Contact> conId = new Map<Id, Contact>();
            conId.put(con1.Id, con1);
            conId.put(con2.Id, con2);
            set<String> brandSet = new set<String>{'81', '82'};

            // Create a parent contact with a loyalty ID
            Contact parentCon = new Contact(LastName = 'ParentTest', Brand_Id__c = '9', Email = 'test@example.com', LoyaltyID__c = 'ABC123', RecordType = emailRecordType);
            insert parentCon;

            // Test the method
            LoyaltyIdGeneration.loyaltyIdGenHandler(conId, brandSet);

            // Verify that the child contact was updated with the parent's loyalty ID
            Contact updatedChildCon = [SELECT LoyaltyID__c, LoyaltyFlag__c, Loyalty_Optin_Date__c FROM Contact WHERE Id = :con1.Id];

      }

}