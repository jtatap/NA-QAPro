/**
 * Created by samuel on 7/2/21.
 */
@IsTest
public with sharing class NF_GetListOfOrdersTest {
    static NF_GetListOfOrders.Input testInput = new NF_GetListOfOrders.Input();
    static List<NF_GetListOfOrders.Input> testInputs = new List<NF_GetListOfOrders.Input>{testInput};

    @TestSetup
    public static void setupTests() {
        LiveChatVisitor testVisitor = new LiveChatVisitor();
        insert testVisitor;
        LiveChatTranscript testTranscript = new LiveChatTranscript();
        testTranscript.LiveChatVisitor = testVisitor;
        testTranscript.ChatKey = 'chatkey123';

        ebotdata__Bot_Session__c testSession = new ebotdata__Bot_Session__c();
        testSession.ebotdata__Live_Agent_Session_Id__c = 'chatkey123';
        insert testSession;
    }

    @IsTest
    public static void testSuccessfulCall_Shipped() {
        testInput.email = 'test@test.com';
        testInput.brandName = 'Tommy Hilfiger';
        testInput.orderNumber = '11111111';
        testInput.chatKey = 'chatkey123';

        List<NF_GetListOfOrders.Output> testOut = NF_GetListOfOrders.getListOfOrders(testInputs);
        System.assert(testOut[0].numberOfOrders == 1, 'Total number of orders returned should be 1');
    }
    @IsTest
    public static void testSuccessfulCall_NotShipped() {
        testInput.email = 'test@test.com';
        testInput.brandName = 'Calvin Klein';
        testInput.orderNumber = '22222222';
        testInput.chatKey = 'chatkey123';

        List<NF_GetListOfOrders.Output> testOut = NF_GetListOfOrders.getListOfOrders(testInputs);
        System.assert(testOut[0].numberOfOrders == 0, 'Total number of orders returned should be 1');
    }
    @IsTest
    public static void testSuccessfulCall_Cancelled() {
        testInput.email = 'test@test.com';
        testInput.brandName = 'Speedo';
        testInput.orderNumber = '33333333';
        testInput.chatKey = 'chatkey123';

        List<NF_GetListOfOrders.Output> testOut = NF_GetListOfOrders.getListOfOrders(testInputs);
        System.assert(testOut[0].numberOfOrders == 1, 'Total number of orders returned should be 2');
    }
    @IsTest
    public static void testFailedCall() {
        testInput.email = 'test@test.com';
        testInput.brandName = 'Partner Brands';
        testInput.orderNumber = '44444444';
        testInput.chatKey = 'chatkey123';

        List<NF_GetListOfOrders.Output> testOut = NF_GetListOfOrders.getListOfOrders(testInputs);
        System.assert(testOut[0].numberOfOrders == 0, 'Total number of orders returned should be 0');
    }
}