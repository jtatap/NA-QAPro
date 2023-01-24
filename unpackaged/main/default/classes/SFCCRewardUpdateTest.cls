@isTest
public class SFCCRewardUpdateTest {
    public static testmethod void testdoFetch(){
        String jsonStr = '{'+
            '  \"BrandId\": \"2\",'+
            '  \"LoyaltyId\": \"C0000000001\",'+
            '  \"Status\": \"Active\",'+
            '  \"RewardId\":[\"1621080000000C000000000117\",\"1621080000000C000000000118\",\"1621080000000C000000000119\" '+
            '  ],'+
            '  \"OperationType\": \"Cancelled\",'+
            '  \"OrderId\": \"\"'+
            '}';
        test.startTest();
        Reward__c objRew=new Reward__c();
        objRew.LoyaltyId__c='C0000000001';
        objRew.Status__c='Pending Redeemed';
        objRew.RewardId__c='1621080000000C000000000117';
        insert objRew;
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        request.requestUri ='/services/apexrest/SFCCRewards/Update/';
        request.httpMethod = 'POST';
        request.requestBody=Blob.valueof(JSOnStr);
        RestContext.request = request;
        RestContext.response= res;
        SFCCRewardUpdate.doUpdate();
        test.stopTest();
    }
    public static testmethod void testErrorInvalidBrand(){
        String jsonStr = '{'+
            '  \"BrandId\": \"3\",'+
            '  \"LoyaltyId\": \"C0000000001\",'+
            '  \"Status\": \"Active\",'+
            '  \"RewardId\":[\"1621080000000C000000000117\",\"1621080000000C000000000118\",\"1621080000000C000000000119\" '+
            '  ],'+
            '  \"OperationType\": \"Cancelled\",'+
            '  \"OrderId\": \"\"'+
            '}';
        test.startTest();
        Reward__c objRew=new Reward__c();
        objRew.LoyaltyId__c='C0000000001';
        objRew.Status__c='Pending Redeemed';
        objRew.RewardId__c='1621080000000C000000000117';
        insert objRew;
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        request.requestUri ='/services/apexrest/SFCCRewards/Update/';
        request.httpMethod = 'POST';
        request.requestBody=Blob.valueof(JSOnStr);
        RestContext.request = request;
        RestContext.response= res;
        SFCCRewardUpdate.doUpdate();
        test.stopTest();
    }
    public static testmethod void testErrorEmptyValues(){
        String jsonStr = '{'+
            '  \"BrandId\": \"2\",'+
            '  \"LoyaltyId\": \"\",'+
            '  \"Status\": \"Active\",'+
            '  \"RewardId\":[\"1621080000000C000000000117\",\"1621080000000C000000000118\",\"1621080000000C000000000119\" '+
            '  ],'+
            '  \"OperationType\": \"Cancelled\",'+
            '  \"OrderId\": \"\"'+
            '}';
        test.startTest();
        Reward__c objRew=new Reward__c();
        objRew.LoyaltyId__c='C0000000001';
        objRew.Status__c='Pending Redeemed';
        objRew.RewardId__c='1621080000000C000000000117';
        insert objRew;
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        request.requestUri ='/services/apexrest/SFCCRewards/Update/';
        request.httpMethod = 'POST';
        request.requestBody=Blob.valueof(JSOnStr);
        RestContext.request = request;
        RestContext.response= res;
        SFCCRewardUpdate.doUpdate();
        test.stopTest();
    }
}