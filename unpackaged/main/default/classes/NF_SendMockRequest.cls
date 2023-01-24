/**
 * Created by adamundus on 6/12/20.
 */

public with sharing class NF_SendMockRequest {

    public class Input {
        @InvocableVariable(required=true)
        public String chatKey;
    }

    public class Output {
        @InvocableVariable(required=true)
        public String response;
    }


    @InvocableMethod(label='Send Mock API Request')
    public static List<Output> getApiResponse(List<Input> inputs){
        String response = '';
        String chatKey = inputs[0].chatKey;

        List<Output> outputs = new List<Output>();
        Output out = new Output();
        out.response = response;
        outputs.add(out);
        return outputs;
    }

}