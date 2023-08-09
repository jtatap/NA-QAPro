@isTest
public class OlgaStagingTableTriggerTest {
    @TestSetup
    static void makeData(){
        List<Account> accountList = new List<Account>();
        Account a1 = new Account(
                Name = 'rob j'
        );
        accountList.add(a1);

        Account a2 = new Account(
                Name = 'Robert j'
        );
        accountList.add(a2);

        Account a3 = new Account(
                Name = 'jack j'
        );
        accountList.add(a3);

        insert accountList;


        List<Contact> contactList = new List<Contact>();
        Contact c1 = new Contact(
                Brand_Id__c    = '1',
                LastName   = 'J',
                FirstName = 'Rob',
                Email = 'rob@test.com',
                AccountId = a1.id
        );
        contactList.add(c1);

        Contact c2 = new Contact(    //same as c1, with different last name
                Brand_Id__c    = '1',
                LastName   = 'k',
                FirstName = 'Rob',
                Email = 'rob@test.com',
                AccountId = a1.id
        );
        contactList.add(c2);

        Contact c3 = new Contact(  // same as c1, with diff email
                Brand_Id__c    = '1',
                LastName   = 'J',
                FirstName = 'Rob',
                Email =  'bob@test.com',
                AccountId = a1.id
        );
        contactList.add(c3);

        Contact c4 = new Contact(  // same as c1, with diff first name
                Brand_Id__c    = '1',
                LastName   = 'J',
                FirstName = 'Bob',
                Email =  'rob@test.com',
                AccountId = a1.id
        );
        contactList.add(c4);

        Contact c5 = new Contact(  // unique contact for brand 1
                Brand_Id__c    = '1',
                LastName   = 'J',
                FirstName = 'Robert',
                Email =  'robert@test.com',
                AccountId = a1.id
        );
        contactList.add(c5);

        Contact c5a = new Contact(  // unique contact for brand 1 for email and first name
                Brand_Id__c    = '1',
                LastName   = 'J',
                FirstName = 'John',
                Email =  'robert@test.com',
                AccountId = a1.id
        );
        contactList.add(c5a);

        Contact c5b = new Contact(  // unique contact for brand 1 for email
                Brand_Id__c    = '1',
                LastName   = 'J',
                FirstName = 'John',
                Email =  'xyz@test.com',
                AccountId = a1.id
        );
        contactList.add(c5b);

        Contact c6 = new Contact(  // unique contact for brand 2 for email
                Brand_Id__c    = '2',
                LastName   = 'J',
                FirstName = 'jack',
                Email =  'q@test.com',
                AccountId = a3.id
        );
        contactList.add(c6);

        Contact c7 = new Contact(      //unique contact  for brand + phone,    match to os8
                Brand_Id__c    = '2',
                LastName   = 'J',
                FirstName = 'Joy',
                Phone =  '123-123-1224',
                AccountId = a3.id
        );
        contactList.add(c7);


        Contact c7a = new Contact(
                Brand_Id__c    = '2',
                LastName   = 'J',
                FirstName = 'anne',
                Phone =  '123-123-1234',
                AccountId = a3.id
        );
        contactList.add(c7a);
        Contact c7b = new Contact(
                Brand_Id__c    = '2',
                LastName   = 'J',
                FirstName = 'anne',
                Phone =  '123-123-1234',
                AccountId = a3.id
        );
        contactList.add(c7b);

        Contact c8 = new Contact(
                Brand_Id__c    = '2',
                LastName   = 'J',
                FirstName = 'kate',
                MobilePhone =  '898-909-8989',
                AccountId = a3.id
        );
        contactList.add(c8);

        Contact c8a = new Contact(
                Brand_Id__c    = '2',
                LastName   = 'J',
                FirstName = 'kate2',
                MobilePhone =  '898-909-8989',
                AccountId = a3.id
        );
        contactList.add(c8a);

        Contact c8b = new Contact(
                Brand_Id__c    = '2',
                LastName   = 'J',
                FirstName = 'kate2',
                MobilePhone =  '898-909-8989',
                AccountId = a3.id
        );
        contactList.add(c8b);

        Contact c9 = new Contact(
                Brand_Id__c    = '2',
                LastName   = 'J',
                FirstName = 'kathy',
                OtherPhone =  '999-909-8989',
                AccountId = a3.id
        );
        contactList.add(c9);

        Contact c9a = new Contact(
                Brand_Id__c    = '2',
                LastName   = 'J',
                FirstName = 'kathy2',
                OtherPhone =  '999-909-8989',
                AccountId = a3.id
        );
        contactList.add(c9a);

        Contact c9b = new Contact(
                Brand_Id__c    = '2',
                LastName   = 'J',
                FirstName = 'kathy2',
                OtherPhone =  '999-909-8989',
                AccountId = a3.id
        );
        contactList.add(c9b);

        Contact c10 = new Contact(
                Brand_Id__c    = '11',
                LastName   = 'J',
                FirstName = 'kathy',
                Email = 'q@test.com',
                OtherPhone =  '898-909-8989',
                AccountId = a3.id
        );
        contactList.add(c10);

        insert contactList;

        Boolean isSandbox = [select isSandbox from Organization limit 1].isSandbox;
        if (isSandbox) {
            List <Contact> sbConList = [select id, Email from Contact where Email!=null];
            for (Contact c: sbConList){
                c.Email = c.Email.replace('@','=')+'@example.com';
            }
            update sbConList;

        }
        System.debug('***'+ contactList.size());
    }

