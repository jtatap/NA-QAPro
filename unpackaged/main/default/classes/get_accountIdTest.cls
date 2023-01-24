/**
 * Created by venkatpenukonda on 2019-06-17.
 */

@IsTest
private class get_accountIdTest {
    @IsTest
    static void testBehavior() {

        List <Account> accountList = new List<Account>();
        Account a1Account = new Account( Name = 'test account1', Customer_Id__c = 'abc123');
        Account a2Account = new Account( Name = 'test account2', Customer_Id__c = 'abc124');
        Account a3Account = new Account( Name = 'test account2', Customer_Id__c = 'mnp789');

        accountList.add(a1Account);
        accountList.add(a2Account);
        accountList.add(a3Account);

        insert accountList;

        List <Contact> contactList = new List<Contact>();
        Contact c1a2 = new Contact(
                FirstName = 'f1',
                LastName = 'l1',
                Customer_Id__c = 'abc124',
            	Brand_Id__c = '1',
            	Source_System__c ='SFSC'
        );

        Contact c2a1 = new Contact(
                FirstName = 'f2',
                LastName = 'l2',
            	Brand_Id__c = '1',
                Customer_Id__c = 'abc123',
            	Source_System__c ='SFSC'
        );

        Contact c3 = new Contact(
                FirstName = 'f3',
                LastName = 'l3',
            	Brand_Id__c = '1',
                Customer_Id__c = 'xyz1234',
            	Source_System__c ='SFSC'
        );
        contactList.add(c1a2);
        contactList.add(c2a1);
        contactList.add(c3);

        Test.startTest();
            insert contactList;

            Id c1a2AccountId = [select accountId from Contact where id = :c1a2.id].AccountId;
            Id c2a1AccountId = [select accountId from Contact where id = :c2a1.id].AccountId;
            Id c3AccountId = [select accountId from Contact where id = :c3.id].AccountId;

          //  System.assertEquals(c1a2AccountId, a2Account.Id);
            //System.assertEquals(c2a1AccountId, a1Account.Id);
           // System.assertEquals(null, c3AccountId);
        Test.stopTest();



    }
}