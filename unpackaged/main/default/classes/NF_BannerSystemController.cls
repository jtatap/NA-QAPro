public without sharing class NF_BannerSystemController {

    
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
    
    @AuraEnabled(cacheable=true)
    public static List<NF_Banner__c> getMessages(String homeOrTopic, String recordId, String pageKey){
        try {
            System.debug('homeOrTopic' + homeOrTopic );
            if(homeOrTopic == 'Home' || homeOrTopic == 'Topic'){
                return getAllMessages();
            } else if(homeOrTopic == 'custompage'){
                return getAllMessages(pageKey); 
            } else {
                System.debug('recordId ' + recordId);
                
                System.debug('homeOrTopic ' + homeOrTopic);
                
                
                List<TopicAssignment> listOfTopicAssignment = [SELECT EntityId, TopicId FROM TopicAssignment WHERE EntityId =: recordId];
                
                System.debug('listOfTopicAssignment ' + listOfTopicAssignment);

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
                
                System.debug('listOfMessages ' + listOfMessages);


                return listOfMessages;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Network> getBrandList() {
        return [SELECT Name FROM Network];
    }

    @AuraEnabled(cacheable=true)
    public static List<Topic> getTopicList() {
        return [SELECT Name, NetworkId FROM Topic WHERE NetworkId != null];
    }

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



    /*
    @AuraEnabled(cacheable=true)
    public static List<ConnectApi.ManagedTopicCollection > getSubTopicList(String communityId, String topicId) {
        ConnectApi.ManagedTopicCollection topics = ConnectApi.ManagedTopics.getManagedTopic(communityId, managedTopicId);
        /*
        for (ConnectApi.ManagedTopic managedTopic : topics.managedTopics) {
            System.debug('###managedTopic.topic.name = ' + ((ConnectApi.Topic)managedTopic.topic).name);
            
            Set<String> topicNames = new Set<String>();
            for (ConnectApi.ManagedTopic childManagedTopic : managedTopic.children) {
                topicNames.add(((ConnectApi.Topic)childManagedTopic.topic).name + '\n');
            }
            
            System.debug('### childTopicNames:\n' + String.join(topicNames, '\n'));
        }
        
        return topics.children;
    }
    */
}