@isTest
public class SFCCActiveRewardsTest {
    public static testmethod void testdoFetch(){
        test.startTest();
        Reward__c objRew=new Reward__c();
        objRew.LoyaltyId__c='E04005339606';
        objRew.Status__c='Active';
        objRew.RewardId__c='E04005339606';
        insert objRew;
        RestResponse res = new RestResponse();
        string url='E04005339606';
        RestContext.request = new RestRequest();
        RestContext.request.params.put('LoyaltyId','E04005339606');
        RestContext.request.params.put('BrandId', '2');
        RestContext.response= res;
        SFCCActiveRewards.doFetch();
        test.stopTest();
        Assert.areEqual(res.statusCode, 200);
    }
    public static testmethod void testdoFetch1(){
        test.startTest();        
        RestResponse res = new RestResponse();
        string url='E04005339606';
        RestContext.request = new RestRequest();
        RestContext.request.params.put('LoyaltyId','E04005339605');
        RestContext.request.params.put('BrandId', '2');
        RestContext.response= res;
        SFCCActiveRewards.doFetch();
        test.stopTest();
        Assert.areEqual(res.statusCode, 200);
    }
    public static testmethod void testdoFetch2(){
        test.startTest();        
        RestResponse res = new RestResponse();
        string url='E04005339606';
        RestContext.request = new RestRequest();
        RestContext.request.params.put('LoyaltyId','');
        RestContext.request.params.put('BrandId', 'E04005339606');
        RestContext.response= res;
        SFCCActiveRewards.doFetch();
        test.stopTest();
        Assert.areEqual(res.statusCode, 400);
    }
    
}