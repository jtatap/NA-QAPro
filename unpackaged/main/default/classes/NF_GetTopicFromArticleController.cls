public without sharing class NF_GetTopicFromArticleController {
    
    @AuraEnabled(cacheable=true)
    public static List<String> getTopicList(String recordId) {
        try{
            List<String> topicNameList = new List<String>();
            List<TopicAssignment> topicAssignmentList = [SELECT EntityId, TopicId, Topic.Name FROM TopicAssignment
                                                         WHERE EntityId =: recordId];
            if(!topicAssignmentList.isEmpty()) { for(TopicAssignment eachAssignment : topicAssignmentList) { topicNameList.add(eachAssignment.Topic.Name); }
            }
            return topicNameList;
        }catch (Exception e) { throw new AuraHandledException(e.getMessage()); }
    }
}