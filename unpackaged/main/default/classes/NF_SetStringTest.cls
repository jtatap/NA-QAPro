/**
 * Created by apoorvrajput on 10/9/20.
 */

@IsTest
private class NF_SetStringTest {
    @IsTest
    static void test1() {
        NF_SetString.Input input= new NF_SetString.Input();
        input.inputString = 'Yes';
        List<NF_SetString.Input> inputs = new List<NF_SetString.Input>();
        inputs.add(input);
        System.assertEquals(NF_SetString.setString(inputs).get(0).outputString,'Yes');
    }
    @IsTest
    static void test2() {
        NF_SetString.Input input= new NF_SetString.Input();
        input.inputString = 'Yeah';
        List<NF_SetString.Input> inputs = new List<NF_SetString.Input>();
        inputs.add(input);
        System.assertEquals(NF_SetString.setString(inputs).get(0).outputString,'Yes');
    }
    @IsTest
    static void test3() {
        NF_SetString.Input input= new NF_SetString.Input();
        input.inputString = 'Nope';
        List<NF_SetString.Input> inputs = new List<NF_SetString.Input>();
        inputs.add(input);
        System.assertEquals(NF_SetString.setString(inputs).get(0).outputString,'No');
    }

}