/**
 * Created by apoorvrajput on 10/9/20.
 */

@IsTest
private class NF_SetBoolTest {
    @IsTest
    static void test1() {
        System.assert(NF_SetBool.setBool(new List<String>{'true'})[0]);
    }
    @IsTest
    static void test2() {
        System.assert(!NF_SetBool.setBool(new List<String>{'false'})[0]);
    }
}