/******************************************************************************
* @Description: Scheduler to Tracker API access tokens
* @JIRA		  : NASSC-1188
*
******************************************************************************/ 
global class Scheduler_A1TrackerAPITokens Implements Schedulable {
    
    global void execute(SchedulableContext sc){  
        setTrackerAPITokens();
    }
    
    public class responseClass{
        public String access_token;	//0a4e6b2f-ef38-4e62-b1ad-d356973ca4aa
        public String token_type;	//bearer
        public Integer expires_in;	//15549620
    }
    
    @future(callout=true) 
    public static void setTrackerAPITokens(){
        Map<String,String> brandBase64Map = new Map<String,String>();
        Map <A1_TrackerAPI_creds__mdt,responseClass> responseValAndMetdataMap = new Map <A1_TrackerAPI_creds__mdt,responseClass>();
        Map<String,A1_TrackerAPI_creds__mdt> brandCredMap = new Map<String,A1_TrackerAPI_creds__mdt>();
        Map<String,List<String>> brandTokenMap = new Map<String,List<String>>();
        List<String> brandTokenNeeded = new List<String>(); //Brands for which token need to be generated
        List<String> getBrandToken = new List<String>();
        
        
        List<A1_TrackerAPI_creds__mdt> credsList =[SELECT Id,MasterLabel, Base64__c, BrandId__c, Password__c, Username__c, TenantId__c,DeveloperName
                                                   FROM A1_TrackerAPI_creds__mdt];
        System.debug('### credList size:'+credsList.size());
        
        for(A1_TrackerAPI_creds__mdt cred : credsList){
            System.debug('### cred: '+cred);
            brandBase64Map.put(String.valueOf(cred.BrandId__c), cred.Base64__c);
            brandCredMap.put(cred.BrandId__c, cred);
            brandTokenNeeded.add(cred.BrandId__c);
        }
        
        System.debug('### brandBase64Map: '+brandBase64Map);  
        List<A1_TrackerAPI_tokens__mdt> accesstokenRecord = [SELECT MasterLabel, BrandId__c, access_token__c 
		FROM A1_TrackerAPI_tokens__mdt 
        WHERE BrandId__c = :brandBase64Map.keySet() AND token_expires_at__c >: System.now()];
		
        System.debug('brandBase64Map.keySet() :'+brandBase64Map.keySet());
        
        if (accesstokenRecord.size()>0){
            for(A1_TrackerAPI_tokens__mdt accesToken : accesstokenRecord){
                if(brandTokenMap.containsKey(accesToken.BrandId__c)){
                    brandTokenMap.get(accesToken.BrandId__c).add(accesToken.access_token__c);
                }else{
                    brandTokenMap.put(accesToken.BrandId__c,new List<String>{accesToken.access_token__c});
                }
            }
        }
        System.debug('### brandTokenMap: '+brandTokenMap);
        
        //Checking if for each brand there is two unexpired key else need to get it
        for(String brand: brandTokenNeeded){
            if(!brandTokenMap.containsKey(brand) || brandTokenMap.get(brand).size()<2){
                getBrandToken.add(brand);
            }
        }
        System.debug('### getBrandToken:'+getBrandToken);
        
        for(Integer i=0; i<getBrandToken.size();i++){
            System.debug('### getBrandToken:'+getBrandToken[i]);
            //String authBearer = 'Bearer '+brandBase64Map.get(getBrandToken[i]);
            String authBearer = 'Basic '+brandBase64Map.get(getBrandToken[i]);
            System.debug('### authBearer: '+authBearer);
            String reqEndPoint='callout:A1_TrackerAPI_AuthEndPoint';
            
            HttpResponse responseGetValue = httpCalloutMethod(reqEndPoint,authBearer, 'GET');
            if(responseGetValue != null){
                if(responseGetValue.getStatusCode() == 200){
                    responseClass responseClassValue = (responseClass)JSON.deserialize(responseGetValue.getBody(), responseClass.class);
                    if(String.isNotEmpty(responseClassValue.access_token)){
                        List<String> presentTokenList = brandTokenMap.get(getBrandToken[i]);
                        system.debug('### presentTokenList' + presentTokenList);
                        if(presentTokenList == null){
                         responseValAndMetdataMap.put(brandCredMap.get(getBrandToken[i]),responseClassValue);   
                        }
                        if(presentTokenList != null){
                            if(!presentTokenList.contains(responseClassValue.access_token)){
                           		responseValAndMetdataMap.put(brandCredMap.get(getBrandToken[i]),responseClassValue);
                        	}else {
                            // only one token exists in Custom meta data so create new one
                            reqEndPoint = 'callout:A1_TrackerAPI_AuthEndPointCreate';
                            HttpResponse resp = httpCalloutMethod(reqEndPoint,authBearer, 'POST');
                            if(resp.getStatusCode() == 200){
                                responseClass resVal = (responseClass)JSON.deserialize(resp.getBody(), responseClass.class);
                                if(String.isNotEmpty(resVal.access_token)){
                                    responseValAndMetdataMap.put(brandCredMap.get(getBrandToken[i]),resVal);
                                }
                            }
                        }
                      }                       
                    }
                }else{//if get call doesn't works ,make POST call to create and get new key
                    reqEndPoint = 'callout:A1_TrackerAPI_AuthEndPointCreate';
                    HttpResponse resp = httpCalloutMethod(reqEndPoint,authBearer, 'POST');
                    if(resp.getStatusCode() == 200){
                        responseClass resVal = (responseClass)JSON.deserialize(resp.getBody(), responseClass.class);
                        if(String.isNotEmpty(resVal.access_token)){
                            responseValAndMetdataMap.put(brandCredMap.get(getBrandToken[i]),resVal);
                        }
                    }
                }
            }
            
        }
        System.debug('### responseValAndMetdataMap: '+responseValAndMetdataMap);
        //Inserting Fresh token records in Metadata
        if(responseValAndMetdataMap.keySet().size() > 0) CustomMetadataCallback.createTrackerAPITokenMetaData(responseValAndMetdataMap);
    }
    
    public static HttpResponse httpCalloutMethod(String reqEP,String authBrr, String method){
        HttpResponse res = Null;
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', authBrr);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Content-Length', '0');
        req.setEndpoint(reqEP);
        system.debug('reqEP: '+reqEP);        
        req.setMethod(method);
        System.debug('Request generic '+req);
        Http http = new Http();
        try{
            res = http.send(req);
            System.debug('### response body:'+res.getBody());            
        }catch(System.CalloutException e) { System.debug('Callout error: '+ e); }
        return res;
    }
    
    
}