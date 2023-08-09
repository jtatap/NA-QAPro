/**
* @author         Hemadri Ravilla   <hemadri@stabilistech.com>
* @modifiedBy     Hemadri Ravilla   <hemadri@stabilistech.com>
* @version        1.0
* @created        2021-10-25
* @modified       2021-10-25
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Description     PVH_ActiveRewards will send the Active records to the SFCC
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@RestResource(urlMapping='/Fetching/ActiveRewards')
global class SFCCActiveRewards {
    global class ActiveRewards {
        public String LoyaltyId;
        public String RewardType;
        public String RewardId;
        public String ActiveFlag;
        public String IssuanceDate;
        public String ExpireDate;
        public String TransactionId;
    }
    global class SubResponse {
        public String Code;
        public String Count;
        public List<ActiveRewards> ActiveRewards;
    }
    global class SubResponse1{
        public String Code;
        public String Count;
        public String Message;
    }
    @httpGet
    global static void doFetch(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        Map<String, String> paramsMap = RestContext.request.params;
        String loyaltyId = paramsMap.get('LoyaltyId');
        String brandId = paramsMap.get('BrandId');
        if (String.IsBlank(LoyaltyId) || string.IsBlank(brandId)) {
            SubResponse1 objres1=new SubResponse1();
            res.statusCode = 400;            
            objres1.code=SYSTEM.LABEL.INVALID_QUERY; 
            objres1.message=SYSTEM.LABEL.Missing_required_parameters_BrandId_or_LoyaltyId;
            res.responseBody = Blob.valueOf(JSON.serialize(objres1));
            return;
        }
       if(brandId==SYSTEM.LABEL.X2){
            string status=SYSTEM.LABEL.Active1;
            List<Reward__c> lstRew= Database.query('Select Id,LoyaltyId__c, Reward_Number__c, RewardId__c, RewardType__c, Status__c,ExpireDate__c,IssuanceDate__c,TransactionId__c From Reward__c  Where Status__c=:status AND LoyaltyId__c=:loyaltyId ' );
            SubResponse successres = new SubResponse();
            Log.push('lstRew>>>'+lstRew);
            Logger.logDebug();
            if(!lstRew.isEmpty()){
                res.statusCode = 200;            
                successres.code=SYSTEM.LABEL.Ok1;
                successres.Count=string.valueof(lstRew.size());
                successres.ActiveRewards=sfscMapper(lstRew);
                res.responseBody = Blob.valueOf(JSON.serialize(successres));
                return;
            }else{
                res.statusCode = 200;            
                successres.code=SYSTEM.LABEL.No_Active_Rewards; 
                res.responseBody = Blob.valueOf(JSON.serialize(successres));
                return;
            }             
       }else{
            SubResponse1 objres1=new SubResponse1();
            res.statusCode = 400;            
            objres1.code=SYSTEM.LABEL.INVALID_BRANDID; 
            objres1.message=SYSTEM.LABEL.Invalid_BrandId1;
            res.responseBody = Blob.valueOf(JSON.serialize(objres1));
            return;
        } 
    }
    public static List<ActiveRewards> sfscMapper(List<Reward__c> lstRew){
        List<ActiveRewards> lstActRew=new List<ActiveRewards>();
        ActiveRewards objActRew;
        for(Reward__c objRew:lstRew){
            objActRew=new ActiveRewards();
            objActRew.LoyaltyId=objRew.LoyaltyId__c;
            objActRew.RewardId=objRew.RewardId__c;
            objActRew.RewardType=objRew.RewardType__c;
            objActRew.ActiveFlag=objRew.Status__c;
            objActRew.ExpireDate=string.valueof(objRew.ExpireDate__c);
            objActRew.TransactionId=objRew.TransactionId__c;
             objActRew.IssuanceDate=string.valueof(objRew.IssuanceDate__c);
            lstActRew.add(objActRew);
            
        }
        return lstActRew;
    }
    
}