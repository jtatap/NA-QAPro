/**
 * Created by apoorvrajput on 10/10/20.
 */

@IsTest(isParallel=false)
private class NF_ReassignCaseOwnerTest {
    static String chatkey = '';

    @TestSetup
    static void setup() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;

        User tuser = NF_Util.getPlatformIntegrationUser();
        User[] platUser = [SELECT Id, Name FROM User WHERE Name = 'Platform Integration User' LIMIT 1];

        System.runAs(tuser) {
            LiveChatTranscript t1 = new LiveChatTranscript();
            LiveChatVisitor lcv = new LiveChatVisitor();
    
            insert lcv;
            t1.LiveChatVisitorId = lcv.Id;
            t1.ChatKey = 'somechatkey';
            t1.OwnerId = platUser[0].Id;
            t1.Body = 'Visitor:';
            insert t1;
            chatkey =t1.ChatKey;

            Contact cont = new Contact();
            cont.FirstName = 'testfirst';
            cont.LastName = 'testuser';
            cont.Email = 'testuser@email.com';
            insert cont;
            
            
            Case c = new Case();
            c.Status = 'Open';
            c.OwnerId =tuser.Id;
            c.ContactId = cont.Id;
            insert c;
            t1.CaseId = c.Id;
            t1.ContactId = cont.Id;
            update t1;

            

            LiveChatTranscript t2 = new LiveChatTranscript();
            LiveChatVisitor lcv2 = new LiveChatVisitor();

            insert lcv2;
            t2.LiveChatVisitorId = lcv2.Id;
            t2.ChatKey = 'somechatkey2';
            t2.OwnerId = platUser[0].Id;
            t2.Status = 'Completed';
            t2.Body = 'Visitor:';
            insert t2;
            chatkey =t2.ChatKey;

            Contact cont2 = new Contact();
            cont2.FirstName = 'testfirst';
            cont2.LastName = 'testuser';
            cont2.Email = 'testuser2@email.com';
            insert cont2;
            
            Case c2 = new Case();
            c2.Status = 'Open';
            c2.OwnerId = platUser[0].Id;
            insert c2;
            t2.CaseId = c2.Id;
            t2.ContactId = cont2.Id;
            update t2;


        }
    }
    
    @IsTest
    static void testBehavior2() {
        //setup();
        Map<Id, LiveChatTranscript> input = new Map<Id, LiveChatTranscript>();
        LiveChatTranscript lct = [SELECT Id, OwnerId, CaseId, CreatedById FROM LiveChatTranscript where ChatKey = 'somechatkey' LIMIT 1];
        //lct.OwnerId = '00505000000OywKAAS';
//       lct.CreatedById = '0051U000003g7wLQAQ'; created by AAK
        input.put(lct.Id, lct);

        Test.startTest();
        System.assertEquals(true, NF_ReassignCaseOwner.reassignCaseOwner(input));
        Test.stopTest();

    }

}