@isTest(isParallel=false)
public class NF_GetTopicFromArticleControllerTest {

    @isTest
    static void getTopicListWithEmptyTopicTest(){
        Test.startTest();
        List<String> listOfTopics = NF_GetTopicFromArticleController.getTopicList('');
        Test.stopTest();
        System.assert(listOfTopics.size() == 0);
    }
    
}