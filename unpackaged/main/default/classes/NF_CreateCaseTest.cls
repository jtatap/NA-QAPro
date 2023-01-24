/**
 * Created by apoorvrajput on 10/10/20.
 */

@IsTest
private class NF_CreateCaseTest {

    @IsTest
    static void test1GetRamdomResponse() {
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
}