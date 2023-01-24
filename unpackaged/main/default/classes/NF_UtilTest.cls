/**
 *
*/

@IsTest
public with sharing class NF_UtilTest {
    public static String createLiveChatTranscript(){
        LiveChatTranscript t1 = new LiveChatTranscript();
        LiveChatVisitor lcv = new LiveChatVisitor();
        try{
            insert lcv;
        }catch(Exception e){

        }
        t1.LiveChatVisitorId = lcv.Id;
        t1.ChatKey = 'somechatkey';
        insert t1;
        return t1.ChatKey;
    }

    public static String createLiveChatTranscript(String brand){
        LiveChatTranscript t1 = new LiveChatTranscript();
        LiveChatVisitor lcv = new LiveChatVisitor();
        try{
            insert lcv;
        }catch(Exception e){

        }
        t1.LiveChatVisitorId = lcv.Id;
        t1.ChatKey = 'somechatkey';
        t1.Brand__c = brand;
        insert t1;
        return t1.ChatKey;
    }

    public static Id createLiveChatTranscript2(){
        LiveChatTranscript t1 = new LiveChatTranscript();
        LiveChatVisitor lcv = new LiveChatVisitor();
        try{
            insert lcv;
        }catch(Exception e){

        }
        t1.LiveChatVisitorId = lcv.Id;
        t1.ChatKey = 'somechatkey';
        insert t1;
        return t1.Id;
    }

    @IsTest
    public static void test1() {
        String chatKey = NF_UtilTest.createLiveChatTranscript();
        NF_Util.insertSession(chatKey,'','Calvin Klein');
        String intent = NF_Util.getLastBusinessIntent(chatKey);
        System.assertNotEquals(NF_Util.getBotSession(chatKey),null);
    }

    @IsTest
    public static void test2() {
        RecordType rt = NF_Util.getRecordType();
        //System.assertNotEquals(rt,null);
    }

    @IsTest
    public static void test3() {
        Brand_Setting__mdt mdt = NF_Util.getBrandName('https://calvinklein.com');
        System.assertNotEquals(mdt.Brand_Id__c,null);
        System.assertNotEquals(NF_Util.getDomainName('https://calvinklein.com'),null);

    }

    @IsTest
    public static void test4() {
        List<String> names = NF_Util.splitFullNameIntoFirstAndLast('test user');
        System.assertNotEquals(names.size(),0);

    }
    @IsTest
    public static void test5() {
        Account test = NF_Util.createCustomer('test', 'user', 'test@gmail.com');
        System.assertNotEquals(test,null);
        Account account = NF_Util.getContact('test@gmail.com');
        System.assertNotEquals(account,null);


        Contact cc = NF_Util.createContact('test','user', 'test@gmail.com', '1');
        System.assertNotEquals(cc,null);

        Contact c = NF_Util.getContact('test@gmail.com', '', 'Tommy Hilfiger');
        System.assertNotEquals(c,null);
    }
    
    
    
    public static ebotdata__Bot_Session__c insertBotSession(String chatKey){
        ebotdata__Bot_Session__c session = new ebotdata__Bot_Session__c();
        session.ebotdata__Live_Agent_Session_Id__c = chatKey;
        insert session;
        return session;
    }

    public static ebotdata__Bot_Chat_Log__c insertChatLog(ebotdata__Bot_Session__c session){
        ebotdata__Bot_Chat_Log__c log = new ebotdata__Bot_Chat_Log__c();
        log.ebotdata__Bot_Session__c = session.Id;
        log.ebotdata__Intent_Name__c = 'bus_testIntent_end';
        log.ebotdata__Current_Utterance__c = 'firstUserInput';
        log.ebotdata__Live_Agent_Session_Id__c = session.ebotdata__Live_Agent_Session_Id__c;
        insert log;
        return log;
    }

    @IsTest
    static void test1GetRamdomResponse() {
        
        contact con = new contact (lastname='Dummycontact' ,email='test@gmail.com',Brand_Id__c = '1',LoyaltyID__c='123456');
        insert con;
        
        getContact.getContactDetails(con.Id);
        GenericRecords__c gr = new GenericRecords__c();
        gr.recordId__c = con.Id;
        gr.Name ='privacyContact';
        insert gr;
        Case cs = NF_Util.getCaseRelatedToContact(con.Id);
        
        List<NF_CreateCase.Input> inputs = new List<NF_CreateCase.Input>();
        NF_CreateCase.Input input = new NF_CreateCase.Input();
        List<NF_CreateCase.Output> outputs;

        input.chatKey = NF_UtilTest.createLiveChatTranscript();
        input.email='testemail1@email.com';
        input.brand='Calvin Klein';
        input.firstName = 'test';
        input.lastName = 'test';
        input.agentAvailable=false;
        input.reason = 'just a test';
        inputs.add(input);
        outputs = NF_CreateCase.createCase(inputs);
        System.assertNotEquals(outputs.get(0).caseNumber,null);

    }
    @IsTest
    static void updateSessionTest1() {
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
        //return botSessions.size() > 0 ? botSessions[0] : null;
        System.assertEquals(botSessions[0].Visitor_Feedback_Result__c,'Yes');

    }


    public static LiveChatTranscript insertLiveChatTranscript(String chatKey, String pageUrl, String token){
        LiveChatVisitor v = new LiveChatVisitor();
        insert v;
        LiveChatTranscript transcript = new LiveChatTranscript();
        transcript.LiveChatVisitorId= v.Id;

        if(String.isNotEmpty(chatKey)){
            transcript.ChatKey = chatKey;
        }

        if(String.isNotEmpty(pageUrl)){
            transcript.ebotdata__Invocation_URL__c = pageUrl;
        }


        insert transcript;

        return transcript;
    }
}