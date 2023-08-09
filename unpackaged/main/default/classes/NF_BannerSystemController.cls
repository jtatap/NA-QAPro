/**
 * @description       : Controller to be used in the NF Banner System
 * @author            : Luis Rocha
 * @last modified on  : 06-21-2021
 * @last modified by  : Luis Rocha
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   06-21-2021   Luis Rocha   Initial Version
**/
public without sharing class NF_BannerSystemController {

    /**
    * @description retrieve all brands (Netowrks)
    * @author Luis Rocha | 06-21-2021 
    * @return List<Network> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<Network> getBrandList() {
        return [SELECT Name FROM Network];
    }
    
    /**
    * @description 
    * @author Luis Rocha | 06-21-2021 
    * @return List<NF_Banner__c> a list of the custom object banner
    **/
    @AuraEnabled(cacheable=true)
    public static List<NF_Banner__c> getAllMessages(){
        try {
            List<NF_Banner__c> listOfMessages = [SELECT Message__c, 
                Brand__c,
                DateStart__c, 
                DateEnd__c, 
                Active__c,
                DisplayonHomepageorTopic__c,
                TopicId__c,
                ImageFile__c
            FROM NF_Banner__c
            WHERE Active__c = true 
            AND DateStart__c <=: System.Today()
            AND DateEnd__c >= Today
            AND Brand__c != null];
            return listOfMessages;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 
    * @author Luis Rocha | 06-21-2021 
    * @param pageKey 
    * @return List<NF_Banner__c> a list of the custom object banner
    **/
    @AuraEnabled(cacheable=true)
    public static List<NF_Banner__c> getAllMessages(String pageKey){
        try {
            List<NF_Banner__c> listOfMessages = [SELECT Message__c, 
                Brand__c,
                DateStart__c, 
                DateEnd__c, 
                Active__c,
                DisplayonHomepageorTopic__c,
                TopicId__c,
                ImageFile__c,
                PageKey__c
            FROM NF_Banner__c
            WHERE Active__c = true 
            AND DateStart__c <=: System.Today()
            AND DateEnd__c >= Today
            AND PageKey__c =: pageKey
            AND Brand__c != null];
            return listOfMessages;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**
    * @description 
    * @author Luis Rocha | 06-21-2021 
    * @param homeOrTopic 
    * @param recordId 
    * @param pageKey 
    * @return List<NF_Banner__c> a list of the custom object banner
    **/
    @AuraEnabled(cacheable=true)
    public static List<NF_Banner__c> getMessages(String homeOrTopic, String recordId, String pageKey){
        try {
            if(homeOrTopic == 'Home' || homeOrTopic == 'Topic'){
                return getAllMessages();
            } else if(homeOrTopic == 'custompage'){
                return getAllMessages(pageKey); 
            } else {
                List<TopicAssignment> listOfTopicAssignment = [SELECT EntityId, 
                        TopicId 
                    FROM TopicAssignment 
                    WHERE EntityId =: recordId];
                
                Set<Id> setOfTopicIds = new Set<Id>();
                for(TopicAssignment topicAssignment : listOfTopicAssignment ){
                    setOfTopicIds.add(topicAssignment.TopicId);
                }

                List<NF_Banner__c> listOfMessages = [SELECT Message__c, 
                    Brand__c,
                    DateStart__c, 
                    DateEnd__c, 
                    Active__c,
                    DisplayonHomepageorTopic__c,
                    TopicId__c,
                    ImageFile__c
                FROM NF_Banner__c
                WHERE Active__c = true 
                AND DateStart__c <=: System.Today()
                AND DateEnd__c >= Today
                AND TopicId__c in : setOfTopicIds];
                
                return listOfMessages;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description Retrieve all topics that have a network attached to it. 
    * @author Luis Rocha | 06-21-2021 
    * @return List<Topic> a list of all topics that have a brand attached to it. 
    **/
    @AuraEnabled(cacheable=true)
    public static List<Topic> getTopicList() {
        return [SELECT Name, NetworkId FROM Topic WHERE NetworkId != null];
    }

    /**
    * @description : Retrieves the Brands and Topics
    * @author Luis Rocha | 06-21-2021 
    * @return BrandAndTopicWrapper the wrapper including both the topics and brands 
    **/
    @AuraEnabled(cacheable=true)
    public static BrandAndTopicWrapper getBrandsAndTopics() {
        BrandAndTopicWrapper batw = new BrandAndTopicWrapper();
        batw.topics = getTopicList();
        batw.brands = getBrandList();
        return batw;
    }

    // wrapper class with @AuraEnabled and {get;set;} properties 
    public class BrandAndTopicWrapper{
        @AuraEnabled
        public List<Topic>  topics{get;set;}
        @AuraEnabled
        public List<Network>  brands{get;set;}
    }
}