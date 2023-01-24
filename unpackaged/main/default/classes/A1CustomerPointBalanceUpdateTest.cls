@isTest
public class A1CustomerPointBalanceUpdateTest{
    public static testmethod void testdoupdatemethodwithLoyaltyId(){
        Contact c = new Contact( Lastname = 'testlastname',LoyaltyId__c= 'TH4005340161',Brand_Id__c = '2' );
        
        insert c;
        Contact c1 = new Contact();
        c1.LastName = 'lastname1';
        c1.LoyaltyId__c ='TH4005340163';
        c1.Brand_Id__c ='4';
        insert c1;
        String JSONMsg = '{'+
            '    \"Count\": \"2\",'+
            '    \"Subscribers\": ['+
            '        {'+
            '            \"BrandId\": \"2\",'+
            '            \"balancepoints\": \"200\",'+
            '            \"LoyaltyId\": \"TH4005340163\"'+
            '  '+
            '},'+
            '        {'+
            '             \"BrandId\": \"2\",'+
            '            \"balancepoints\": \"200\",'+
            '            \"LoyaltyId\": \"1222\"'+
            '  '+
            '        }'+
            '    ]'+
            '}';
        // string JSONMsg='{{ "Count": "2", "Subscribes": [ {"BrandId": "2","balancepoints": "200","LoyaltyId": "",}, {"BrandId": "2","balancepoints": "200","LoyaltyId": "",}]}';
        test.startTest();
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        request.requestUri ='/services/apexrest/A1subscribers/pointBalance/';
        request.httpMethod = 'POST';
        request.requestBody=Blob.valueof(JSONMsg);
        RestContext.request = request;
        RestContext.response= res;
        A1CustomerPointBalanceUpdate.doUpdate();
        test.stopTest();
       
    }
    public static testmethod void testdoupdatemethodWithoutLoyaltyId(){
        Contact c = new Contact( Lastname = 'testlastname',LoyaltyId__c= 'TH4005340161',Brand_Id__c = '2' );
        
        insert c;
        Contact c1 = new Contact();
        c1.LastName = 'lastname1';
        c1.LoyaltyId__c ='TH4005340163';
        c1.Brand_Id__c ='4';
        insert c1;
        String JSONMsg = '{'+
            '    \"Count\": \"2\",'+
            '    \"Subscribers\": ['+
            '        {'+
            '            \"BrandId\": \"2\",'+
            '            \"balancepoints\": \"200\",'+
            '            \"LoyaltyId\": \"\"'+
            '  '+
            '},'+
            '        {'+
            '             \"BrandId\": \"2\",'+
            '            \"balancepoints\": \"200\",'+
            '            \"LoyaltyId\": \"\"'+
            '  '+
            '        }'+
            '    ]'+
            '}';
        // string JSONMsg='{{ "Count": "2", "Subscribes": [ {"BrandId": "2","balancepoints": "200","LoyaltyId": "",}, {"BrandId": "2","balancepoints": "200","LoyaltyId": "",}]}';
        test.startTest();
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        request.requestUri ='/services/apexrest/A1subscribers/pointBalance/';
        request.httpMethod = 'POST';
        request.requestBody=Blob.valueof(JSONMsg);
        RestContext.request = request;
        RestContext.response= res;
        A1CustomerPointBalanceUpdate.doUpdate();
        test.stopTest();
       
    }
    
}