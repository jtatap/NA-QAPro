@isTest
public class ContactUtilityTest { 

    static testMethod void testCreateErrorLogRecords() {
        Account genAcc = new Account();
        genAcc.Name = 'generic Account' + Math.random();
        insert genAcc;

        Contact genCon = new Contact();
        genCon.email = 'foo@example.com';
        genCon.lastName = 'generic contact ' + Math.random();
        genCon.AccountId = genAcc.id;
        genCon.Brand_Id__c = '9';
        insert genCon;

        Contact errCon = new Contact();
        errCon.email = 'fooerror@example.com';
        errCon.Brand_Id__c = '1';
        List<Contact> errContacts = new List<Contact>();
        errContacts.add(errCon);
        String sourceSystem = 'SFSC';
        String FileName = 'testname';
        Database.SaveResult[] results = Database.insert(errContacts, false);
        ContactUtility.createErrorLogRecords(results, sourceSystem, FileName);

        GenericRecords__c genRec = new GenericRecords__c(
                Name = Constants.privacyContactGenericRecordSettingName,
                recordId__c = genCon.Id
        );
        insert genRec;

        GenericRecords__c genRecAcct = new GenericRecords__c(
                Name = Constants.AccountGenericRecordSettingName,
                recordId__c = genAcc.Id
        );
        insert genRecAcct;
        DateTime dt = utilityClass.strYYYMMDDtoDateTime('2021-10-01T00:00:00Z');
        DateTime dt3 = utilityClass.strYYYMMDDtoDateTime('');
        Date dt1 = utilityClass.strYYYMMDDtoDate('');
        Date dt2 = utilityClass.strYYYMMDDtoDate('2021-10-01T00:00:00Z');
        String dummyAccount = utilityClass.generateRandomString(4);
        account acc = new account(name = dummyAccount);
        insert acc;

        contact con = new contact (lastname = 'Dummycontact', email = 'test@gmail.com', Brand_Id__c = '1');
        insert con;

        case parentcase = new case(Type = 'Support', Status = 'New', SuppliedEmail = 'test@gmail.com', ContactId = con.id, AccountId = acc.id, Brand__c = '1');
        insert parentcase;

        case childcase = new case(Type = 'Support', Status = 'New', SuppliedEmail = 'test@gmail.com', parentid = parentcase.id, Is_Milestone_Violated__c = true,
                ContactId = con.id, AccountId = acc.id, Brand__c = '1');
        insert childcase;
        Test.setCreatedDate(childcase.Id, DateTime.newInstance(2019, 06, 06));

    }
}