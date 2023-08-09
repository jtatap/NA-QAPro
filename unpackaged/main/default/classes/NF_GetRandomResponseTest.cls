/**
 * Created by apoorvrajput on 10/10/20.
 */

@IsTest
private class NF_GetRandomResponseTest {
    @IsTest
    static void test1GetRamdomResponse() {
        Test.startTest();
        List<NF_GetRandomResponse.Input> inputs = new List<NF_GetRandomResponse.Input>();
        NF_GetRandomResponse.Input input = new NF_GetRandomResponse.Input();
        List<NF_GetRandomResponse.Output> outputs;

        input.intentName = 'social_hello';
        inputs.add(input);
        outputs = NF_GetRandomResponse.getResponse(inputs);
        Test.stopTest();
        System.assertNotEquals(outputs.get(0).response,null);

    }
}