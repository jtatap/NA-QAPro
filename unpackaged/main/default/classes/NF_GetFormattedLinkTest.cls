/**
 * Created by apoorvrajput on 10/10/20.
 */

@IsTest
private class NF_GetFormattedLinkTest {
    @IsTest
    static void testFormattedLink1() {
        Test.startTest();
        List<NF_GetFormattedLink.Input> inputs = new List<NF_GetFormattedLink.Input>();
        NF_GetFormattedLink.Input input = new NF_GetFormattedLink.Input();
        List<NF_GetFormattedLink.Output> outputs;
        String email = 'testuser1@gmail.com';
        String orderId = '12334';
        String baseURL = 'https://justatest.com';
        input.chatKey = NF_UtilTest.createLiveChatTranscript();
        input.email = email;
        input.orderId = orderId;
        input.baseURL = baseURL;
        inputs.add(input);
        outputs = NF_GetFormattedLink.getBrandName(inputs);
        System.debug('returned:'+outputs.get(0).formattedLink);
        Test.stopTest();
        System.assertEquals(outputs.get(0).formattedLink.contains(email),true);
        System.assertEquals(outputs.get(0).formattedLink.contains(orderId),true);
        System.assertEquals(outputs.get(0).formattedLink.contains(baseURL),true);

    }
}