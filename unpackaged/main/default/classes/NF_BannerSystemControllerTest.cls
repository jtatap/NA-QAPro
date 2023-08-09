@isTest(isParallel=false)
public class NF_BannerSystemControllerTest {
    
    @testSetup
    public static void testData() {
        List<Network> networkList = NF_BannerSystemController.getBrandList();
        if(networkList.size() > 0){
            List<NF_Banner__c> listNb = new List<NF_Banner__c>();
        	
            for(Network net :  networkList){
                NF_Banner__c nb = TestDataFactory.createNfBanner(net.Id);
                listNb.add(nb);                
            }
            insert listNb;
    	}
    }     

    @isTest
    public static void getAllMessagesOverallTest(){
        List<NF_Banner__c> nfBannerLst = NF_BannerSystemController.getAllMessages();
        System.assertEquals(true, nfBannerLst.size() > 0);
        
        List<NF_Banner__c> nfAllMsgLst = NF_BannerSystemController.getAllMessages('Test');
        System.assertEquals(false, nfAllMsgLst.size()>0);
        
        List<NF_Banner__c> nfMsgLst = NF_BannerSystemController.getMessages('Test','test','test');
        System.assertEquals(false, nfMsgLst.size()>0);
        
        NF_BannerSystemController.getBrandsAndTopics();
    }
    
    @isTest
    public static void getAllMessagesOverallTest1(){
        List<NF_Banner__c> nfMsgLst = NF_BannerSystemController.getMessages('Home','test','test');
        List<NF_Banner__c> nfMsgLst1 = NF_BannerSystemController.getMessages('custompage','test','test');
    }
    
}