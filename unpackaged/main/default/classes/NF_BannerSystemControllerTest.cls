@isTest
public class NF_BannerSystemControllerTest {

    @isTest
    public static void getAllMessagesTest(){
        NF_BannerSystemController.getAllMessages();
        NF_BannerSystemController.getAllMessages('Test');
        NF_BannerSystemController.getMessages('Test','test','test');
        NF_BannerSystemController.getBrandsAndTopics();
        
    }
}