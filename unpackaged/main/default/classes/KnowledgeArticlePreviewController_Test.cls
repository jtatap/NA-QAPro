@isTest
public class KnowledgeArticlePreviewController_Test {
    
    @isTest
    private static void getCommunityURLTest(){
        
        User tuser = new User();
        tuser.firstName = 'test1';
        tuser.lastName = 'test2';
        tuser.Alias = 'ttalias';
        tuser.TimeZoneSidKey = '';
        tuser.Username = 'testUser@test.com' + System.currentTimeMillis();
        tuser.email = 'test@test.com';
        tuser.TimeZoneSidKey = 'America/Los_Angeles';
        tuser.LocaleSidKey = 'en_US';
        tuser.EmailEncodingKey = 'UTF-8';
        tuser.CommunityNickname = 'testUser123';
        tuser.IsActive = true;
        tuser.LanguageLocaleKey = 'en_US';
        tuser.UserPermissionsKnowledgeUser = true;
        tuser.ProfileId = [
            Select Id FROM Profile Where Name = 'System Administrator' LIMIT 1
        ].Id;
        insert tuser;
        
        Test.startTest(); 
        System.runAs(tuser){
            Knowledge__kav kba = new Knowledge__kav(Title='title1',urlName='test-article',Brand__c ='Calvin Klein');
            Database.SaveResult res = Database.insert(kba,false);
            
            Knowledge__DataCategorySelection dcs = new Knowledge__DataCategorySelection();
            dcs.DataCategoryName='Calvin_Klein_Internal';
            dcs.DataCategoryGroupName = 'PVH_Knowledge_Base';
            dcs.ParentId = kba.Id;
            Database.SaveResult res2 = Database.insert(dcs,false);
            string kbaId = kba.id;  
            
            Knowledge__kav kba2 = new Knowledge__kav(Title='title2',urlName='test-article2',Brand__c ='Calvin Klein');
            Database.SaveResult res3 = Database.insert(kba2,false);
            
            Knowledge__DataCategorySelection dcs2 = new Knowledge__DataCategorySelection();
            dcs2.DataCategoryName='Calvin_Klein_Internal';
            dcs2.DataCategoryGroupName = 'PVH_Knowledge_Base';
            dcs2.ParentId = kba2.Id;  
            
            string kba2Id = kba2.id;
            
            KnowledgeArticlePreviewController.getCommunityURL(kbaId);
            //KnowledgeArticlePreviewController.getCommunityURL(kba2Id);
            KnowledgeArticlePreviewController.getArticleContent(kba2Id);
            Test.stopTest();
        }
    }
    
    
}