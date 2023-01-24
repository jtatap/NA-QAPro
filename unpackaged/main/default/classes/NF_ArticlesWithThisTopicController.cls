/**
 * @description       : Controller class for nfArtclesWithThisTopic LWC
 * @author            : chayan.batabyal@neuraflash.com
 * @last modified on  : 07-29-2021
 * @last modified by  : chayan.batabyal@neuraflash.com
**/
public without sharing class NF_ArticlesWithThisTopicController {
    /**
    * @description Receives url from community, gets the topic id & returns the related articles
    * @author chayan.batabyal@neuraflash.com | 07-27-2021
    * @param fullURL
    * @return List<Knowledge__kav>
    **/
    @AuraEnabled
    public static List<Knowledge__kav> fetchArticlesToDisplay(String fullURL){
        List<Knowledge__kav> articlesToDisplay = new List<Knowledge__kav>();
        Set<Id> entityIds = new Set<Id>();
        String currentCommunityBaseURL = fullURL.substring(0, fullURL.indexOf('/topic/')) + '/';
        String topicId = fullURL.substring(fullURL.indexOf('/topic/') + 7).split('/')[0];

        for(TopicAssignment eachTopicAsignList : [
            SELECT Id, EntityId
            FROM TopicAssignment
            WHERE TopicId =: topicId
            Limit 1000
        ]){
            entityIds.add(eachTopicAsignList.EntityId);
        }

        if(!entityIds.isEmpty()){
            for(Knowledge__kav eachKAV :[
                SELECT Id, PublishStatus, VersionNumber, Title, UrlName, Sort_Order__c
                FROM Knowledge__kav
                WHERE Language = 'en_US'
                AND PublishStatus = 'Online'
                AND Sort_Order__c != null
                AND Id IN : entityIds
                ORDER BY Sort_Order__c ASC
                NULLS LAST
            ]){
                eachKAV.UrlName = currentCommunityBaseURL + 'article/' + eachKAV.UrlName;
                articlesToDisplay.add(eachKAV);
            }
        }

        return articlesToDisplay;
    }
}