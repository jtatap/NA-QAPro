/**
 * Created by apoorvrajput on 10/10/20.
 */

@IsTest
private class NF_UpdateSessionFollowupTest {

    @IsTest
    static void updateSessionTest1() {
        Test.startTest();
        NF_UpdateSessionFollowup.Input input= new NF_UpdateSessionFollowup.Input();
        input.chatKey = NF_UtilTest.createLiveChatTranscript();
        input.isPositiveFeedback = 'true';
        NF_Util.insertSession(input.chatKey,'','Calvin Klein');
        NF_Util.associateCaseWithSession(input.chatKey,'');
        List<NF_UpdateSessionFollowup.Input> inputs = new List<NF_UpdateSessionFollowup.Input>();
        inputs.add(input);
        NF_UpdateSessionFollowup.updateSession(inputs);
        ebotdata__Bot_Session__c[] botSessions = [SELECT Id, Brand__c,Visitor_Feedback_Result__c
        FROM ebotdata__Bot_Session__c
        WHERE ebotdata__Live_Agent_Session_Id__c = :input.chatKey
        LIMIT 1];
        Test.stopTest();
        //return botSessions.size() > 0 ? botSessions[0] : null;
        System.assertEquals(botSessions[0].Visitor_Feedback_Result__c,'Yes');

    }

}