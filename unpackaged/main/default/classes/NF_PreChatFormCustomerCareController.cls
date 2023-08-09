/**
 * Created by mcasella on 9/11/20.
 */

 public with sharing class NF_PreChatFormCustomerCareController {
    @AuraEnabled
    public static String checkAgentAvailable(){
        // metadata check
        return  'true' ;
    }

    @AuraEnabled
    public static String getBrand(String url){
        Brand_Setting__mdt b = NF_Util.getBrandName(url);
        return (b.Label == 'Tommy Hilfiger'  ?  'Tommy Hilfiger'  :  'Calvin Klein');

    }
}