public with sharing class NF_UpdateSessionFollowup {
    public class Input{
        @InvocableVariable(required=true)
        public String chatKey;

        @InvocableVariable(required=true)
        public String isPositiveFeedback;
    }

    @InvocableMethod(label='Neuraflash - Update Bot Session After Followup')
    public static void updateSession(List<Input> input){
        String chatKey = input[0].chatKey;
        Boolean isPositiveFeedback = Boolean.valueOf(input[0].isPositiveFeedback);

        try {
            String lbi = NF_Util.getLastBusinessIntent(chatKey);

            ebotdata__Bot_Session__c session = NF_Util.getBotSession(chatKey);
            session.Visitor_Feedback_Intent__c = lbi;
            session.Visitor_Feedback_Result__c = (isPositiveFeedback) ? SYSTEM.LABEL.Yes : SYSTEM.LABEL.No;

            update session;
        }catch(Exception e){
            Logger.logException(e);
        }
    }
}