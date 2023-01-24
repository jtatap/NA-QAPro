/*******************************************************************************************
* @Description: Utility methods for SFMC & SMS related methods for Waterfall and QueueMOAPI
* @Author     : 
* @Date       : 3 March & 20 April
* @JIRA       : NASSC-1481/NASSC-1485/NASSC-1486
*
********************************************************************************************/ 

global class SFMCUtility{
    public static integer countSFMCPostCall = 0; 
    
    //method: POST to SFMC
    @future (callout=true)
    public static void postToSFMCQueueMOAPI(String QueueMODataListAsString){
    System.debug('^^^inside postToSFMCQueueMOAPI()');
  List<QueueMOData> QueueMODataList = (List<QueueMOData>)Json.deserialize(QueueMODataListAsString,List<QueueMOData>.class);

        for (QueueMOData QMOData : QueueMODataList) {

            String KeywordType = QMOData.KeywordType;
            String BrandId = QMOData.BrandId;
            String SmsNumber = QMOData.SmsNumber;
            Id ContactId = QMOData.ContactId;
            String Email = QMOData.Email;
            String Country = QMOData.Country;
            String SMSLocale = QMOData.SMSLocale;

            String requestBody = '';
            String keyword = '';
            Integer countCalls = 0;
            String cacheControl = 'no-cache';
            String requestEndPoint = 'callout:SFMC_QueueMOAPI/';

            List<LoyaltySettings__mdt> listLoyalty = [
                    SELECT shortCode__c, chargeItKeyword__c, preferenceCenterKeyword__c, stopKeyword__c
                    FROM LoyaltySettings__mdt
                    WHERE BrandId__c = :BrandId AND shortCode__c!=null
            ];
      System.debug('***Get Loyalty Record = '+listLoyalty);
            if(listLoyalty!=null && !listLoyalty.isEmpty() && BrandId =='1')
            {
                if (KeywordType == 'chargeIt') keyword = listLoyalty[0].chargeItKeyword__c;
                if (KeywordType == 'preferenceCenter') keyword = listLoyalty[0].preferenceCenterKeyword__c;
                if (KeywordType == 'stop') keyword = listLoyalty[0].stopKeyword__c;
                
                
                if (KeywordType == 'chargeIt' || KeywordType == 'preferenceCenter') {
                    requestBody = '{"subscribers":[{ "mobilenumber": "' + SmsNumber + '", "subscriberkey": "' + ContactId + '" }],"shortCode" : "' + listLoyalty[0].shortCode__c + '","messageText" : "' + keyword + ' ' + ContactId + ' ' + Email + ' ' + BrandId + ' ' + SMSLocale + '"}';
                } else if (KeywordType == 'stop') {
                    requestBody = '{"subscribers":[{ "mobilenumber": "' + SmsNumber + '", "subscriberkey": "' + ContactId + '" }],"shortCode" : "' + listLoyalty[0].shortCode__c + '","messageText" : "' + keyword + ' ' + ContactId + '"}';
                }
                
                //getting access token
                String validAccessToken = getSFMCAccessToken();
                System.debug('*****get valid access token first time= ' + validAccessToken);
                String authorization = 'Bearer ' + validAccessToken;
                
                //SFMC Callout 1
                HttpResponse getResponse = doCalloutSFMC(requestEndPoint, 'POST', requestBody, authorization, cacheControl);
                
                if (getResponse.getStatusCode() == 200) System.debug('^^^Successfully POST SFMC Attempt 1');
                
                else if (getResponse.getStatusCode() == 401 || getResponse.getStatusCode() == 403) {
                    System.debug('^^^Error 401 or 403 Posting SFMC');
                    if (countSFMCPostCall == 1) {
                        System.debug('^^^getting valid access token second time');
                        validAccessToken = getSFMCAccessToken();
                        authorization = 'Bearer ' + validAccessToken;
                        //SFMC Callout 2
                        getResponse = doCalloutSFMC(requestEndPoint, 'POST', requestBody, authorization, cacheControl);
                        if (getResponse.getStatusCode() == 200) System.debug('*****Successfully POST SFMC Attempt 2');
                        
                        else if ((getResponse.getStatusCode() == 401 || getResponse.getStatusCode() == 403) && countSFMCPostCall == 2) {                            
                            createErrorLogs(requestEndPoint,requestBody,String.valueOf(getResponse.getStatusCode()),getResponse.getBody(),'SFSC to SFMC');
                        }
                    } 
                    else {                        
                        createErrorLogs(requestEndPoint,requestBody,String.valueOf(getResponse.getStatusCode()),getResponse.getBody(),'SFSC to SFMC');
                    }
                    
                }
                else {                    
                    createErrorLogs(requestEndPoint,requestBody,String.valueOf(getResponse.getStatusCode()),getResponse.getBody(),'SFSC to SFMC');
                }
            }
            if(listLoyalty!=null && !listLoyalty.isEmpty() && BrandId =='2')
            {
               /* if (KeywordType == 'chargeIt') keyword = listLoyalty[0].chargeItKeyword__c;
                if (KeywordType == 'preferenceCenter') keyword = listLoyalty[0].preferenceCenterKeyword__c;*/
                if (KeywordType == 'stop') keyword = listLoyalty[0].stopKeyword__c;
                
                
                /*if (KeywordType == 'chargeIt' || KeywordType == 'preferenceCenter') {
                    requestBody = '{"subscribers":[{ "mobilenumber": "' + SmsNumber + '", "subscriberkey": "' + ContactId + '" }],"shortCode" : "' + listLoyalty[0].shortCode__c + '","messageText" : "' + keyword + ' ' + ContactId + ' ' + Email + ' ' + BrandId + ' ' + SMSLocale + '"}';
                } else */
                if (KeywordType == 'stop') {
                    requestBody = '{"subscribers":[{ "mobilenumber": "' + SmsNumber + '", "subscriberkey": "' + ContactId + '" }],"shortCode" : "' + listLoyalty[0].shortCode__c + '","messageText" : "' + keyword + ' ' + ContactId + '"}';
                }
                
                //getting access token
                String validAccessToken = CKgetSFMCAccessToken();
                System.debug('*****get valid access token first time= ' + validAccessToken);
                String authorization = 'Bearer ' + validAccessToken;
                
                //SFMC Callout 1
                HttpResponse getResponse = doCalloutSFMC(requestEndPoint, 'POST', requestBody, authorization, cacheControl);
                
                if (getResponse.getStatusCode() == 200) System.debug('^^^Successfully POST SFMC Attempt 1');
                
                else if (getResponse.getStatusCode() == 401 || getResponse.getStatusCode() == 403) {
                    System.debug('^^^Error 401 or 403 Posting SFMC');
                    if (countSFMCPostCall == 1) {
                        System.debug('^^^getting valid access token second time');
                        validAccessToken = CKgetSFMCAccessToken();
                        authorization = 'Bearer ' + validAccessToken;
                        //SFMC Callout 2
                        getResponse = doCalloutSFMC(requestEndPoint, 'POST', requestBody, authorization, cacheControl);
                        if (getResponse.getStatusCode() == 200) System.debug('*****Successfully POST SFMC Attempt 2');
                        
                        else if ((getResponse.getStatusCode() == 401 || getResponse.getStatusCode() == 403) && countSFMCPostCall == 2) {                            
                            createErrorLogs(requestEndPoint,requestBody,String.valueOf(getResponse.getStatusCode()),getResponse.getBody(),'SFSC to SFMC');
                        }
                    } 
                    else {                        
                        createErrorLogs(requestEndPoint,requestBody,String.valueOf(getResponse.getStatusCode()),getResponse.getBody(),'SFSC to SFMC');
                    }
                    
                }
                else {                    
                    createErrorLogs(requestEndPoint,requestBody,String.valueOf(getResponse.getStatusCode()),getResponse.getBody(),'SFSC to SFMC');
                }
            }
        }
    }
    
    
    //method: POST to Waterfall
    @future (callout=true)
    public static void postToWaterfallSMSAPI(String QueueMODataListAsString){
        System.debug('^^^inside postToWaterfallSMSAPI()');
        List<QueueMOData> QueueMODataList = (List<QueueMOData>)Json.deserialize(QueueMODataListAsString,List<QueueMOData>.class);
        
        for (QueueMOData QMOData : QueueMODataList) {
            
            String KeywordType = QMOData.KeywordType;
            String BrandId = QMOData.BrandId;
            String SmsNumber = QMOData.SmsNumber;
            Id ContactId = QMOData.ContactId;
            String Email = QMOData.Email;
            String Country = QMOData.Country;
            String SMSLocale = QMOData.SMSLocale;
            String requestBody = '';
            String requestEndPoint = '';
            String cacheControl = 'no-cache';
            List<WaterfallAPISettings__mdt> listWaterfallSettings = [SELECT BrandId__c, Country__c, AuthKey__c,
                                                                     ChargeItOptinFlowId__c, PrefCenterOptinFlowId__c, 
                                                                     WfShortCode__c
                                                                     FROM WaterfallAPISettings__mdt
                                                                     WHERE BrandId__c != null AND 
                                                                     BrandId__c =: BrandId AND
                                                                     Country__c != null AND
                                                                     Country__c =:Country];
            
            
            HttpResponse getResponse;
            //setting authorization
            if(listWaterfallSettings.size() > 0){
                String authorization = listWaterfallSettings[0].AuthKey__c;
                if (KeywordType == 'chargeIt') {
                    requestBody = '{"msisdns": ["'+SmsNumber+'"],"mobileFlow":"'+listWaterfallSettings[0].ChargeItOptinFlowId__c+'"}';
                    requestEndPoint = 'callout:WaterfallAPIOptin/';
                    getResponse = doCalloutSFMC(requestEndPoint, 'POST', requestBody, authorization, cacheControl);
                }
                else if (KeywordType == 'preferenceCenter') {
                    requestBody = '{"msisdns": ["'+SmsNumber+'"],"mobileFlow":"'+listWaterfallSettings[0].PrefCenterOptinFlowId__c+'"}';
                    requestEndPoint = 'callout:WaterfallAPIOptin/';
                    getResponse = doCalloutSFMC(requestEndPoint, 'POST', requestBody, authorization, cacheControl);
                }
                else if(KeywordType == 'stop'){
                    requestEndPoint = 'callout:WaterfallAPIOptout/'+SmsNumber+'?shortCode='+listWaterfallSettings[0].WfShortCode__c;
                    getResponse = doCalloutSFMC(requestEndPoint, 'POST', requestBody, authorization, cacheControl);
                }
                
                if (String.valueOf(getResponse.getStatusCode()).startsWith('2')) {
                    System.debug('^^^POST Call to Waterfall Success with StatusCode = '+getResponse.getStatusCode());
                }
                else {
                    System.debug('^^^POST Call to Waterfall Error');                 
                    createErrorLogs(requestEndPoint,requestBody,String.valueOf(getResponse.getStatusCode()),getResponse.getBody(),'SFSC to Waterfall');
                }
            }
        }
    }
    
    
    private static String getSFMCAccessToken(){
         String accessToken = null;        
        List<SFMC_AccessTokens__mdt> tokenRecord = [SELECT Access_Token__c 
                                                    FROM SFMC_AccessTokens__mdt 
                                                    WHERE DeveloperName='Token_1' AND expires_at__c > :System.now() LIMIT 1];
        if (tokenRecord.size()>0){
            accessToken = tokenRecord[0].access_token__c;
        } 
        return accessToken;
    }
     private static String CKgetSFMCAccessToken(){
         String accessToken = null;        
        List<SFMC_AccessTokens__mdt> tokenRecord = [SELECT Access_Token__c 
                                                    FROM SFMC_AccessTokens__mdt 
                                                    WHERE DeveloperName!='Token_1' AND expires_at__c > :System.now() LIMIT 1];
        if (tokenRecord.size()>0){
            accessToken = tokenRecord[0].access_token__c;
        } 
        return accessToken;
    }
    
    

    //method: POST callout to SFMC 
    private static HttpResponse doCalloutSFMC(String requestEP, String calloutMethod,String inputBody, String auth, String cacheControl){
        System.debug('^^^inside doCalloutSFMC()');
        System.debug('^^^Request Body = '+inputBody);
        System.debug('^^^auth = '+auth);
        countSFMCPostCall = countSFMCPostCall + 1;
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', auth);
        req.setHeader('Cache-Control', cacheControl);
        req.setEndpoint(requestEP);
        req.setMethod(calloutMethod);
        req.setBody(inputBody);
        Http http = new Http();
        try{
            res = http.send(req);
            System.debug('*****Status Code = '+res.getStatusCode());
            System.debug('*****Response Body = '+res.getBody());
        }catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
        }
        return res;
        
       
    }
   
    //method: create logs in ErrorLog__c object
    public static void createErrorLogs(String reqEndPoint, String reqBody, String resStatusCode, String resBody, String sourceSystem){
        ErrorLog__c logObject = new ErrorLog__c();
        logObject.SourceSystem__c = sourceSystem;
        logObject.FileName__c = 'Auth API Call from SFSC';
        logObject.Message__c = 'Response status code: '+ resStatusCode;
        logObject.StackTrace__c = 'POST '+ reqEndPoint + ' ; request payload: '+ reqBody + ' ; response body: ' + resBody;
        
        try{
            insert logObject;
        }
        catch(Exception e){
            System.debug('Exception has occurred while inserting in ErrorLog Object: ' + e.getMessage());
        }
    }
    
    //Set contact SMS preferences
    Static void setContactSMSOptin(Contact cont,Boolean smsOptInFlag){
        if (smsOptInFlag){
            cont.SMSOptinStatus__c = 'Y'; //true;
            cont.SMSOptInDate__c = System.now();
            cont.SMSOptOutDate__c = Null;
        } else {
            cont.SMSOptinStatus__c = 'N'; //false;
            cont.SMSOptInDate__c = Null;
            cont.SMSOptOutDate__c = System.now();
        }
    }


    public class QueueMOData {

        @InvocableVariable
        public String KeywordType;
        @InvocableVariable
        public String BrandId;
        @InvocableVariable
        public String SmsNumber;
        @InvocableVariable
        public Id ContactId;
        @InvocableVariable
        public String Email;
        @InvocableVariable
        public String Country;
        @InvocableVariable
        public String SMSLocale;
    }


    @InvocableMethod(label='invocable QueueMOAPI' description='pass thru method to call QueueMOAPI')
    public static void invocableTargetSMSAPI(List<QueueMOData> QueueMODataList) {
    String jsonString = json.serialize(QueueMODataList);
        List<LoyaltySettings__mdt> listLoyaltyData = [SELECT BrandId__c, MCSMSEnabled__c, WaterfallSMSEnabled__c,
                                                     shortCode__c, preferenceCenterKeyword__c, chargeItKeyword__c, 
                                                     stopKeyword__c 
                                                     FROM LoyaltySettings__mdt 
                                                     WHERE BrandId__c =: QueueMODataList[0].BrandId];
        if(listLoyaltyData[0].MCSMSEnabled__c){
             System.debug('^^^calling postToSFMCQueueMOAPI method');
            if(!Test.isRunningTest())  postToSFMCQueueMOAPI(jsonString);
        }
        if(listLoyaltyData[0].WaterfallSMSEnabled__c){
            System.debug('^^^calling postToWaterfallSMSAPI method');
            if(!Test.isRunningTest())  postToWaterfallSMSAPI(jsonString);                
            
        }

    }
    
    //method: 
    public static Contact searchSMSBrandContact(String brandId,String SMSNumber){

        List <Contact> conList = [SELECT id, Brand_Id__c, Email, SMSNumber__c, AccountId, StoreOfCapture__c, CountryOfCapture__c,
                LoyaltyID__c, LoyaltyFlag__c, SMSOptinStatus__c,SMSLocale__c,EmailOptInStatus__c, Loyalty_Optin_Date__c, SMSOptInDate__c, Source_System__c, Latest_Source__c
        FROM CONTACT
               WHERE Brand_Id__c=:brandId AND SMSNumber__c=:SMSNumber limit 1];

        if (conList.size()>0) return conList[0];
        else return null;
    }
    
    //method:
    public static Contact searchEmailBrandContact(String brandId,String EmailAddress){

        List <Contact> conList = [SELECT id, Brand_Id__c, Email, SMSNumber__c, AccountId, StoreOfCapture__c, CountryOfCapture__c,
                LoyaltyID__c, LoyaltyFlag__c, SMSOptinStatus__c,SMSLocale__c,EmailOptInStatus__c, Loyalty_Optin_Date__c, SMSOptInDate__c, Source_System__c, Latest_Source__c
               FROM CONTACT 
               WHERE Brand_Id__c=:brandId AND Email=:EmailAddress limit 1];

        if (conList.size()>0) return conList[0];
        else return null;
    }

    public static Id getSiblingAccountId(String brandId,String EmailAddress){

        List <Contact> conList = [SELECT id, AccountId
        FROM CONTACT
        WHERE Email=:EmailAddress AND Brand_Id__c!=:brandId AND AccountId!=null AND Account.Name != 'Dummy Parent Account' limit 1];

        if (conList.size()>0) return conList[0].AccountId;
        else return null;
    }

    //Email validation function
    public static Boolean validateEmail(string emailString){
        System.debug(Pattern.matches('([a-zA-Z0-9_\\-\\.]+)@(((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3}))','emailString'));
        return Pattern.matches('([a-zA-Z0-9_\\-\\.]+)@(((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3}))',emailString);
    }
   
    
}