/**
 * Created by apoorvrajput on 10/23/20.
 */

public with sharing class NF_GetShippingDelays {
    public class Input{
        @InvocableVariable(required=true)
        public String chatKey;

    }
    public class Output{
        @InvocableVariable(required=false)
        public Boolean shippingDelaysEnabled = false;

    }

    @InvocableMethod(label='Neuraflash - Shipping delays enabled?')
    public static List<Output> getShippingDelays(List<Input> input) {
        List<Output> result = new List<Output>();
        String chatKey = input[0].chatKey;
        Output out = new Output();
        Einstein_Bot_Dialog_Configuration__mdt configuration = [select Shipping_Delays__c from Einstein_Bot_Dialog_Configuration__mdt limit 1];
        out.shippingDelaysEnabled = configuration.Shipping_Delays__c;
        result.add(out);
        return result;
    }
}