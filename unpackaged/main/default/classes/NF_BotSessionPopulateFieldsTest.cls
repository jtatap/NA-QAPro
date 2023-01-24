/**
 * Created by apoorvrajput on 10/23/20.
 */

@IsTest
private class NF_BotSessionPopulateFieldsTest {
    @IsTest
    static void testBehavior() {
        String chatKey = NF_UtilTest.createLiveChatTranscript('Calvin Klein');

        List<LiveChatTranscript> listTranscripts = new List<LiveChatTranscript>();

        try {
            listTranscripts = [SELECT Id, URL__c, Brand__c
            FROM LiveChatTranscript
            WHERE ChatKey = :chatKey];
        }
        catch(Exception e){
            System.debug('Exception encountered: ' + e);
        }

        LiveChatTranscript transcript = listTranscripts.size() > 0 ? listTranscripts[0] : null;

        ebotdata__Bot_Session__c session = new ebotdata__Bot_Session__c();
        session.ebotdata__Live_Agent_Session_Id__c = chatKey;
        session.ebotdata__Live_Chat_Transcript__c = transcript.Id;
        insert session;


        ebotdata__Bot_Session__c sessionNew = NF_Util.getBotSession(chatKey);

        System.assertEquals(transcript.Brand__c,sessionNew.Brand__c);
    }
}