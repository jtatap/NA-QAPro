/**
 * Created by apoorvrajput on 10/23/20.
 */

@IsTest
private class NF_GetShippingDelaysTest {
    @IsTest
    static void test1() {

        List<NF_GetShippingDelays.Input> inputs = new List<NF_GetShippingDelays.Input>();
        NF_GetShippingDelays.Input input = new NF_GetShippingDelays.Input();
        List<NF_GetShippingDelays.Output> outputs;

        input.chatKey = NF_UtilTest.createLiveChatTranscript();
        inputs.add(input);
        outputs = NF_GetShippingDelays.getShippingDelays(inputs);

        Einstein_Bot_Dialog_Configuration__mdt configuration = [select Shipping_Delays__c from Einstein_Bot_Dialog_Configuration__mdt limit 1];
        
        System.assertEquals(outputs.get(0).shippingDelaysEnabled,configuration.Shipping_Delays__c);
    }
}