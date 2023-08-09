/**
 * Created by apoorvrajput on 10/9/20.
 */

@IsTest
private class NF_SetBoolTest {
    @IsTest
    static void test1() {
        Test.startTest();
        System.assert(NF_SetBool.setBool(new List<String>{'true'})[0]);
        Test.stopTest();
    }
    @IsTest
    static void test2() {
        Test.startTest();
        System.assert(!NF_SetBool.setBool(new List<String>{'false'})[0]);
        Test.stopTest();
    }
}