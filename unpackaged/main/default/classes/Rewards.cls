/*******************************************************************************************
 * @Description: Class to Handle Posting Rewards to AgileOne
 * @Author     :
 * @Date       : April 24
 * @JIRA       : NASSC-1710 [NASSC-1712]
 *
 ********************************************************************************************/
public without sharing class Rewards{
    public class RewardData{
        public List<Couponhistory> couponhistory;
        public List<Customers> customers;
    }

    public class Couponhistory{
        public String CampaignID;
        public String CustomerID;
        public String ExpiryTimestamp;
        public String c_originalExpiryTimestamp;
        public String c_redemptionTimestamp;
        public String PromotionID;
        public String SourceCustomerNumber;
        public String SourcePromotionNumber;
        public String MasterCustomerID;
        public String CouponID;
        public String SourceCouponNumber;
        public String StartTimestamp;
        public Boolean IsRedeemed;
        public String c_isExpired;
        public String c_isExtended;
        public String c_sequenceNumber;
        public String c_updateDate;
        public String c_activeFlag;
        public String c_pointBasedReward;
        public String c_accrualPeriod;
        public String c_originalLoyaltyId;
        public String c_rewardId;
    }

    public class Customers{
        public String SourceCustomerNumber;
        public String c_loyaltyid;
        public String ID;
        public String Email;
        public String c_loyaltyFlag;
    }

    @future(callout = true)
    public static void postRewardsToA1(String RewardsDataAsString){

        Log.push('***inside postRewardsToA1');
        List<RewardsData> RewardsDataList = (List<RewardsData>)Json.deserialize(RewardsDataAsString, List<RewardsData>.class);
        Log.push('RewardsDataList****' + RewardsDataList);
        String loyaltyId = RewardsDataList[0].loyaltyId;
        Boolean loyaltyFlag = RewardsDataList[0].loyaltyFlag;
        String brandId = RewardsDataList[0].brandId;
        String email = RewardsDataList[0].email;
        String rewardId = RewardsDataList[0].rewardId;
        DateTime originalExpiryDate = RewardsDataList[0].originalExpiryDate;
        System.debug('originalExpiryDate'+originalExpiryDate);
        Log.push(brandId + '****brandId');
        List<Reward__c> listRewards = [Select Id, LoyaltyId__c, Reward_Number__c, RewardId__c, RewardType__c, 
                                      SequenceNumber__c,Status__c,ExpireDate__c,OriginalExpireDate__c,IssuanceDate__c,
                                      c_isexpired__c, c_isextended__c, LastModifiedDate, Active_Flag__c,RedeemedDate__c
                                      From Reward__c
                                      Where LoyaltyId__c != null AND 
                                      LoyaltyId__c=:loyaltyId AND RewardId__c=:rewardId];
        Log.push('***listRewards = '+listRewards);
        System.debug('listRewards---'+listRewards);
        string rewType;
        if (listRewards.size() > 0){
            rewType = listRewards[0].RewardType__c;
        }
        if (listRewards.size() > 0){

            List<AccuralPeriods__mdt> listAccuralPeriod = [SELECT Id, MasterLabel, AccuralPeriod__c, EndDate__c, StartDate__c
                                                           FROM AccuralPeriods__mdt
                                                           WHERE StartDate__c <= :Date.today() AND 
                                                           EndDate__c >= :Date.today()];
            Log.push('***listAccuralPeriod = '+listAccuralPeriod);
            
             List<A1_TrackerAPI_creds__mdt> listTrackerCreds =[SELECT Id,MasterLabel, Base64__c, BrandId__c, Password__c, 
                                                              Username__c, TenantId__c 
                                                              FROM A1_TrackerAPI_creds__mdt
                                                              WHERE BrandId__c =: brandId];  
            
          /*  List<A1_TrackerAPI_creds__mdt> listTrackerCreds =[SELECT Id,MasterLabel, Base64__c, BrandId__c, Password__c, 
                                                              Username__c, TenantId__c 
                                                              FROM A1_TrackerAPI_creds__mdt
                                                              WHERE (BrandId__c ='9' OR BrandId__c ='1' OR BrandId__c ='2')];*/
            string pointBasedReward;
            List<A1_RewardTypes__mdt> rewardMetadata = [Select Description__c,RewardType__c,Point_Based_Reward__c from A1_RewardTypes__mdt WHERE BrandId__c=:brandId AND RewardType__c=:rewType];
            for(A1_RewardTypes__mdt rew : rewardMetadata){
                pointBasedReward=rew.Point_Based_Reward__c;
            }


            Log.push('***listTrackerCreds = ' + listTrackerCreds);

            if (listTrackerCreds.size() > 0){
                String accessKey = AgileOne.getTrackerAPIAccesskey(listTrackerCreds[0]);
                Log.push('***accessKey = ' + accessKey);
                if (String.isNotBlank(accessKey)){
                    RewardData rewardObject = new RewardData();
                    Couponhistory coupanData = new Couponhistory();
                    Customers customerData = new Customers();
                    List<Couponhistory> listCoupan = new List<Couponhistory>();
                    List<Customers> listCostumer = new List<Customers>();
                    // String OriginalExpireDate = String.valueOf(listRewards[0].OriginalExpireDate__c.getTime());

                    /*coupan data*/
                    if(String.isNotBlank(listRewards[0].RewardType__c)) coupanData.CampaignID = listRewards[0].RewardType__c;
                    if(String.isNotBlank(listRewards[0].LoyaltyId__c)) coupanData.CustomerID = listRewards[0].LoyaltyId__c;
                    if(listRewards[0].ExpireDate__c != null) coupanData.ExpiryTimestamp = String.valueOf(listRewards[0].ExpireDate__c.getTime());
                    if(listRewards[0].OriginalExpireDate__c != null) {
                        coupanData.c_originalExpiryTimestamp = String.valueOf(listRewards[0].OriginalExpireDate__c.getTime());
                    } else{
                        coupanData.c_originalExpiryTimestamp = '';
                    }
                    //if (String.isNotBlank(listRewards[0].RewardType__c))
                      //  coupanData.PromotionID = listRewards[0].RewardType__c;
                    if (String.isNotBlank(listRewards[0].LoyaltyId__c))
                        coupanData.SourceCustomerNumber = listRewards[0].LoyaltyId__c;
                    //if (String.isNotBlank(listRewards[0].RewardType__c))
                      //  coupanData.SourcePromotionNumber = listRewards[0].RewardType__c;
                    if (String.isNotBlank(listRewards[0].LoyaltyId__c))
                        coupanData.MasterCustomerID = listRewards[0].LoyaltyId__c;
                    if (String.isNotBlank(listRewards[0].RewardId__c))
                        coupanData.CouponID = listRewards[0].RewardId__c;
                    if (String.isNotBlank(listRewards[0].RewardId__c))
                        coupanData.SourceCouponNumber = listRewards[0].RewardId__c;
                    if (listRewards[0].IssuanceDate__c != null)
                        coupanData.StartTimestamp = String.valueOf(listRewards[0].IssuanceDate__c.getTime());
                    if (String.isNotBlank(listRewards[0].Status__c)){
                        if (listRewards[0].Status__c == SYSTEM.LABEL.Redeemed)
                            coupanData.IsRedeemed = true;
                        else
                            coupanData.IsRedeemed = false;
                    }
                    //NACDT-4065
                    if (listRewards[0].RedeemedDate__c != null){
                        if (listRewards[0].Status__c == SYSTEM.LABEL.Redeemed)
                            coupanData.c_redemptionTimestamp = String.valueOf(listRewards[0].RedeemedDate__c.getTime());
                    }

                    if (String.isNotBlank(listRewards[0].c_isexpired__c))
                        coupanData.c_isExpired = listRewards[0].c_isexpired__c;
                    if (String.isNotBlank(listRewards[0].c_isextended__c))
                        coupanData.c_isExtended = listRewards[0].c_isextended__c;
                    if (String.isNotBlank(listRewards[0].RewardId__c))
                        coupanData.c_sequenceNumber = listRewards[0].RewardId__c;
                    if (listRewards[0].LastModifiedDate != null)
                        coupanData.c_updateDate = String.valueOf(listRewards[0].LastModifiedDate.getTime());
                    //  if(String.isNotBlank(listRewards[0].Active_Flag__c)) coupanData.c_activeFlag = listRewards[0].Active_Flag__c;
                    //coupanData.c_pointBasedReward = SYSTEM.LABEL.Yes;
                    if (String.isNotBlank(listRewards[0].c_isexpired__c) && listRewards[0].c_isexpired__c == SYSTEM.LABEL.Yes){
                        coupanData.c_activeFlag = SYSTEM.LABEL.No;
                    } else if (String.isNotBlank(listRewards[0].c_isextended__c) && listRewards[0].c_isextended__c == SYSTEM.LABEL.Yes){
                        coupanData.c_activeFlag = SYSTEM.LABEL.Yes;
                    } else if (String.isNotBlank(listRewards[0].Active_Flag__c)){
                        coupanData.c_activeFlag = listRewards[0].Active_Flag__c;
                    }


                    if (String.isNotBlank(listAccuralPeriod[0].AccuralPeriod__c))
                        coupanData.c_accrualPeriod = listAccuralPeriod[0].AccuralPeriod__c;
                    if (String.isNotBlank(listRewards[0].LoyaltyId__c))
                        coupanData.c_originalLoyaltyId = listRewards[0].LoyaltyId__c;
                    if (String.isNotBlank(listRewards[0].RewardType__c))
                        coupanData.c_rewardId = listRewards[0].RewardType__c;
                    if (String.isNotBlank(listRewards[0].RewardType__c) && listRewards[0].RewardType__c == rewType){
                        coupanData.c_pointBasedReward = pointBasedReward;
                    }

                    /*customer data*/
                    if (String.isNotBlank(listRewards[0].LoyaltyId__c))
                        customerData.SourceCustomerNumber = listRewards[0].LoyaltyId__c;
                    if (String.isNotBlank(listRewards[0].LoyaltyId__c))
                        customerData.c_loyaltyid = listRewards[0].LoyaltyId__c;
                    if (String.isNotBlank(listRewards[0].LoyaltyId__c))
                        customerData.ID = listRewards[0].LoyaltyId__c;
                    if (String.isNotBlank(email))
                        customerData.Email = email;
                    if (loyaltyFlag)
                        customerData.c_loyaltyFlag = SYSTEM.LABEL.Yes;
                    else
                        customerData.c_loyaltyFlag = SYSTEM.LABEL.No;
                    listCoupan.add(coupanData);
                    listCostumer.add(customerData);

                    Log.push('***listCoupan = ' + listCoupan);
                    System.debug('listCoupan---'+listCoupan);
                    Log.push('***listCostumer = ' + listCostumer);
                    rewardObject.couponhistory = new List<Couponhistory>();
                    rewardObject.couponhistory.addAll(listCoupan);
                    rewardObject.customers = new List<Customers>();
                    rewardObject.customers.addAll(listCostumer);
                    String body = String.valueOf('{"couponhistory":' + JSON.serialize(rewardObject.couponhistory) + ',"customers":' + JSON.serialize(rewardObject.customers) + '}');
                    Log.push('***body = ' + body);

                    String reqEndPoint = SYSTEM.LABEL.callout_A1_TrackerAPI_DataEndPoint + listTrackerCreds[0].TenantId__c + '/dw/tracker?scheme=a1webtag&accessKey=' + accessKey;
                    Log.push('***reqEndPoint = ' + reqEndPoint);
                    HttpRequest req = new HttpRequest();
                    HttpResponse res = new HttpResponse();
                    req.setHeader('Content-Type', 'application/json');
                    req.setBody(body);
                    req.setEndpoint(reqEndPoint);
                    req.setMethod('POST');
                    
                    Http http = new Http();
                    try{
                        res = http.send(req);
                        Log.push('***response body:' + res.getBody());

                    } catch (System.CalloutException e){
                        Logger.logException(e);
                    }

                    if (String.valueOf(res.getStatusCode()).startsWith('2')){
                        Log.push('^^^Posting Rewards to AgileOne Success with StatusCode = ' + res.getStatusCode());
                    } else{
                        createErrorLogs(reqEndPoint, body, String.valueOf(res.getStatusCode()), res.getBody());
                    }
                } else{
                    Log.push('***Access Key is Blank');
                }

            }
            listRewards[0].ExpireDate__c = originalExpiryDate;
            update listRewards;

        }
        Logger.logDebug();
    }

    //method: create logs in ErrorLog__c object
    public static void createErrorLogs(String reqEndPoint, String reqBody, String resStatusCode, String resBody){
        ErrorLog__c logObject = new ErrorLog__c();
        logObject.SourceSystem__c = 'SFSC to AgileOne';
        logObject.FileName__c = 'Posting Rewards to AgileOne';
        logObject.Message__c = 'Response status code: '+ resStatusCode;
        logObject.StackTrace__c = 'POST '+ reqEndPoint + ' ; request payload: '+ reqBody + ' ; response body: ' + resBody;
        
        try{
            insert logObject;
        } catch (Exception e){
            Logger.logException(e);
        }
    }

    @InvocableMethod(label = 'invocable Post Rewards'description = 'Post Rewards')
    public static void invocablePostRewardsToA1(List<RewardsData> rewardsDataList){
        Log.push('***inside invocablePostRewardsToA1');
        String jsonString = json.serialize(rewardsDataList);
        Logger.logDebug();
        postRewardsToA1(jsonString);
    }

    public class RewardsData{
        @InvocableVariable
        public String loyaltyId;
        @InvocableVariable
        public Boolean loyaltyFlag;
        @InvocableVariable
        public String brandId;
        @InvocableVariable
        public String email;
        @InvocableVariable
        public String rewardId;
        @InvocableVariable
        public Datetime originalExpiryDate;

    }

}