/**
 * Created by apoorvrajput on 10/9/20.
 */

@IsTest
private class NF_SetStringTest {
    @IsTest
    static void test1() {
        Test.startTest();
        NF_SetString.Input input= new NF_SetString.Input();
        input.inputString = 'Yes';
        List<NF_SetString.Input> inputs = new List<NF_SetString.Input>();
        inputs.add(input);
        Test.stopTest();
        System.assertEquals(NF_SetString.setString(inputs).get(0).outputString,'YES');
    }
    @IsTest
    static void test2() {
        Test.startTest();
        NF_SetString.Input input= new NF_SetString.Input();
        input.inputString = 'Yeah';
        List<NF_SetString.Input> inputs = new List<NF_SetString.Input>();
        inputs.add(input);
        Test.stopTest();
        System.assertEquals(NF_SetString.setString(inputs).get(0).outputString,'YES');
    }
    @IsTest
    static void test3() {
        Test.startTest();
        NF_SetString.Input input= new NF_SetString.Input();
        input.inputString = 'Nope';
        List<NF_SetString.Input> inputs = new List<NF_SetString.Input>();
        inputs.add(input);
        Test.stopTest();
        System.assertEquals(NF_SetString.setString(inputs).get(0).outputString,'NO');
    }

}