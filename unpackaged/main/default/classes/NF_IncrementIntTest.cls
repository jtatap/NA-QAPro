/**
 * Created by apoorvrajput on 10/9/20.
 */


@IsTest
private class NF_IncrementIntTest {
    @IsTest
    static void test1() {
        System.assert(NF_IncrementInt.increment(new List<Integer>{1})[0] == 2);
    }
}