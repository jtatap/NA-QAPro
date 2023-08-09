/**
 * Created by apoorvrajput on 10/9/20.
 */


@IsTest(isParallel=false)
private class NF_AgentAvailabilityCheckTest {
    @isTest static void test1(){
        List<LiveChatDeployment> deploymentList = [SELECT Id FROM LiveChatDeployment];
        List<LiveChatButton> chatButtonIdList =[SELECT Id FROM LiveChatButton];

        Test.startTest();
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new MockLiveAgentResponse());

        NF_AgentAvailabilityCheck.Input input = new NF_AgentAvailabilityCheck.Input();
        input.brand = 'Calvin Klein';
        List<NF_AgentAvailabilityCheck.Input> inputList = new List<NF_AgentAvailabilityCheck.Input>{ input };

        System.assert(NF_AgentAvailabilityCheck.checkAgentAvailability(inputList) != null);
        Test.stopTest();
    }

    @IsTest
    static void testButtonAvailability() {

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockLiveAgentResponse());
        Boolean isAvailable = NF_AgentAvailabilityCheck.getButtonAvailability(NF_Util.buttonMapping.get('Calvin Klein'), NF_Util.deploymentMapping.get('Calvin Klein'));
        Test.stopTest();

        System.assertNotEquals(null, isAvailable);
    }

    public class MockLiveAgentResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            //res.setBody('{"results":{"type":"array","description":"List of ids and their availability","items":{"name":"result","type":"object","properties":{"isAvailable":{"type":"boolean","description":"Whether or not the entity is available for chat","required":true,"version":29.0}}},"required":true}}');
            res.setBody('{"messages":[{"type":"Availability", "message":{"results":[{"id":"57305000000CaS5"}]}}]}');
            res.setStatusCode(200);
            return res;
        }
    }
}