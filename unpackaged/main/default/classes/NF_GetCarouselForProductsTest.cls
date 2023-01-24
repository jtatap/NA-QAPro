/**
 * Created by apoorvrajput on 10/12/20.
 */

@IsTest
public with sharing class NF_GetCarouselForProductsTest {

    @IsTest
    static void test1DefaultBrand() {
        List<NF_GetCarouselForProducts.Input> inputs = new List<NF_GetCarouselForProducts.Input>();
        NF_GetCarouselForProducts.Input input = new NF_GetCarouselForProducts.Input();

        input.chatKey = NF_UtilTest.createLiveChatTranscript();
        input.brandName = 'Calvin Klein';
        inputs.add(input);
        NF_GetCarouselForProducts.getResponse(inputs);
        //System.assertNotEquals(outputs.get(0).shippingQuestionsURL,null);
        // T

    }
    @IsTest
    static void test2THBrand() {
        List<NF_GetCarouselForProducts.Input> inputs = new List<NF_GetCarouselForProducts.Input>();
        NF_GetCarouselForProducts.Input input = new NF_GetCarouselForProducts.Input();

        input.chatKey = NF_UtilTest.createLiveChatTranscript();
        input.brandName = 'IZOD';
        inputs.add(input);
        NF_GetCarouselForProducts.getResponse(inputs);

    }

}