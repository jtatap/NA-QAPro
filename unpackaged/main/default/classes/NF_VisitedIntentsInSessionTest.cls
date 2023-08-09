/**
 * Created by apoorvrajput on 10/10/20.
 */

@IsTest
private class NF_VisitedIntentsInSessionTest {
    @IsTest
    static void test1() {
        Test.startTest();
        NF_VisitedIntentsInSession.Input input= new NF_VisitedIntentsInSession.Input();
        input.chatKey = 'key';
        List<NF_VisitedIntentsInSession.Input> inputs = new List<NF_VisitedIntentsInSession.Input>();
        inputs.add(input);
        Test.stopTest();
        System.assertEquals(NF_VisitedIntentsInSession.visitedIntents(inputs).get(0).visitedOrderStatusOrReturns,true);

    }
}