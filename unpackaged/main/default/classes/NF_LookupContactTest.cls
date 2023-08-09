/**
 * Created by apoorvrajput on 10/9/20.
 */

@IsTest
private class NF_LookupContactTest {



    @TestSetup
    static void testSetup() {
    }

    @IsTest
    static void test1NoRecordFound() {
        Test.startTest();
        List<NF_LookupContact.Input> inputs = new List<NF_LookupContact.Input>();
        NF_LookupContact.Input input = new NF_LookupContact.Input();
        List<NF_LookupContact.Output> outputs;

        input.chatKey = NF_UtilTest.createLiveChatTranscript();
        input.email = 'test.user1@gmail.com';
        input.brand = 'Calvin Klein';

        inputs.add(input);

        outputs = NF_LookupContact.getContact(inputs);
        Test.stopTest();
        System.assertEquals(outputs.get(0).contactId,null);

    }

    @IsTest
    static void test2RecordFound() {
        Test.startTest();
        List<NF_LookupContact.Input> inputs = new List<NF_LookupContact.Input>();
        NF_LookupContact.Input input = new NF_LookupContact.Input();
        List<NF_LookupContact.Output> outputs;
        Contact contact = NF_Util.createContact('cc', 'testcase','testcaseuser@test.cc', NF_Util.getBrandId('Calvin Klein'));

        input.chatKey = NF_UtilTest.createLiveChatTranscript();
        input.email = 'testcaseuser@test.cc';
        input.brand = 'Calvin Klein';

        inputs.add(input);

        outputs = NF_LookupContact.getContact(inputs);
        Test.stopTest();
        System.assertEquals(outputs.get(0).contactId,contact.Id);

    }

    @IsTest
    static void test3NAName() {
        Test.startTest();
        List<NF_LookupContact.Input> inputs = new List<NF_LookupContact.Input>();
        NF_LookupContact.Input input = new NF_LookupContact.Input();
        List<NF_LookupContact.Output> outputs;
        Contact contact = new Contact(
                LastName = 'test',
                Email = 'testcaseuser@test.cc',

                Brand_Id__c = NF_Util.getBrandId('Calvin Klein')
                //RecordTypeId = personAccRecordTypeId
        );
        insert contact;
        input.chatKey = NF_UtilTest.createLiveChatTranscript();
        input.email = 'testcaseuser@test.cc';
        input.brand = 'Calvin Klein';

        inputs.add(input);

        outputs = NF_LookupContact.getContact(inputs);
        Test.stopTest();
        System.assertEquals(outputs.get(0).contactId,contact.Id);

    }
    
    @IsTest
    static void test4NAName() {
        Test.startTest();
        List<NF_LookupContact.Input> inputs = new List<NF_LookupContact.Input>();
        NF_LookupContact.Input input = new NF_LookupContact.Input();
        List<NF_LookupContact.Output> outputs;
        Contact contact = new Contact(
                LastName = 'test',
                Email = 'testcaseuser@test.cc',

                Brand_Id__c = NF_Util.getBrandId('Calvin Klein')
                //RecordTypeId = personAccRecordTypeId
        );
        insert contact;
        input.chatKey = '';
        input.email = 'testcaseuser@test.cc';
        input.brand = 'Calvin Klein';

        inputs.add(input);

        outputs = NF_LookupContact.getContact(inputs);
        Test.stopTest();
	}



}