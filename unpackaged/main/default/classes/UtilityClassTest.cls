@isTest
private class UtilityClassTest {

    static testMethod void testConvertISO8601() {
        String iso8601_ts = '2022-01-01T00:00:00.000Z';
        DateTime expectedResult = DateTime.newInstance(2022, 1, 1, 0, 0, 0);
        DateTime actualResult = utilityClass.convertISO8601(iso8601_ts);
    }

    static testMethod void testStrYYYMMDDtoDate() {
        String strDate = '2022-01-01';
        Date expectedResult = Date.newInstance(2022, 1, 1);
        Date actualResult = utilityClass.strYYYMMDDtoDate(strDate);
    }

    static testMethod void testStrYYYMMDDtoDateTime() {
        // Test for ISO8601 format
        String strDateTime = '2022-01-01T00:00:00.000Z';
        DateTime expectedResult = DateTime.newInstance(2022, 1, 1, 0, 0, 0);
        DateTime actualResult = UtilityClass.strYYYMMDDtoDateTime(strDateTime);

        // Test for YYYYMMDD format
        strDateTime = '20221231';
        expectedResult = DateTime.newInstance(2022, 12, 31);
        actualResult = UtilityClass.strYYYMMDDtoDateTime(strDateTime);

        // Test for invalid format
        strDateTime = '20221231T00:00:00.000Z';
        expectedResult = System.now();
        actualResult = UtilityClass.strYYYMMDDtoDateTime(strDateTime);
    }

    static testMethod void testGenerateRandomString() {
        Integer len = 10;
        String actualResult = utilityClass.generateRandomString(len);
    }

    static testMethod void testTriggerEnabled() {
        Profile profileRecord = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
                FirstName='Test',
                LastName='User',
                Alias='testuser',
                Email='testuser@example.com',
                Username='asdjasfhasklfhalkfhafals@test.com',
                TimeZoneSidKey='America/Los_Angeles',
                LocaleSidKey='en_US',
                EmailEncodingKey='UTF-8',
                ProfileId=profileRecord.Id,
                LanguageLocaleKey='en_US'
        );
        insert testUser;
        // Set the test user as the running user
        System.runAs(testUser) {
            // Test that the trigger is enabled
            String className = 'UtilityClassTest';
            Boolean expectedResult = true;
            Boolean actualResult = utilityClass.triggerEnabled(className);
            System.assertEquals(expectedResult, actualResult);
        }
    }


    static testMethod void testGetPicklistValues() {
        // Create a test object record
        Account testAccount = new Account(Name='Test Account');
        insert testAccount;

        // Get the picklist values for the Industry field on the Account object
        String objName = 'Account';
        String fieldName = 'Industry';
        Map<String, String> expectedPicklistValues = new Map<String, String>{
                'Agriculture' => 'Agriculture',
                'Apparel' => 'Apparel',
                'Banking' => 'Banking'
                // ...
        };
        Map<String, String> actualPicklistValues = UtilityClass.getPicklistValues(objName, fieldName);
    }
}