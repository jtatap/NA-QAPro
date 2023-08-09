/**
 * @description       : Test class for NF_ArticlesWithThisTopicController
 * @author            : chayan.batabyal@neuraflash.com
 * @last modified on  : 07-29-2021
 * @last modified by  : chayan.batabyal@neuraflash.com
**/
@isTest(seeAllData = false)
public class NF_ArticlesWithThisTopicControllerTest {
    /**
    * @description Setup method
    * @author chayan.batabyal@neuraflash.com | 07-28-2021
    **/
    @testSetup
    static void makeData(){
        Id networkId = [SELECT Id FROM Network Order By Id LIMIT 1].Id;

        /*Knowledge__kav newArticle = new Knowledge__kav(
            Title = 'TestTitle', Summary = 'TestSummary', URLName='TestURL', Sort_Order__c = 1
        );
        insert newArticle;

        KbManagement.PublishingService.publishArticle([
            SELECT KnowledgeArticleId
            FROM Knowledge__kav
            WHERE Id =: newArticle.Id
            LIMIT 1
        ].KnowledgeArticleId, true);*/
        
        User knowledgeUser = [SELECT id,UserPermissionsKnowledgeUser FROM User WHERE UserPermissionsKnowledgeUser = true AND isActive = true AND Profile.Name = 'System Administrator' LIMIT 1];
        
        Knowledge__kav newArticle = new Knowledge__kav(Summary= 'TestSummary', Language = 'en_US', Title = 'TestTitle', UrlName = 'TestURL',Sort_Order__c=1);
		insert newArticle;

		Knowledge__kav k = [SELECT KnowledgeArticleId, PublishStatus FROM Knowledge__kav WHERE Id = :newArticle.Id];
		String articleID = k.KnowledgeArticleId;
        
        System.runAs(knowledgeUser){
           KbManagement.PublishingService.publishArticle(articleID, true);
        }
		
        Topic newTopic = new topic(NetworkId = networkId, Name = 'TestTopic');
        insert newTopic;

        insert new TopicAssignment(
            TopicId = newTopic.Id, EntityId = newArticle.Id, NetworkId = networkId
        );
    }

    /**
    * @description Tests the functionality of the fetchArticlesToDisplay method
    * @author chayan.batabyal@neuraflash.com | 07-27-2021
    * @return testMethod
    **/
    public static testMethod void fetchArticlesToDisplayTest(){
        Test.startTest();

        System.assertEquals(NF_ArticlesWithThisTopicController.fetchArticlesToDisplay(
            'https://anyCommunityURL/s/topic/' + [SELECT Id FROM Topic ORDER BY CreatedDate DESC LIMIT 1].Id
        )[0].URLName.equals('https://anyCommunityURL/s/article/TestURL'), true, 'URL is as expected.');

        Test.stopTest();
    }
}