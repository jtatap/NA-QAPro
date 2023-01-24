global class SFCC_ContactRewardListedResponse {
      
          //Wrapper class to warp the various  List<sObject> as Super wrapper
      global class supersobjectWrapper{
          List<Reward__c> Rewards=new List<Reward__c>();//A list to hold the Rewards
          List<Contact> Contacts=new List<Contact>();//A list to hold the Contacts  
     }
        
     //This method will be called as the http get request
     public static supersobjectWrapper makeResponseString(){  
         List<Reward__c>  lstRew=new List<Reward__c>();
         List<Contact> lstcontacts=new List<Contact>();
         
         lstRew=[Select Id,LoyaltyId__c, Reward_Number__c, RewardId__c, RewardType__c, 
                                      Status__c,ExpireDate__c
                                      From Reward__c];
         lstcontacts=[Select id,CreatedDate,LastModifiedDate,Isdeleted from Contact];
         
         supersobjectWrapper superWrap=new supersobjectWrapper();//Instantiating thesuperclass
         superWrap.Contacts = lstcontacts ;
         superWrap.Rewards = lstRew;
         
          return superWrap;
         }
}