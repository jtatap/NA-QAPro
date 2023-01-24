/**
 * Created by apoorvrajput on 9/12/20.
 */

public with sharing class NF_GetFormattedLink {
    public class Input{
        @InvocableVariable(required=true)
        public String chatKey;

        @InvocableVariable(required=false)
        public String email;

        @InvocableVariable(required=false)
        public String orderId;

        @invocableVariable(required=false)
        public String orderZip = '';

        @InvocableVariable(required=true)
        public String linkType;
        
        @InvocableVariable(required=false)
        public String brand;

        @InvocableVariable(required=false)
        public String baseURL;
    }
    public class Output{
        @InvocableVariable(required=true)
        public String formattedLink;
    }

    @InvocableMethod(label='Neuraflash - Get Formatted link')
    public static List<Output> getBrandName(List<Input> input){
        List<Output> result = new List<Output>();
        String chatKey = input[0].chatKey;
        Output out = new Output();

        System.debug('>>NF_Util.getLiveChatTranscript chatKey is ' + chatKey);

        String EZtoEncode = 'orderEmail=' + input[0].email + '&orderShippingZipCode=' + input[0].orderZip;
        Blob blobtoEncode = Blob.valueOf(EZtoEncode);
        String encodedEZ = EncodingUtil.base64encode(blobToEncode);

        if(String.isEmpty(chatKey)){
            System.debug('>>NF_Util.getLiveChatTranscript Cannot find LiveChatTranscript, chatKey is empty');
            return null;
        }
        if(input[0].linkType == 'OrderStatus') {
            // if (input[0].brand == 'Tommy Hilfiger') {
            //     out.formattedLink = input[0].baseURL + '&orderId=' + input[0].orderId + '&emailAddress=' + input[0].email; //'&orderEmail=' + input[0].email;
            // } else {                
            out.formattedLink = input[0].baseURL + '?orderID=' + input[0].orderId + '&orderTrackToken=' + encodedEZ + '&track=true';
            //}
            //out.formattedLink = input[0].baseURL + '&orderId=' + input[0].orderId + '&orderEmail=' + input[0].email + '&orderZip=' + input[0].orderZip + '&track=true';
        } else
                out.formattedLink = input[0].baseURL + '?order=' +input[0].orderId +'&email='+ input[0].email + '&init=true';
        result.add(out);
        System.debug(result.toString());
        return result;
    }
    //https://www.calvinklein.us/GuestTrackOrderStatus?authToken=67470865%252CmZ1fPXeqfRiqjgCjRMhMwUqX9AkRLKrK6mP%252FFvU2tmE%253D&storeId=10751&langId=-1&catalogId=12101&orderId=52341179&emailAddress=keithrivela%40pvh.com

}