/**
 *
 *
*/

public with sharing class NF_AgentAvailabilityCheck {
    public class Input{
        @InvocableVariable(required=true)
        public String brand;
    }
    public class Output{
        @InvocableVariable(required=true)
        public boolean bAgentAvailability;
    }

    @InvocableMethod(label='Neuraflash - Check Agent Availability')
    public static List<Output> checkAgentAvailability(List<Input> input){
        Output output = new Output();
        output.bAgentAvailability = false;

        try{
            Log.push('input is:'+input.toString());
            Log.push('Button mapping is:'+NF_Util.buttonMapping.get(input[0].brand));
            Log.push('Deployment mapping is:'+NF_Util.deploymentMapping.get(input[0].brand));

            output.bAgentAvailability = getButtonAvailability(NF_Util.buttonMapping.get(input[0].brand), NF_Util.deploymentMapping.get(input[0].brand));

        }catch(Exception e){
            Logger.logException(e);
        }
        Log.push('returning availability as'+output);
        Logger.logDebug();
        return new List<Output>{output};
    }

    @AuraEnabled
    //public static boolean getButtonAvailability(String botDeploymentId, String botTransferbuttonId){
    public static boolean getButtonAvailability(String botTransferbutton, String botDeployment){
        Boolean isAvailable = false;
        List<LiveChatButton> chatButtonIdList = [SELECT Id
        FROM LiveChatButton
        WHERE MasterLabel = :botTransferbutton
        LIMIT 1];

        List<LiveChatDeployment> deploymentList = [SELECT Id
        FROM LiveChatDeployment
        WHERE MasterLabel = :botDeployment
        LIMIT 1];
        String botTransferbuttonId = chatButtonIdList[0].Id;
        botTransferbuttonId = botTransferbuttonId.substring(0,15);
        String botDeploymentId = deploymentList[0].Id;
        botDeploymentId = botDeploymentId.substring(0,15);
        String botOrgId = UserInfo.getOrganizationId().substring(0, 15);
        botOrgId = botOrgId.substring(0,15);


        String sPath = 'callout:Live_Chat_Agent_Availability/chat/rest/Visitor/Availability?Availability.ids='+botTransferbuttonId+'&deployment_id='+botDeploymentId+'&org_id='+botOrgId;
        Log.push('>> NF_AgentAvailabilityCheck.getButtonAvailability: sPath='+sPath);

        HttpRequest request = new HttpRequest();
        request.setEndpoint(sPath);
        request.setMethod('GET');
        request.setHeader('X-LIVEAGENT-API-VERSION', '47');

        Http http = new Http();
        HttpResponse response = http.send(request);
        Log.push('NF_AgentAvailabilityCheck.getButtonAvailability: response='+response.getBody());

        // If the request is successful, parse the JSON response.
        if (response.getStatusCode() == 200) {
            JSONParser parser = JSON.createParser(response.getBody());
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'isAvailable')) {
                    // Get the value.
                    parser.nextToken();
                    isAvailable = parser.getBooleanValue() != null ? parser.getBooleanValue() : false;
                }
            }
        }
        Log.push('Returning Agent Availability as:' +isAvailable);
        Logger.logDebug();
        return isAvailable;

    }


}