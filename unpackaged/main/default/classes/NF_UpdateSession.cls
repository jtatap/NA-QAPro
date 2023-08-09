/**
 * Created by NeuraFlash LLC on 11/11/19.
 */

public with sharing class NF_UpdateSession {
    public class Input{
        @InvocableVariable(required=true)
        public String chatKey;

        @InvocableVariable(required=false)
        public String brandName;

    }

    @InvocableMethod(label='Neuraflash - Update Bot Session')
    public static void updateSession(List<Input> input){
        String chatKey = input[0].chatKey;
        try{
            ebotdata__Bot_Session__c session;
            session = NF_Util.getBotSession(chatKey);
            if(String.isNotBlank(input[0].brandName) && session != null) {
                session.Brand__c = input[0].brandName;
                update session;
            }

        }catch(Exception e){
            Logger.logException(e);
        }

    }
}