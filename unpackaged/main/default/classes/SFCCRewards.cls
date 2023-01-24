@RestResource(urlMapping='/v1/SFCCRewards/')
global class SFCCRewards{
    @httpGet
    global static Reward__c doGetMethod(){
    Reward__c rew= new Reward__c();
    Map<String,String> paramsMap = RestContext.request.params;
   String loyid=paramsMap.get('loyalId');
   // String rawid=paramsMap.get('id');
    rew = [Select Id,LoyaltyId__c, Reward_Number__c, RewardId__c, RewardType__c, 
                                      Status__c,ExpireDate__c
                                      From Reward__c
                                      Where LoyaltyId__c=:loyid AND Status__c='Active'limit 1];
    return rew;
    }
 
   
 
  
}