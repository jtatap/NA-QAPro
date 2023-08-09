/**
 * Created by apoorvrajput on 9/14/20.
 */

public with sharing class NF_VisitedIntentsInSession {
    public class Input{
        @InvocableVariable(required=true)
        public String chatKey;

        @InvocableVariable(required=false)
        public String intentName;
    }
    public class Output{
        @InvocableVariable(required=false)
        public Boolean visitedOrderStatusOrReturns;
    }

    @InvocableMethod(label='Neuraflash - Set Vistied order status or Returns intent in this session.')
    public static List<Output> visitedIntents(List<Input> input){
        List<Output> result = new List<Output>();
        String chatKey = input[0].chatKey;
        Output out = new Output();
        out.visitedOrderStatusOrReturns = true;
        Log.push('>>NF_Util.getLiveChatTranscript chatKey is ' + chatKey);

        result.add(out);
        Log.push('result.toString()'+result.toString());
        Logger.logDebug();
        return result;
    }

}