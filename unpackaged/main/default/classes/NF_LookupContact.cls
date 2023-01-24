/**
 * Created by apoorvrajput on 9/14/20.
 */

public with sharing class NF_LookupContact {
    /**
     * Created by NeuraFlash LLC on 10/21/19.
     */

        public class Input{
            @InvocableVariable(required=true)
            public String chatKey;

            @InvocableVariable(required=true)
            public String email;

            @InvocableVariable(required=true)
            public String brand;

        }
        public class Output{
            @InvocableVariable(required=false)
            public String firstName;

            @InvocableVariable(required=false)
            public String lastName;

            @InvocableVariable(required=false)
            public Account personAccount;

            @InvocableVariable(required=false)
            public Boolean casesInLast72;

            @InvocableVariable(required=false)
            public Case latestCase;

            @InvocableVariable(required=false)
            public String accountId;

            @InvocableVariable(required=false)
            public String contactId;

        }

        @InvocableMethod(label='Neuraflash - Lookup Contact')
        public static List<Output> getContact(List<Input> input) {
            List<Output> result = new List<Output>();
            String chatKey = input[0].chatKey;
            Output out = new Output();

            System.debug('>>NF_Util.getLiveChatTranscript chatKey is: ' + chatKey);
            System.debug('>> input is: ' + input[0]);
            if (String.isEmpty(chatKey)) {
                System.debug('>>NF_Util.getLiveChatTranscript Cannot find LiveChatTranscript, chatKey is empty');
                return null;
            }

            List<LiveChatTranscript> listTranscripts = new List<LiveChatTranscript>();

            LiveChatTranscript liveChatTranscript = NF_Util.getLiveChatTranscript(chatKey);

            // 1. Search if account exists with the email.
            if (input[0].email == null)
                return null;

            Contact contact = NF_Util.getContact(input[0].email, '', input[0].brand);
            if(contact != null) {
                out.contactId = contact.Id;
                if(String.isBlank(contact.FirstName))
                    out.firstName = 'NA';
                else
                    out.firstName = contact.FirstName;
                if(String.isBlank(contact.LastName))
                    out.lastName = 'NA';
                else
                    out.lastName = contact.LastName;
            }

            // 2. get the case related to the email.
            if(contact!=null)
                out.latestCase = NF_Util.getCaseRelatedToContact(out.contactId);
            System.debug('found a case: '+out.latestCase);
            if (out.latestCase != null) {
                out.casesInLast72 = true;
                liveChatTranscript.CaseId = out.latestCase.Id;
                update liveChatTranscript;
                System.debug('Case updated '+out.latestCase);
            }
            result.add(out);
            System.debug(result.toString());
            return result;
        }
}