/******************************************************************************
* @Description: Show Rewards Data to Case and Contact Page
* @Author	  : Rounak P
* @Date		  : 26:12.2019
* @JIRA		  : NASSC-1176,1178,1180
*
******************************************************************************/ 


public without sharing class A1_RewardsDataApexController {

    @AuraEnabled
    public static List<RewardWrapper> getLoyaltyId(Id recordIds) {
        
        Map<String,String> LoyaltyMap = new Map<String,String>();
        
        Contact conRecord;
        Case caseRecord;
        String brandId;
		List<Reward__c> listRewards = new List<Reward__c>();       
        Schema.SObjectType token = recordIds.getSObjectType();
        Schema.DescribeSObjectResult dr = token.getDescribe();
		System.debug('Name = '+dr.getName());
       
        // fetching loyalty MDT
        List<LoyaltySettings__mdt> loyaltyList = [Select Id, BrandId__c, Parent_Brand__c from LoyaltySettings__mdt];
        for(LoyaltySettings__mdt loyalRecord : loyaltyList){
            if(loyalRecord.Parent_Brand__c != null){
            	LoyaltyMap.put(loyalRecord.BrandId__c,loyalRecord.Parent_Brand__c);
            }
        }
        System.debug('Loyalty Map = '+LoyaltyMap);
        
        
        if(dr.getName().equals('Contact')){
            conRecord = [Select LoyaltyID__c,Brand_Id__c from Contact WHERE Id=:recordIds];
            brandId = conRecord.Brand_Id__c;
        }
        else if(dr.getName().equals('Case')){
            caseRecord = [Select Contact.LoyaltyID__c,Contact.Brand_Id__c from Case WHERE Id=:recordIds];
            brandId = caseRecord.Contact.Brand_Id__c;
        }       
        
        //if records brand is child, assigning brandId with its parent
        if(LoyaltyMap.containsKey(brandId)){
            brandId = LoyaltyMap.get(brandId);
        }
        
        //System.debug('Loyalty Id = '+conRecord.LoyaltyID__c);
        //System.debug('Actual BrandId = '+conRecord.Brand_Id__c);
        //System.debug('Updated BrandId = '+brandId);
        
        //System.debug('Loyalty Id = '+caseRecord.Contact.LoyaltyID__c);
        //System.debug('Brand Id = '+caseRecord.Contact.Brand_Id__c);
        
        if(conRecord!=null && conRecord.LoyaltyID__c !=null){
             listRewards = AgileOne.getRewardsData(conRecord.LoyaltyID__c);
        }
        else if(caseRecord!=null && caseRecord.Contact.LoyaltyID__c !=null){
             listRewards = AgileOne.getRewardsData(caseRecord.Contact.LoyaltyID__c);
        }
        
        Map<String,String> metadataMap = new Map<String,String>();
        Set<String> rewType = new Set<String>();
	    for(Reward__c rew : listRewards)
        {
			rewType.add(rew.RewardType__c);
        }

        List<A1_RewardTypes__mdt> rewardMetadata = [Select Description__c,RewardType__c from A1_RewardTypes__mdt WHERE BrandId__c=:brandId AND RewardType__c IN : rewType];
        for(A1_RewardTypes__mdt meta : rewardMetadata){
            metadataMap.put(meta.RewardType__c,meta.Description__c);
        }
        
        
      List<RewardWrapper> wrapperlist = new List<RewardWrapper>();
      for(Reward__c rew : listRewards){
           RewardWrapper wrapperObj = new RewardWrapper();
           wrapperObj.rewardId = rew.RewardId__c;
           wrapperObj.transactionId = rew.TransactionId__c;
           wrapperObj.status = rew.Status__c;
           wrapperObj.description = metadataMap.get(rew.RewardType__c);
           System.debug('***Get BackEnd ExpireDate__c = '+rew.ExpireDate__c);
           //Date expDate = rew.Expire_Date_form__c;
          
           String getExpireDateString = DateTime.newInstance(rew.ExpireDate__c.year(),rew.ExpireDate__c.month(),rew.ExpireDate__c.day()).format('yyyy-MM-dd');
		   System.debug('***Expire_Date_form__c AS String = '+getExpireDateString);
           wrapperObj.expireDate = getExpireDateString;
           wrapperlist.add(wrapperObj);
        }
      System.debug('***Final Data = '+wrapperlist);
      return wrapperlist;
    }
    
 public class RewardWrapper {
       	@AuraEnabled
        public String rewardId { get; set; }
        @AuraEnabled
        public String transactionId { get; set; }
        @AuraEnabled
        public String description { get; set; }
        @AuraEnabled
        public String status { get; set; }
     	@AuraEnabled
        public String expireDate { get; set; }
		}
}