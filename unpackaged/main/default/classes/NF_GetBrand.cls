public with sharing class NF_GetBrand {

        public class Input{
            @InvocableVariable(required=true)
            public String chatKey;


        }
        public class Output{
            @InvocableVariable(required=true)
            public String brandName;

            @InvocableVariable(required=true)
            public String brandEmail;

            @InvocableVariable(required=true)
            public String brandPhone;

            @InvocableVariable(required=true)
            public String brandId;

            @InvocableVariable(required=true)
            public String shippingQuestionsURL;

            @InvocableVariable(required=true)
            public String returnQuestionsURL;

            @InvocableVariable(required=true)
            public String covidURL;

            @InvocableVariable(required=true)
            public String promotionsURL;

            @InvocableVariable(required=true)
            public String latestFashionsURL;

            @InvocableVariable(required=true)
            public String returnsURL;

            @InvocableVariable(required=true)
            public String orderStatusURL;
        }

        @InvocableMethod(label='Neuraflash - Get Brand Name')
        public static List<Output> getBrandName(List<Input> input){
            List<Output> result = new List<Output>();
            String chatKey = input[0].chatKey;
            Output out = new Output();

            System.debug('>>NF_Util.getLiveChatTranscript chatKey is ' + chatKey);

            if(String.isEmpty(chatKey)){
                System.debug('>>NF_Util.getLiveChatTranscript Cannot find LiveChatTranscript, chatKey is empty');
                return null;
            }

            List<LiveChatTranscript> listTranscripts = new List<LiveChatTranscript>();

            try {
                listTranscripts = [SELECT Id, URL__c, Brand__c
                FROM LiveChatTranscript
                WHERE ChatKey = :chatKey];
            }
            catch(Exception e){
                System.debug('Exception encountered: ' + e);
            }



            LiveChatTranscript transcript = listTranscripts.size() > 0 ? listTranscripts[0] : null;

            if(transcript != null){
                if (String.isBlank(transcript.URL__c))
                    transcript.URL__c = 'https://external.neuraflash.com/PVH/ChatWindows/CK/HolidayDev/CK-sf_iframe.html?';
                System.debug(transcript.URL__c);
                Brand_Setting__mdt brandSetting = NF_Util.getBrandName(transcript.URL__c);
                out.shippingQuestionsURL = brandSetting.Shipping_Questions_URL__c;
                out.promotionsURL = brandSetting.Promotions_URL__c;
                out.latestFashionsURL = brandSetting.Product_Questions_URL__c;
                out.covidURL = brandSetting.Covid_URL__c;
                out.returnQuestionsURL = brandSetting.Return_Questions_URL__c;
                out.returnsURL =  brandSetting.Return_URL__c;
                out.brandName = brandSetting.Label;
                out.brandId = brandSetting.Id;
                out.brandEmail = brandSetting.Brand_Email__c;
                out.brandPhone = brandSetting.Brand_Phone__c;
                out.orderStatusURL = brandSetting.Order_Status_URL__c;

                transcript.Brand__c = brandSetting.Label;
                update transcript;

            }
            else{
                System.debug('>>NF_GetBrand Name  failed to retrieve LiveChatTranscript');
            }
            result.add(out);
            System.debug(result.toString());
            return result;
        }
}