/******************************************************************************
 * @Description: Scheduler to C360API Token
 * @Author      : Trupti Bhirud
 * @Date          : 01:01.2020
 * @JIRA          : NASSC-1190,NASSC-1188
 *
 ******************************************************************************/
global class Scheduler_A1C360APITokens implements Schedulable{
    global void execute(SchedulableContext sc){
        setC360APITokens();
    }

    public static List<A1_C360API_creds__mdt> TEST_credListMetadata;
    private static List<A1_C360API_creds__mdt> retrieveCredListMetadata() {
        if (!Test.isRunningTest() || TEST_credListMetadata == NULL) {
            return [
                SELECT BrandId__c, TenantId__c, Username__c, Password__c, Base64__c, MasterLabel, DeveloperName
                FROM A1_C360API_creds__mdt
            ];
        } else {
            return TEST_credListMetadata;
        }
    }

    public static List<A1_C360API_Tokens__mdt> TEST_accessTokenMetadata;
    private static List<A1_C360API_Tokens__mdt> retrieveTokenMetadata(Map<String, A1_C360API_creds__mdt> brandIdAndCredsMetadataMap) {
        if (!Test.isRunningTest() || TEST_accessTokenMetadata == NULL) {
            return [
                SELECT BrandId__c, access_token__c, DeveloperName
                FROM A1_C360API_Tokens__mdt
                WHERE BrandId__c = :brandIdAndCredsMetadataMap.keySet() AND expires_at__c > :System.now()
            ];
        } else {
            return TEST_accessTokenMetadata;
        }
    }

    @future(callout = true)
    public static void setC360APITokens(){
        List<String> getBrandToken = new List<String>();
        Map<String, List<String>> brandTokenMap = new Map<String, List<String>>();
        List<String> brandTokenNeeded = new List<String>(); //Brands for which token need to be generated
        Map<String, A1_C360API_creds__mdt> brandIdAndCredsMetadataMap = new Map<String, A1_C360API_creds__mdt>();
        Map<A1_C360API_creds__mdt, responseClass> responseValAndMetdataMap = new Map<A1_C360API_creds__mdt, responseClass>();

        //get A1_C360API_creds__mdt for all brand records
        List<A1_C360API_creds__mdt> C360CredsList = retrieveCredListMetadata();

        if (!C360CredsList.isEmpty()){
            for (A1_C360API_creds__mdt cred : C360CredsList){
                brandIdAndCredsMetadataMap.put(cred.BrandId__c, cred);
            }
        }
        System.debug('brandIdAndCredsMetadataMap---'+brandIdAndCredsMetadataMap.keySet());
        Log.push('Brad id map ' + brandIdAndCredsMetadataMap.keySet());
        //Query A1_C360API_Tokens__mdt for unexpired tokens for this brand
        List<A1_C360API_Tokens__mdt> accesstokenList = retrieveTokenMetadata(brandIdAndCredsMetadataMap);
        //iterate expired token list to get active access token
        System.debug('accesstokenList---'+accesstokenList);
        if (accesstokenList.size() > 0){
            for (A1_C360API_Tokens__mdt accesTokenRec : accesstokenList){
                if (brandTokenMap.containsKey(accesTokenRec.BrandId__c)){
                    brandTokenMap.get(accesTokenRec.BrandId__c).add(accesTokenRec.access_token__c);
                } else{
                    brandTokenMap.put(accesTokenRec.BrandId__c, new List<String>{ accesTokenRec.access_token__c });
                }
            }
        }
        Log.push('brandTokenMap' + brandTokenMap);
        System.debug('brandTokenMap---'+brandTokenMap);
        //Checking if for each brand there is two unexpired key else need to get it
        for (String brand : brandIdAndCredsMetadataMap.keySet()){
            System.debug('brand'+brand);
            System.debug('brandTokenMap.get(brand).size()'+brandTokenMap.get(brand).size());
            System.debug('!brandTokenMap.containsKey(brand)'+!brandTokenMap.containsKey(brand));
            System.debug('if (!brandTokenMap.containsKey(brand) || brandTokenMap.get(brand).size() < 2)'+(!brandTokenMap.containsKey(brand) || brandTokenMap.get(brand).size() < 2));
            if (!brandTokenMap.containsKey(brand) || brandTokenMap.get(brand).size() < 2){
                getBrandToken.add(brand);
            }
        }
        Log.push('getBrandToken:' + getBrandToken);

        if (!getBrandToken.isEmpty()){
            for (Integer i = 0; i < getBrandToken.size(); i++){
                Log.push('getBrandToken:' + getBrandToken[i]);
                //make a GET call to get new acces toekn
                String authBearer = 'Basic ' + brandIdAndCredsMetadataMap.get(getBrandToken[i]).Base64__c;
                String reqEndPoint = SYSTEM.LABEL.callout_A1_C360API_AuthEndPoint_token;
                HttpResponse getRes = httpCalloutMethod(reqEndPoint, authBearer, 'GET');
                if (getRes != null){
                    if (getRes.getStatusCode() == 200){
                        responseClass responseClassValue = (responseClass)JSON.deserialize(getRes.getBody(), responseClass.class);
                        List<String> presentTokenList = brandTokenMap.get(getBrandToken[i]);
                        Log.push('### presentTokenList' + presentTokenList);
                        if (presentTokenList == null){
                            responseValAndMetdataMap.put(brandIdAndCredsMetadataMap.get(getBrandToken[i]), responseClassValue);
                        }
                        if (presentTokenList != null){
                            if (!presentTokenList.contains(responseClassValue.access_token)){
                                responseValAndMetdataMap.put(brandIdAndCredsMetadataMap.get(getBrandToken[i]), responseClassValue);
                            } else{
                                // only one token exists in Custom meta data so create new one
                                reqEndPoint = SYSTEM.LABEL.callout_A1_C360API_AuthEndPoint_authentication_action_login;
                                HttpResponse resp = httpCalloutMethod(reqEndPoint, authBearer, 'POST');
                                if (resp != null){
                                    if (resp.getStatusCode() == 200){
                                        responseClass resVal = (responseClass)JSON.deserialize(resp.getBody(), responseClass.class);
                                        if (String.isNotEmpty(resVal.access_token)){
                                            responseValAndMetdataMap.put(brandIdAndCredsMetadataMap.get(getBrandToken[i]), resVal);
                                        }
                                    }
                                }
                            }
                        }
                    } else{
                        reqEndPoint = SYSTEM.LABEL.callout_A1_C360API_AuthEndPoint_authentication_action_login;
                        HttpResponse resp = httpCalloutMethod(reqEndPoint, authBearer, 'POST');
                        if (resp.getStatusCode() == 200){
                            responseClass resVal = (responseClass)JSON.deserialize(resp.getBody(), responseClass.class);
                            if (String.isNotEmpty(resVal.access_token)){
                                responseValAndMetdataMap.put(brandIdAndCredsMetadataMap.get(getBrandToken[i]), resVal);
                            }
                        }
                    }
                }
            }
        }
        //inserts current active token into A1_C360API_Tokens__mdt custom metadata type
        if (responseValAndMetdataMap.keySet().size() > 0)
            CustomMetadataCallback.createMetaDataA1c360APIToken(responseValAndMetdataMap);
        Logger.logDebug();
    }

    //Generic method to make C360 API callout
    private static HttpResponse httpCalloutMethod(String reqEP, String authBrr, String method){
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setHeader(SYSTEM.LABEL.Authorization, authBrr);
        req.setHeader(SYSTEM.LABEL.ContentType, SYSTEM.LABEL.applicationjson);
        req.setHeader(SYSTEM.LABEL.ContentLength, SYSTEM.LABEL.X0);
        req.setEndpoint(reqEP);
        req.setMethod(method);
        try{
            res = http.send(req);
            Log.push('***response body:' + res.getBody());
        } catch (System.CalloutException e){
            Logger.logException(e);
        }
        Logger.logDebug();
        return res;
    }

    //Wrapper class to collect token response
    public class responseClass{
        public String access_token;    //0a4e6b2f-ef38-4e62-b1ad-d356973ca4aa
        public String token_type;    //bearer
        public Integer expires_in;

        //15549620
    }

}