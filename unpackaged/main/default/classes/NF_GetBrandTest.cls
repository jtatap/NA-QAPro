/**
 * Created by apoorvrajput on 10/6/20.
 */

@IsTest
public with sharing class NF_GetBrandTest {
    static String transcriptID, sessionID, chatlogID;
    @IsTest
    static void test1DefaultBrand() {
        Test.startTest();
        List<NF_GetBrand.Input> inputs = new List<NF_GetBrand.Input>();
        NF_GetBrand.Input input = new NF_GetBrand.Input();
        List<NF_GetBrand.Output> outputs;

        input.chatKey = NF_UtilTest.createLiveChatTranscript();
        inputs.add(input);
        outputs = NF_GetBrand.getBrandName(inputs);
        Test.stopTest();
        System.assertNotEquals(outputs.get(0).shippingQuestionsURL,null);
        System.assertNotEquals(outputs.get(0).promotionsURL,null);
        System.assertNotEquals(outputs.get(0).covidURL,null);
        System.assertNotEquals(outputs.get(0).returnQuestionsURL,null);
        System.assertNotEquals(outputs.get(0).returnsURL,null);
        System.assertNotEquals(outputs.get(0).brandName,null);
        System.assertNotEquals(outputs.get(0).brandId,null);
        System.assertNotEquals(outputs.get(0).brandEmail,null);
        System.assertNotEquals(outputs.get(0).brandPhone,null);
        System.assertNotEquals(outputs.get(0).orderStatusURL,null);

    }
}