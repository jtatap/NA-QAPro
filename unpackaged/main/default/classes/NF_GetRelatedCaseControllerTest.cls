/**
 * Created by apoorvrajput on 10/14/20.
 */

@IsTest
private class NF_GetRelatedCaseControllerTest {
    @IsTest
    static void test1() {
        String key  = NF_UtilTest.createLiveChatTranscript2();
        System.debug('key is' +key);
        NF_GetRelatedCaseController.getRelatedCase(key);
        System.assertNotEquals(NF_GetRelatedCaseController.getRelatedCase(key),null);
    }
}