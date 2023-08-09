public with sharing class NF_NavigationalTopicArticlesController {
//implements Comparable
    @AuraEnabled
    Public static List<knowledgeArticleVerWrapper> getArticles(){
        //String networkId = '0DB1U000000XbkNWAS';
        String networkId = Network.getNetworkId();
        String networkName= '';
        if(!Test.isRunningTest()){
            Network netRec = [SELECT Id, Name, Description, SelfRegProfileId FROM Network Where Id = :networkId limit 1];
            networkName = netRec.Name;
        }
        
       

        Map<Integer,Navigational_Topic_Information__mdt> navTopicmap = new Map<Integer,Navigational_Topic_Information__mdt>();
        List<Navigational_Topic_Information__mdt> navigationTopicList =[Select developerName,Community__c,MasterLabel,Sort_Order__c
                                                                      From Navigational_Topic_Information__mdt where Sort_Order__c != null And Community__c = :networkName order by Sort_Order__c ASC NULLS LAST];
        
        
        if(Test.isRunningTest()){
            navigationTopicList = new List<Navigational_Topic_Information__mdt>{new Navigational_Topic_Information__mdt(developerName='International1',
                                                                                                                    MasterLabel='International1',
                                                                                                                    Sort_Order__c=1)};

            Network NetworkRec = [SELECT Name, Id, Status, Description 
                                 FROM Network order by id limit 1];
            
            if(NetworkRec != null){
                networkId = NetworkRec.Id;
            }else{
                networkId=''; 
            }
            
        }
        
        Set<String> topicSet = new Set<String>();
        if(navigationTopicList != null && navigationTopicList.size() > 0){
            for(Navigational_Topic_Information__mdt navMetadataRecord : navigationTopicList){
                topicSet.add(navMetadataRecord.MasterLabel.trim().toLowerCase());
            }
        }else{

        }

        Map<String,String> topicNameToTopicIdMap = new Map<String,String>();
        List<Topic> topicList = [Select Id, Name, NetworkId FROM Topic WHERE NetworkId = :networkId And Name IN :topicSet ];
        if(topicList != null && topicList.size() > 0){
            for(Topic topicRecord : topicList){
                topicNameToTopicIdMap.put(topicRecord.Name.toLowerCase(),topicRecord.Id);
            }
        }

        Map<String,Set<String>> entityToTopicSetMap = new Map<String,Set<String>>();
        Map<String,Set<String>> topicToEntitySetMap = new Map<String,Set<String>>();
        List<TopicAssignment> topicAsignList = [SELECT Id, EntityId, EntityKeyPrefix, EntityType, TopicId, NetworkId FROM TopicAssignment WHERE TopicId IN :topicList Limit 1000];
       
        if(topicAsignList != null && topicAsignList.size() > 0){
            for(TopicAssignment topicRecord : topicAsignList){
                //entityToTopicMap(topicRecord.EntityId,topicRecord.TopicId);
                if(topicToEntitySetMap.containsKey(topicRecord.TopicId)){
                    topicToEntitySetMap.get(topicRecord.TopicId).add(topicRecord.EntityId);
                }else{
                    topicToEntitySetMap.put(topicRecord.TopicId,new Set<String>{topicRecord.EntityId});
                }
                if(entityToTopicSetMap.containsKey(topicRecord.TopicId)){
                    entityToTopicSetMap.get(topicRecord.EntityId).add(topicRecord.TopicId);
                }else{
                    entityToTopicSetMap.put(topicRecord.EntityId,new Set<String>{topicRecord.TopicId});
                }
            }
        }

        /*List<Knowledge__kav> knowledgeArticleVerList = [SELECT Id, KnowledgeArticleId, PublishStatus, VersionNumber, Title, UrlName, ArticleNumber,Sort_Order__c, ArticleTotalViewCount FROM Knowledge__kav 
                                                                 WHERE Language = 'en_US' AND PublishStatus = 'Online' AND Id in :entityToTopicSetMap.keySet() order by Sort_Order__c Desc Nulls last ];//Limit :Integer.valueOf(articalDisplayed)*/

        Map<String,Knowledge__kav> knowledgeMap = new Map<String,Knowledge__kav>([SELECT Id, KnowledgeArticleId, PublishStatus, VersionNumber, Title, UrlName,Sort_Order__c, ArticleNumber, ArticleTotalViewCount FROM Knowledge__kav 
                                                                                WHERE Language =: SYSTEM.LABEL.en_US AND PublishStatus =: SYSTEM.LABEL.Online AND Sort_Order__c != null AND Id in :entityToTopicSetMap.keySet() order by Sort_Order__c ASC Nulls last ]);
        List<knowledgeArticleVerWrapper> wrapperList = new List<knowledgeArticleVerWrapper>();
        if(navigationTopicList != null && navigationTopicList.size() > 0){
            for(Navigational_Topic_Information__mdt navMetadataRecord : navigationTopicList){
                if(topicNameToTopicIdMap.containskey(navMetadataRecord.MasterLabel.trim().toLowerCase())){
                    String topicName = navMetadataRecord.MasterLabel.trim();
                    String topicId = topicNameToTopicIdMap.get(navMetadataRecord.MasterLabel.trim().toLowerCase());
                    if(topicToEntitySetMap.containsKey(topicId)){
                        List<Knowledge__kav> newKAMap = new List<Knowledge__kav>();
                        for(String knowledgeId : topicToEntitySetMap.get(topicId)){
                            if(knowledgeMap.containsKey(knowledgeId)){
                                newKAMap.add(knowledgeMap.get(knowledgeId));
                            }
                        }
                        if(newKAMap != null && !newKAMap.isEmpty()){
                            wrapperList.add(new knowledgeArticleVerWrapper(topicId,topicName,newKAMap)); 
                        }
                    }
                }
            }
        }

        return wrapperList;

    }

   
    
    Public Class knowledgeArticleVerWrapper{
        @AuraEnabled Public String topicName;
        @AuraEnabled Public String topicId;
        @AuraEnabled Public List<Knowledge__kav> knowledgeArticleVerList;
        public knowledgeArticleVerWrapper(String topicId,String topicName,List<Knowledge__kav> knowledgeArticleVerList){
            this.topicId = topicId;
            this.knowledgeArticleVerList = knowledgeArticleVerList;
            this.topicName = topicName;
        }
    }
}