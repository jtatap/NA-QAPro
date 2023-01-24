/*******************************************************************************************
* @Description: Test Class for class - Rewards
* @Author     : 
* @Date       : April 28
* @JIRA       : NASSC-1710 [NASSC-1712]
*
********************************************************************************************/ 

@isTest
public class RewardsTest {
    static Map<String, String> responseHeaders = new Map<String, String>();
  
    //method: fake response
    //@isTest(SeeAllData=true) 
    public static void setMockResponse(){
        
        responseHeaders.put('Content-Type','application/json');
        SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                                               'Complete',
                                                               '{ }',
                                                               responseHeaders);
        
        System.debug('*** fake response = '+fakeResponse);
        Test.setMock(HttpCalloutMock.class, fakeResponse);        
        
    }
    
    //method: data setup
    @testSetup
    static void dataSetup() {
        List<Reward__c> listRewards = new List<Reward__c>();
        Reward__c rewardObject = new Reward__c(
            LoyaltyId__c = 'C04000218657',
            RewardId__c = '134275624',
            RewardType__c = '16',
            SequenceNumber__c = 'S101',
            Status__c = 'Active',
            ExpireDate__c = System.now(),
            OriginalExpireDate__c = System.now(),
            IssuanceDate__c = System.now()
        );
        listRewards.add(rewardObject);
        insert listRewards;
    }
    
    //method:
    @isTest
    public static void invocablePostRewardsToA1Test(){
        setMockResponse();
        List<Rewards.RewardsData> ListData = new List<Rewards.RewardsData>();
        Rewards.RewardsData obj = new Rewards.RewardsData();
        obj.loyaltyId = 'C04000218657';
        obj.loyaltyFlag = true;
        obj.brandId = '2';
        obj.email = 'lallan@gmail.com';
        obj.rewardId = '134275624';
        ListData.add(obj);
        Rewards.invocablePostRewardsToA1(ListData);
        
    }
    
     //method: data setup
     
     static void dataSetup1() {
        List<Reward__c> listRewards = new List<Reward__c>();
        Reward__c rewardObject = new Reward__c(
            LoyaltyId__c = 'C04000218658',
            RewardId__c = '134275625',
            RewardType__c = '17',
            //SequenceNumber__c = 'S101',
            Status__c = 'Redeemed',
            ExpireDate__c = System.now(),
            OriginalExpireDate__c = System.now(),
            IssuanceDate__c = System.now(),
            RedeemedDate__c=System.now()
        );
        listRewards.add(rewardObject);
        insert listRewards;
    }
    //method:
    @isTest
    public static void invocablePostRewardsToA1Test1(){
        setMockResponse();
        List<Rewards.RewardsData> ListData = new List<Rewards.RewardsData>();
        Rewards.RewardsData obj = new Rewards.RewardsData();
        obj.loyaltyId = 'C04000218658';
        obj.loyaltyFlag = true;
        obj.brandId = '2';
        obj.email = 'test@gmail.com';
        obj.rewardId = '134275625';
        ListData.add(obj);
        Rewards.invocablePostRewardsToA1(ListData);
        
    }
    @isTest
    public static void createErrorLogTest(){
        List<ErrorLog__c> insertErrorLog=new List<ErrorLog__c>();
        String reqEndPoint='Testing';
        String reqBody='test1';
        String resStatusCode='test2';
        String resBody='test3';
        ErrorLog__c logObject = new ErrorLog__c();
        logObject.SourceSystem__c = 'SFSC to AgileOne';
        logObject.FileName__c = 'Posting Rewards to AgileOne';
        logObject.Message__c = 'Response status code: ';
        logObject.StackTrace__c = 'Testing';
        insertErrorLog.add(logObject);
        
        if(insertErrorLog.size()>0){
            insert insertErrorLog;
        }
        
        Rewards.createErrorLogs(reqEndPoint,reqBody,resStatusCode,resBody);
        
    }
     
}