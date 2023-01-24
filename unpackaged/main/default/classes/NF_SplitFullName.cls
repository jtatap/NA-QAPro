/**
 * Created by apoorvrajput on 9/14/20.
 */

public with sharing class NF_SplitFullName {
    public class Input{
        @InvocableVariable(required=true)
        public String chatKey;

        @InvocableVariable(required=true)
        public String fullName;

    }
    public class Output{
        @InvocableVariable(required=false)
        public String firstName;

        @InvocableVariable(required=false)
        public String lastName;

    }

    @InvocableMethod(label='Neuraflash - Split Full Name')
    public static List<Output> splitFullName(List<Input> input){
        List<Output> result = new List<Output>();
        String chatKey = input[0].chatKey;
        Output out = new Output();

        System.debug('>>NF_Util.getLiveChatTranscript chatKey is ' + chatKey);

        if(String.isEmpty(chatKey)){
            System.debug('>>NF_Util.getLiveChatTranscript Cannot find LiveChatTranscript, chatKey is empty');
            return null;
        }

        List<LiveChatTranscript> listTranscripts = new List<LiveChatTranscript>();

        // TODO: add null checks?

        List<String> nameStrings= NF_Util.splitFullNameIntoFirstAndLast(input[0].fullName);
        out.firstName = nameStrings.get(0);
        out.lastName = nameStrings.get(1);

        result.add(out);
        System.debug(result.toString());
        return result;
    }

}