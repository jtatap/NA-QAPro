/**
 * Created by samuel on 1/4/22.
 */
@IsTest
public with sharing class NF_UpdateTranscriptBodyWithContact_Test {
    static String chatkey = '';

    @TestSetup
    static void setup() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');
        Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
        String uniqueName = orgId + dateString + randomInt;

        User tuser = NF_Util.getPlatformIntegrationUser();
        User[] platUser = [SELECT Id, Name FROM User WHERE Name = 'Platform Integration User' LIMIT 1];

        System.runAs(tuser) {
            LiveChatTranscript t1 = new LiveChatTranscript();
            LiveChatVisitor lcv = new LiveChatVisitor();

            Contact contact1 = NF_Util.createContact('testfirstname', 'testlastname','testcaseuser@test.cc', NF_Util.getBrandId('Calvin Klein'));

            insert lcv;
            t1.LiveChatVisitorId = lcv.Id;
            t1.ChatKey = 'testchatkey1';
            t1.OwnerId = platUser[0].Id;
            t1.ContactId = contact1.Id;
            t1.Status = 'Completed';
            t1.Body = '<p align="center">Chat Started: Thursday, July 29, 2021, 18:15:37 (+0000)</p>( 4s ) Digital Assistant: This is a test, using metadata. ^{&quot;t&quot;:&quot;link&quot;,&quot;v&quot;:&quot;this is text&quot;,&quot;url&quot;:&quot;www.tommy.com&quot;}^<br>( 5s ) Digital Assistant: Hi, I&#39;m the Tommy Hilfiger Digital Assistant.<br>( 7s ) Digital Assistant: How can I help you today? You can ask me a question, or select from one of the topics below.<br>( 8s ) Digital Assistant: {ChatWindowButton:Order Status,Shipping Policies,Product Questions,Returns,Something Else}<br>( 2m 33s ) Visitor: Order Status<br>( 2m 36s ) Digital Assistant: I&#39;ll be happy to get you more information on your order.<br>( 2m 37s ) Digital Assistant: Please type your order number below, or if you don&#39;t know it, select &quot;Don&#39;t know it&quot;.<br>( 2m 38s ) Digital Assistant: {ChatWindowButton:Don&#39;t know it}<br>';
            insert t1;
            //system.debug(t1);
            chatkey = t1.ChatKey;
        }
    }

    @IsTest
    static void testTranscriptUpdate() {


        Map<Id, LiveChatTranscript> input = new Map<Id, LiveChatTranscript>();
        LiveChatTranscript lct = [SELECT Id, OwnerId, Body, CaseId, CreatedById FROM LiveChatTranscript where ChatKey = 'testchatkey1' LIMIT 1];
        system.debug(lct.CreatedById);
        //lct.OwnerId = '00505000000OywKAAS';
//       lct.CreatedById = '0051U000003g7wLQAQ'; created by AAK
        input.put(lct.Id, lct);

        Test.startTest();
        System.assertEquals(true, NF_UpdateTranscriptBodyWithContactName.updateBodyWithName(input));
        LiveChatTranscript lct_confirm = [SELECT Id, OwnerId, Body, CaseId, CreatedById FROM LiveChatTranscript where ChatKey = 'testchatkey1' LIMIT 1];
        System.assert(lct_confirm.Body == '<p align="center">Chat Started: Thursday, July 29, 2021, 18:15:37 (+0000)</p>( 4s ) Digital Assistant: This is a test, using metadata. ^{&quot;t&quot;:&quot;link&quot;,&quot;v&quot;:&quot;this is text&quot;,&quot;url&quot;:&quot;www.tommy.com&quot;}^<br>( 5s ) Digital Assistant: Hi, I&#39;m the Tommy Hilfiger Digital Assistant.<br>( 7s ) Digital Assistant: How can I help you today? You can ask me a question, or select from one of the topics below.<br>( 8s ) Digital Assistant: {ChatWindowButton:Order Status,Shipping Policies,Product Questions,Returns,Something Else}<br>( 2m 33s ) testfirstname: Order Status<br>( 2m 36s ) Digital Assistant: I&#39;ll be happy to get you more information on your order.<br>( 2m 37s ) Digital Assistant: Please type your order number below, or if you don&#39;t know it, select &quot;Don&#39;t know it&quot;.<br>( 2m 38s ) Digital Assistant: {ChatWindowButton:Don&#39;t know it}<br>');
        Test.stopTest();
    }
}