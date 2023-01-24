/**
 * Created by apoorvrajput on 10/9/20.
 */

@IsTest
private class NF_SplitFullNameTest {
    @IsTest
    static void testNullResponse() {
        NF_SplitFullName.Input input= new NF_SplitFullName.Input();
        input.fullName = 'John Doe';
        List<NF_SplitFullName.Input> inputs = new List<NF_SplitFullName.Input>();
        inputs.add(input);
        System.assertEquals(NF_SplitFullName.splitFullName(inputs),null);

    }

    @IsTest
    static void test1() {
        NF_SplitFullName.Input input= new NF_SplitFullName.Input();
        input.fullName = 'John Doe';
        input.chatKey = 'key';
        List<NF_SplitFullName.Input> inputs = new List<NF_SplitFullName.Input>();
        inputs.add(input);
        System.assertEquals(NF_SplitFullName.splitFullName(inputs).get(0).firstName,'John');
        System.assertEquals(NF_SplitFullName.splitFullName(inputs).get(0).lastName,'Doe');

    }
}