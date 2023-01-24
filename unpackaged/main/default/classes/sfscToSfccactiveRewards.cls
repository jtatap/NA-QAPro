@RestResource(urlMapping='/Fetching/ActiveRewards1')
global class sfscToSfccactiveRewards {
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
    @httpGet
    global static void doFetch(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        Map<String, String> paramsMap = RestContext.request.params;
        String loyaltyId = paramsMap.get('BrandId');
        String brandId = paramsMap.get('LoyaltyId');
         List<Reward__c> lstRew=[Select Id,LoyaltyId__c, Reward_Number__c, RewardId__c, RewardType__c, Status__c,ExpireDate__c
                                      From Reward__c
                                      Where LoyaltyId__c=:loyaltyId AND Status__c='Active'limit 1];
        //if(lstRew.size()>0){
            res.statusCode = 200;
            SubResponse successres = new SubResponse();
            successres.code='Ok';
            successres.Count=string.valueof(lstRew.size());
        List<ActiveRewards> lstActRew=new List<ActiveRewards>();
        ActiveRewards objRew=new ActiveRewards();
        objRew.TransactionId=loyaltyId;
        objRew.IssuanceDate=brandId;
        lstActRew.add(objRew);
        successres.ActiveRewards=lstActRew;
            res.responseBody = Blob.valueOf(JSON.serialize(successres));
            return;
       // }
    }
    
}