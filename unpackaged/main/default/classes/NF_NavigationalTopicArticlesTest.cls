@IsTest(isParallel=false)
public with sharing class NF_NavigationalTopicArticlesTest {


    public static knowledge__kav getKnowledgeArticle(String title,String Summary,String Urlname){
         knowledge__kav newArticle = new knowledge__kav(Title=title,summary=Summary,urlname=Urlname,Sort_Order__c=1);
         return newArticle;
    } 

    public static topic getTopic(String NetworkId,String name){
        topic newTopic = new topic(NetworkId = NetworkId, name = name);//
         return newTopic;
    } 
    static testMethod void MakeArticle() {
        knowledge__kav newArticle = getKnowledgeArticle('test','xyz','xyz');
        Network NetworkRec = [SELECT Name, Id, Status, Description FROM Network order by id limit 1];
        String NetworkId = (NetworkRec != null ) ? NetworkRec.Id : '';
        topic newTopic = getTopic(NetworkId,'International1');
        insert newTopic;
        string topicID = newTopic.Id; 
        insert newArticle;
        knowledge__kav obj1 = [SELECT Id,Title,KnowledgeArticleId FROM knowledge__kav WHERE id =: newArticle.Id];
        String articleId = obj1.KnowledgeArticleId;
        TopicAssignment Topicass = new TopicAssignment(TopicId = topicID, EntityId = newArticle.Id, NetworkId = NetworkId);
        insert Topicass;
        
        User knowledgeUser = [SELECT id,UserPermissionsKnowledgeUser FROM User WHERE UserPermissionsKnowledgeUser = true AND isActive = true AND Profile.Name = 'System Administrator' LIMIT 1];
        System.runAs(knowledgeUser) {
        	KbManagement.PublishingService.publishArticle(articleId, true);  
        }
        
        Test.startTest();
           List<NF_NavigationalTopicArticlesController.knowledgeArticleVerWrapper> articleList = NF_NavigationalTopicArticlesController.getArticles();
        	system.assertNotEquals(articleList, null);
        Test.StopTest();

    }
}