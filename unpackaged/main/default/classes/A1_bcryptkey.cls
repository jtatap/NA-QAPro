/******************************************************************************
 * Deployed only for testing to UAT
* @Description: API to POST the bCrypt Accesskey
* @Author	  : PVH
* @Date		  : 30:11.2022
******************************************************************************/ 
@RestResource(urlMapping='/get/AcquiaAccessKey')
global class A1_bcryptkey {
    
    global class ActiveBcrypt {
        public String brandId;
        public String applicationID;
        public String accesskey;
        public datetime keyExpireAt;
    }
    
    global class SubResponse {
        public String Code;
        public String Message;
        public List<ActiveBcrypt> ActiveBcrypt;
    }
    
    @httpGet
    global static void doFetch(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        Map<String, String> paramsMap = RestContext.request.params;
        String appName = paramsMap.get('appName');
        String applicationID = paramsMap.get('applicationID');
        String brandId = paramsMap.get('brandId');
        datetime currentDateTime= system.now();
        
        if (string.IsBlank(brandId) || string.IsBlank(appName)) {
            SubResponse objres=new SubResponse();
            res.statusCode = 400;            
            objres.code='INVALID_QUERY'; 
            objres.message='Missing required parameters BrandId or AppName';
            res.responseBody = Blob.valueOf(JSON.serialize(objres));
            return;
        }
       if(brandId=='1' || brandId=='2'){
            List<A1_TrackerAPI_tokens__mdt> Activebcryptkey = Database.query('Select BrandId__c,ApplicationID__c,AppName__c,access_key__c,access_token__c,key_expires_at__c,token_expires_at__c,token_expires_in__c from A1_TrackerAPI_tokens__mdt where BrandId__c=:brandId AND AppName__c=:appName');
           // List<A1_TrackerAPI_tokens__mdt> Activebcryptkey = Database.query('Select BrandId__c,TenantID__c,AppName__c,access_key__c,access_token__c,key_expires_at__c,Source_System__c,token_expires_at__c,token_expires_in__c	,TokenID__c from A1_TrackerAPI_tokens__mdt where BrandId__c=:brandId AND AppName__c=:appName AND key_expires_at__c>=:currentDateTime');
            SubResponse successres = new SubResponse();
            system.debug('Activebcryptkey>>>'+Activebcryptkey);
            if(!Activebcryptkey.isEmpty()){
                res.statusCode = 200;
                successres.message='Success';
                successres.code='Ok';
                successres.ActiveBcrypt=bCryptKeyResponse(Activebcryptkey);
                res.responseBody = Blob.valueOf(JSON.serialize(successres));
                return;
            }else{
                res.statusCode = 200;            
                successres.message='No Active bCryptKeys'; 
                res.responseBody = Blob.valueOf(JSON.serialize(successres));
                return;
            }             
       }else{
            SubResponse objres=new SubResponse();
            res.statusCode = 400;            
            objres.code='INVALID_BRANDID'; 
            objres.message='Invalid BrandId';
            res.responseBody = Blob.valueOf(JSON.serialize(objres));
            return;
        } 
    }
    //Wrapper class to collect bCrypt keys response
    public static List<ActiveBcrypt> bCryptKeyResponse(List<A1_TrackerAPI_tokens__mdt> lstBcryptKeys){
        List<ActiveBcrypt> lstActKeys=new List<ActiveBcrypt>();
        ActiveBcrypt objActKeys;
        for(A1_TrackerAPI_tokens__mdt objRew:lstBcryptKeys){
            objActKeys=new ActiveBcrypt();
            objActKeys.brandId=objRew.BrandId__c;
            objActKeys.applicationID=objRew.ApplicationID__c;
            objActKeys.accesskey=objRew.access_key__c;
            objActKeys.keyExpireAt=objRew.key_expires_at__c;
           
            lstActKeys.add(objActKeys);
            
        }
        return lstActKeys;
    }
    
}