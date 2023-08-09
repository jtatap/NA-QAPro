/******************************************************************************
* @Description: Test class for A1_bcryptkey
* @Author	  : PVH
* @Date		  : 30:11.2022
******************************************************************************/ 
@isTest
public class A1_bcryptkeyTest {
    
  public static testmethod void testdoFetch(){
        test.startTest();
        string appName='DWTracker';
        string BrandId='1';
        List<A1_TrackerAPI_tokens__mdt> bcryptToken =[Select BrandId__c,ApplicationID__c,AppName__c,access_key__c,access_token__c,key_expires_at__c,token_expires_at__c,token_expires_in__c	from A1_TrackerAPI_tokens__mdt where BrandId__c='1' AND AppName__c='DWTracker'];
        RestResponse res = new RestResponse();
        string url='DWTracker';
        RestContext.request = new RestRequest();
        RestContext.request.params.put('appName','DWTracker');
        RestContext.request.params.put('brandId', '1');
        RestContext.response= res;
        A1_bcryptkey.doFetch();
        test.stopTest();
    }
  
    public static testmethod void testdoFetch1(){
        test.startTest();
        string appName='DWTracker';
        string BrandId='2';
        List<A1_TrackerAPI_tokens__mdt> bcryptToken =[Select BrandId__c,ApplicationID__c,AppName__c,access_key__c,access_token__c,key_expires_at__c,token_expires_at__c,token_expires_in__c from A1_TrackerAPI_tokens__mdt where BrandId__c='1' AND AppName__c='DWTracker'];
        RestResponse res = new RestResponse();
        string url='DWTracker';
        RestContext.request = new RestRequest();
        RestContext.request.params.put('appName','DWTracker');
        RestContext.request.params.put('brandId', '2');
        RestContext.response= res;
        A1_bcryptkey.doFetch();
        test.stopTest();
    }
     public static testmethod void testdoFetch2(){
        test.startTest();
        string appName='DWTracker';
        string BrandId='5';
        List<A1_TrackerAPI_tokens__mdt> bcryptToken =[Select BrandId__c,ApplicationID__c,AppName__c,access_key__c,access_token__c,key_expires_at__c,token_expires_at__c,token_expires_in__c from A1_TrackerAPI_tokens__mdt where BrandId__c='1' AND AppName__c='DWTracker'];
        RestResponse res = new RestResponse();
        string url='DWTracker';
        RestContext.request = new RestRequest();
        RestContext.request.params.put('appName','DWTracker');
        RestContext.request.params.put('brandId', '5');
        RestContext.response= res;
        A1_bcryptkey.doFetch();
        test.stopTest();
    }
    public static testmethod void testdoFetch3(){
        test.startTest();
        string appName='DWTracker';
        string BrandId='5';
        List<A1_TrackerAPI_tokens__mdt> bcryptToken =[Select BrandId__c,ApplicationID__c,AppName__c,access_key__c,access_token__c,key_expires_at__c,token_expires_at__c,token_expires_in__c from A1_TrackerAPI_tokens__mdt where BrandId__c='1' AND AppName__c='DWTracker'];
        RestResponse res = new RestResponse();
        string url='DWTracker';
        RestContext.request = new RestRequest();
        RestContext.request.params.put('appName','DWTracker');
        //RestContext.request.params.put('brandId', '5');
        RestContext.response= res;
        A1_bcryptkey.doFetch();
        test.stopTest();
    }
}