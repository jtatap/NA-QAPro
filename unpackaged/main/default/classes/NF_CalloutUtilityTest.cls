/**
 * @description       : Test class for NF_CalloutUtility
 * @author            : chayan.batabyal@neuraflash.com
 * @last modified on  : 09-10-2021
 * @last modified by  : chayan.batabyal@neuraflash.com
**/
@isTest(seeAllData = false)
public class NF_CalloutUtilityTest {
    /**
    * @description Covers the positive and negative scenarios of docallout method
    * @author chayan.batabyal@neuraflash.com | 09-10-2021
    * @return testMethod
    **/
    public static testMethod void doCalloutTest(){
        Boolean catchAssert = false;

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, 'OK', '{"token": ""}', null));
        HttpResponse response = NF_CalloutUtility.doCallout(
            'endpoint', 'GET', 2000,
            new Map<String, Object>{'test' => 'test'},
            'body', 200, true
        );
        System.assertEquals(200, response.getStatusCode());

        try{
            response = NF_CalloutUtility.doCallout(
                'endpoint', 'GET', null,
                new Map<String, Object>{'test' => 'test'},
                'body', 200, true
            );
        }
        catch(NF_CalloutUtility.CalloutException e){
            System.assertEquals('Error in configuations, please check metadata record', e.getMessage());
            catchAssert = true;
        }
        System.assert(catchAssert);

        catchAssert = false;
        try{
            response = NF_CalloutUtility.doCallout(
                'endpoint', 'GET', 2000,
                new Map<String, Object>{'test' => 'test'},
                'body', 100, true
            );
        }
        catch(NF_CalloutUtility.CalloutException e){
            System.assertEquals('Response is not as expected', e.getMessage());
            catchAssert = true;
        }
        System.assert(catchAssert);

        Test.stopTest();
    }
}