    Private static TestMethod void BeforeInsertTest(){
        Test.startTest();
        List <OlgaStagingTable__c> osList = new List<OlgaStagingTable__c>();

        OlgaStagingTable__c os1 =new OlgaStagingTable__c(   // no email, no phone customer, create new contact

                ZdPVHUserId__c ='zdPVH1',
                // no email or phone intentionally
                Source_System__c='Zendesk PVH',
                BrandId__c='1',
                Customer_Name__c = 'Rob J',
                created_at__c = UtilityClass.convertISO8601('2018-11-28T17:12:45.000Z'),
                updated_at__c = UtilityClass.convertISO8601('2018-11-28T17:12:45.000Z')
        );
        
        osList.add(os1);

        OlgaStagingTable__c os2 =new OlgaStagingTable__c(   //unique match by brand, email, update matching contact c5

                ZdPVHUserId__c ='zdPVH2',
                email__c='xyz@test.com',
                Phone__c = '1111111111',
                Source_System__c='Zendesk PVH',
                BrandId__c='1',
             //   Customer_Name__c = 'Robert J',
                created_at__c = UtilityClass.convertISO8601('2018-11-28T17:12:45.000Z'),
                updated_at__c = UtilityClass.convertISO8601('2018-11-28T17:12:45.000Z')
        );

        osList.add(os2);

        OlgaStagingTable__c os3 =new OlgaStagingTable__c(   //unique match by brand, email, firstname, update matching contact c5a

                ZdPVHUserId__c ='zdPVH3',
                email__c='robert@test.com',
                Other_phone__c = '2222222222',
                Source_System__c='Zendesk PVH',
                possible_fraud__c = true,
                BrandId__c='1',
                Customer_Name__c = 'John Jane',
                created_at__c = UtilityClass.convertISO8601('2018-11-28T17:12:45.000Z'),
                updated_at__c = UtilityClass.convertISO8601('2018-11-28T17:12:45.000Z')
        );

        osList.add(os3);

        OlgaStagingTable__c os4 =new OlgaStagingTable__c(   //multiple matches by brand, email, firstname, bucket-2

                ZdPVHUserId__c ='zdPVH4',
                email__c='rob@test.com',
                Source_System__c='Zendesk PVH',
                BrandId__c='1',
                Customer_Name__c = 'Rob',
                created_at__c = UtilityClass.convertISO8601('2018-11-28T17:12:45.000Z'),
                updated_at__c = UtilityClass.convertISO8601('2018-11-28T17:12:45.000Z')
        );

        osList.add(os4);

        OlgaStagingTable__c os5 =new OlgaStagingTable__c(   //no match by brand and email, creates new contact

                ZdPVHUserId__c ='zdPVH5',
                email__c='samp@test.com',
                Source_System__c='Zendesk PVH',
                BrandId__c='2',
                possible_fraud__c = true,
                Customer_Name__c = 'sam k c jackson',
                created_at__c = UtilityClass.convertISO8601('2018-11-28T17:12:45.000Z'),
                updated_at__c = UtilityClass.convertISO8601('2018-11-28T17:12:45.000Z')
        );

       osList.add(os5);

        OlgaStagingTable__c os6 =new OlgaStagingTable__c(   //match by brand and email, no match by first name, bucket-1

                ZdPVHUserId__c ='zdPVH6',
                email__c='rob@test.com',
                Source_System__c='Zendesk PVH',
                BrandId__c='1',
                Customer_Name__c = 'Patrik c',
                created_at__c = UtilityClass.convertISO8601('2018-11-28T17:12:45.000Z'),
                updated_at__c = UtilityClass.convertISO8601('2018-11-28T17:12:45.000Z')
        );

        osList.add(os6);

        OlgaStagingTable__c os7 =new OlgaStagingTable__c(

                ZdTnCUserId__c ='zdTnC7',
                email__c='q@test.com',
                Source_System__c='Zendesk T&C',
                BrandId__c='11',
                Customer_Name__c = 'Nan',
                possible_fraud__c = true,
                created_at__c = UtilityClass.convertISO8601('2018-11-28T17:12:45.000Z'),
                updated_at__c = UtilityClass.convertISO8601('2018-11-28T17:12:45.000Z')
        );

        osList.add(os7);

        OlgaStagingTable__c os8 =new OlgaStagingTable__c(          //unique match on phone with C7

                ZdTnCUserId__c ='zdPVH8',
                Source_System__c='Zendesk PVH',
                BrandId__c='2',
                Customer_Name__c = 'Joy',
                Phone__c = '123-123-1224',
                Other_phone__c = '789',
                possible_fraud__c = false,
                created_at__c = UtilityClass.convertISO8601('2018-11-28T17:12:45.000Z'),
                updated_at__c = UtilityClass.convertISO8601('2018-11-28T17:12:45.000Z')
        );

        osList.add(os8);

        OlgaStagingTable__c os9 =new OlgaStagingTable__c(

                ZdTnCUserId__c ='zdPVH9',
                Source_System__c='Zendesk PVH',
                BrandId__c='2',
                Customer_Name__c = 'Kate',
                Other_phone__c = '898-909-8989',
                possible_fraud__c = false,
                created_at__c = UtilityClass.convertISO8601('2018-11-28T17:12:45.000Z'),
                updated_at__c = UtilityClass.convertISO8601('2018-11-28T17:12:45.000Z')
        );

        osList.add(os9);

        OlgaStagingTable__c os10 =new OlgaStagingTable__c(

                ZdTnCUserId__c ='zdPVH10',
                Source_System__c='Zendesk PVH',
                BrandId__c='2',
                Customer_Name__c = 'Kate',
                Other_phone__c = '999-909-8989',
                possible_fraud__c = false,
                created_at__c = UtilityClass.convertISO8601('2018-11-28T17:12:45.000Z'),
                updated_at__c = UtilityClass.convertISO8601('2018-11-28T17:12:45.000Z')
        );

        osList.add(os10);


        OlgaStagingTable__c os11 =new OlgaStagingTable__c(  // no match on phone

                ZdTnCUserId__c ='zdPVH11',
                Source_System__c='Zendesk PVH',
                BrandId__c='2',
                Customer_Name__c = 'Cory',
                Other_phone__c = '999-909-0000',
                possible_fraud__c = false,
                created_at__c = UtilityClass.convertISO8601('2018-11-28T17:12:45.000Z'),
                updated_at__c = UtilityClass.convertISO8601('2018-11-28T17:12:45.000Z')
        );

        osList.add(os11);

        insert osList;
        Integer callouts = Limits.getCallouts();

        Test.stopTest();
        system.assertEquals(0, callouts);






    }
}