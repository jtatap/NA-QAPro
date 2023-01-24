/******************************************************************************
* @Description: Scheduler to set access_token for Marketing Cloud
* @Author     : 
* @Date       : 03/13
* @JIRA       : NASSC-1481/NASSC-1556 
*
******************************************************************************/ 
global class Scheduler_SFMCAccessTokens implements Schedulable,Database.AllowsCallouts {
    global void execute(SchedulableContext sc) {
        getSFMCAccessToken();
    }
    
    @future(callout=true) 
    public static void getSFMCAccessToken(){
        List<SFMC_Credentials__mdt> listSFMCcreds = [SELECT client_id__c, client_secret__c, account_id__c 
                                                     FROM SFMC_Credentials__mdt where account_id__c ='100028781' LIMIT 1];
        String reqEndPoint='callout:SFMC_Auth_End_Point/';
        String reqBody = '{"grant_type":"client_credentials","client_id":"'+listSFMCcreds[0].client_id__c+'","client_secret":"'+listSFMCcreds[0].client_secret__c+'","account_id":"'+listSFMCcreds[0].account_id__c+'"}';
        HttpResponse getRes = doCalloutForToken(reqEndPoint,'POST',reqBody);
        if(getRes != null){
            if(getRes.getStatusCode() == 200){
                responseClass responseClassValue = (responseClass)JSON.deserialize(getRes.getBody(), responseClass.class);   
                //insert record into SFMC_Tokens_mdt 
                //CreateMetadataRecords.createSFMC_AccessTokens_mdtRecords(responseClassValue);   
                
                //update MDT with new token every 10 min
                CreateMetadataRecords.updateSFMC_AccessTokens_mdtRecords(responseClassValue);  
                             
            }
            else if(String.valueOf(getRes.getStatusCode()).startsWith('4') ||  String.valueOf(getRes.getStatusCode()).startsWith('5')){
                System.debug('*****ERROR - StatusCode = 4XX OR 5XX');
                //insert record into Error Log                  
                SFMCUtility.createErrorLogs(reqEndPoint,reqBody,String.valueOf(getRes.getStatusCode()),getRes.getBody(),'SFMC_Auth_End_Point');
            }
        }
    }
    //method: Callout for Access Token
    private static HttpResponse doCalloutForToken(String requestEP, String calloutMethod,String inputBody){
        System.debug('*****inside doCalloutForToken()');
        String responseString = Null;
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(requestEP);
        req.setMethod(calloutMethod);
        req.setBody(inputBody);
        Http http = new Http();
        try{
            res = http.send(req);
            responseString = res.getBody();
            System.debug('*****Response Body = '+responseString);
            System.debug('*****Status Code = '+res.getStatusCode());
        }catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
        }
        return res;
    }
    //Wrapper class to collect token response
    public class responseClass{
        public String access_token; 
        public Integer expires_in;  
    }
}