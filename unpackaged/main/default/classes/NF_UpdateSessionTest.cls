/**
 * Created by apoorvrajput on 10/10/20.
 */

@IsTest
private class NF_UpdateSessionTest {
    @IsTest
    static void test1UpdateSession() {
        Test.startTest();
        List<NF_UpdateSession.Input> inputs = new List<NF_UpdateSession.Input>();
        NF_UpdateSession.Input input = new NF_UpdateSession.Input();

        input.chatKey = NF_UtilTest.createLiveChatTranscript();
        input.brandName = 'Calvin Klein';
        inputs.add(input);
        NF_Util.insertSession(input.chatKey,'','Calvin Klein');
        NF_Util.associateCaseWithSession(input.chatKey,'');
        NF_UpdateSession.updateSession(inputs);
        ebotdata__Bot_Session__c session = NF_Util.getBotSession(input.chatKey);
        Test.stopTest();
        System.assertEquals(session.Brand__c,'Calvin Klein');
    }
}