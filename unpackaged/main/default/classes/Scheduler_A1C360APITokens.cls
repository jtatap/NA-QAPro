/******************************************************************************
* @Description: Scheduler to C360API Token
* @Author	  : Trupti Bhirud 
* @Date		  : 01:01.2020
* @JIRA		  : NASSC-1190,NASSC-1188   
*
******************************************************************************/ 
global class Scheduler_A1C360APITokens implements Schedulable{
    
	global void execute(SchedulableContext sc) {
        setC360APITokens();
    }
    
    @future(callout=true) 
    public static void setC360APITokens(){
        List<String> getBrandToken = new List<String>();
        Map<String,List<String>> brandTokenMap = new Map<String,List<String>>();
        List<String> brandTokenNeeded = new List<String>(); //Brands for which token need to be generated
        Map<String,A1_C360API_creds__mdt> brandIdAndCredsMetadataMap = new  Map<String,A1_C360API_creds__mdt>();
        Map <A1_C360API_creds__mdt,responseClass> responseValAndMetdataMap = new Map <A1_C360API_creds__mdt,responseClass>(); 
        
        //get A1_C360API_creds__mdt for all brand records
        List<A1_C360API_creds__mdt> C360CredsList= [SELECT BrandId__c, TenantId__c, Username__c, Password__c,Base64__c,MasterLabel,
                                                    DeveloperName FROM A1_C360API_creds__mdt ];        
        if(! C360CredsList.isEmpty()){
            for(A1_C360API_creds__mdt cred :C360CredsList){
            	brandIdAndCredsMetadataMap.put(cred.BrandId__c,cred);       
            }
        }
        System.debug('Brad id map '+brandIdAndCredsMetadataMap.keySet());
        //Query A1_C360API_Tokens__mdt for unexpired tokens for this brand        
        List<A1_C360API_Tokens__mdt> accesstokenList = [SELECT BrandId__c, access_token__c,DeveloperName
                                                    	FROM A1_C360API_Tokens__mdt 
                                                    	WHERE BrandId__c =: brandIdAndCredsMetadataMap.keySet()
                                                        AND expires_at__c > :System.now() ];
        //iterate expired token list to get active access token              
         if (accesstokenList.size()>0){
            for(A1_C360API_Tokens__mdt accesTokenRec : accesstokenList){
                if(brandTokenMap.containsKey(accesTokenRec.BrandId__c)){
                    brandTokenMap.get(accesTokenRec.BrandId__c).add(accesTokenRec.access_token__c);
                }else{
                    brandTokenMap.put(accesTokenRec.BrandId__c,new List<String>{accesTokenRec.access_token__c});
                }
            }
        }
        System.debug(brandTokenMap);
        //Checking if for each brand there is two unexpired key else need to get it
        for(String brand: brandIdAndCredsMetadataMap.keySet()){
            if(!brandTokenMap.containsKey(brand) || brandTokenMap.get(brand).size()<2){
                getBrandToken.add(brand);
            }
        }
        System.debug('getBrandToken:'+getBrandToken);

        if(! getBrandToken.isEmpty() ){
          for(Integer i=0; i<getBrandToken.size();i++){
             System.debug('getBrandToken:'+getBrandToken[i]);           
             //make a GET call to get new acces toekn           
             String authBearer = 'Basic '+brandIdAndCredsMetadataMap.get(getBrandToken[i]).Base64__c;
             String reqEndPoint='callout:A1_C360API_AuthEndPoint/token';                
             HttpResponse getRes = httpCalloutMethod(reqEndPoint,authBearer, 'GET');
             if(getRes != null){
               if(getRes.getStatusCode() == 200){
                 responseClass responseClassValue = (responseClass)JSON.deserialize(getRes.getBody(), responseClass.class);
                 List<String> presentTokenList = brandTokenMap.get(getBrandToken[i]);
                 system.debug('### presentTokenList' + presentTokenList);
                  if(presentTokenList == null){
                         responseValAndMetdataMap.put(brandIdAndCredsMetadataMap.get(getBrandToken[i]),responseClassValue);  
                   }
                   if(presentTokenList!= null){
                       if(!presentTokenList.contains(responseClassValue.access_token)){
                       		responseValAndMetdataMap.put(brandIdAndCredsMetadataMap.get(getBrandToken[i]),responseClassValue);
                   		}else{
                          // only one token exists in Custom meta data so create new one
                          reqEndPoint = 'callout:A1_C360API_AuthEndPoint/authentication?action=login';
                          HttpResponse resp = httpCalloutMethod(reqEndPoint,authBearer, 'POST');
                          if(resp != null){
                             if(resp.getStatusCode() == 200){
                                responseClass resVal = (responseClass)JSON.deserialize(resp.getBody(), responseClass.class);
                                if(String.isNotEmpty(resVal.access_token)){
                                  responseValAndMetdataMap.put(brandIdAndCredsMetadataMap.get(getBrandToken[i]),resVal);
                                }
                             }
                          }
                        }
                   }
               }else{
                    reqEndPoint = 'callout:A1_C360API_AuthEndPoint/authentication?action=login';
                    HttpResponse resp = httpCalloutMethod(reqEndPoint,authBearer, 'POST');
                    if(resp.getStatusCode() == 200){
                        responseClass resVal = (responseClass)JSON.deserialize(resp.getBody(), responseClass.class);
                        if(String.isNotEmpty(resVal.access_token)){
                            responseValAndMetdataMap.put(brandIdAndCredsMetadataMap.get(getBrandToken[i]),resVal);
                        }
                    }
                 }
             }               
        }
      }
        //inserts current active token into A1_C360API_Tokens__mdt custom metadata type
        if(responseValAndMetdataMap.keySet().size() > 0) CustomMetadataCallback.createMetaDataA1c360APIToken(responseValAndMetdataMap);

    }
    
    //Generic method to make C360 API callout
    private static HttpResponse httpCalloutMethod(String reqEP,String authBrr, String method){
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setHeader('Authorization', authBrr);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Content-Length', '0');
        req.setEndpoint(reqEP);
        req.setMethod(method);      
        try{
            res = http.send(req);
            System.debug('***response body:'+res.getBody());            
        }catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
        }
        return res;
    }
    
    //Wrapper class to collect token response
    public class responseClass{
       	public String access_token;	//0a4e6b2f-ef38-4e62-b1ad-d356973ca4aa
		public String token_type;	//bearer
		public Integer expires_in;	//15549620
    }
}