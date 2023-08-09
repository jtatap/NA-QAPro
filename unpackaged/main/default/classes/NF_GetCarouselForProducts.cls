/**
 * Created by apoorvrajput on 9/28/20.
 */

public with sharing class NF_GetCarouselForProducts {


    // payloadCard = '<div class = \'carousel\'> <div class=\'Rectangle\'><div class = \'-Oak-Street text-style-1\' ><b>Order #' + order.orderNumber + '</b><br>Placed on ' + order.orderDate.month + '/' + order.orderDate.day + '/' + order.orderDate.year + '  </div><div class = \'ColumnContainer slds-grid\' style=\'margin-bottom: 0.5rem !important; margin-top: 0.5rem !important;\'><div class = \'Total-items-2 slds-col\'><span>Total Items: <b>' + items + '</b><br>' + imageHTMLCompiled + '</span></div><div class=\'Total-items-2 slds-col\'><span>Order Total: <b>' + order.orderSummary.orderTotal + '</span></b></div></div>' + '</div>' + '<div class=\'Lorem-ipsum-dolor-si\'><div class= \'text-style-1\'> Status: ' + shipment.status.capitalize() + ' on ' +  shipment.statusDate.month + '/' + shipment.statusDate.day+ '/' + shipment.statusDate.year+ '</div><div> Estimated Delivery:' + deliveryDate + '</div> </div><div> ' + shipmentButton + '</div><br>' + orderDetailsButton + '</div></div>';

    public class Input{
        @InvocableVariable(required=true)
        public String chatKey;

        @InvocableVariable(required=true)
        public String brandName;
    }
    @InvocableMethod(label='Neuraflash - Get Carousal for Products')
    public static void getResponse(List<Input> input){
        String payloadCard = '' ;
        if (input[0].brandName == SYSTEM.LABEL.Calvin_Klein) {
            payloadCard = '<div class = \'carousel\'> <div class=\'Rectangle\'><table class=\'productsTable\'><tbody><tr><td style=\'text-align:center\'><a href=\'https://www.calvinklein.us/en/womens-clothing/womens-apparel/womens-shop-all?ab=homepage_desktop_1\'>Womens</a></td></tr><tr><td style=\'text-align:center\'><a href=\'https://www.calvinklein.us/en/mens-clothing/mens-apparel/mens-shop-all?ab=homepage_desktop_2\'>Mens</a></td></tr><tr><td style=\'text-align:center\'><a href=\'https://www.calvinklein.us/en/kids-clothing\'>Kids</a></td></tr><tr><td style=\'text-align:center\'><a href=\'https://www.calvinklein.us/en/underwear\'>Underwear</a></td></tr><tr><td style=\'text-align:center\'><a href=\'https://www.calvinklein.us/en/home-decor-collection\'>Home</a></td></tr></tbody></table></div></div>';
        }
        else {
            payloadCard = '<div class = \'carousel\'> <div class=\'Rectangle\'><table class=\'productsTable\'><tbody><tr><td style=\'text-align:center\'><a href=\'https://usa.tommy.com/en/all-women-clothing-and-accessories?icid=1.2-women_s_clothing_accessories-splash-desktop-20200902\'>Womens</a></td></tr><tr><td style=\'text-align:center\'><a href=\'https://usa.tommy.com/en/all-men-clothing-and-accessories?icid=1.1-men_s_clothing_accessories-splash-desktop-20200902\'>Mens</a></td></tr><tr><td style=\'text-align:center\'><a href=\'https://usa.tommy.com/en/kids-all?icid=1.3-kids_clothing_accessories-splash-desktop-20200902\'>Kids</a></td></tr><tr><td style=\'text-align:center\'><a href=\'https://usa.tommy.com/en/home\'>Home</a></td></tr><tr><td style=\'text-align:center\'><a href=\'https://usa.tommy.com/en/tommy-jeans\'>Tommy Jeans</a></td></tr><tr><td style=\'text-align:center\'><a href=\'https://usa.tommy.com/en/tommy-hilfiger-sale\'>Sale</a></td></tr></tbody></table></div></div>';
        }

        // append the data to the bot session for carousal

        String finalDynamicPayload = '{"home":1,"cards":['+'\"' + payloadCard + '\"'+']}';

        //String finalDynamicPayload = '{"home":1,"cards":["<p>test</p>"]}';
        ebotdata__Bot_Session__c session = NF_Util.getBotSession(input[0].chatKey);
        if (session != null) {
            session.CarouselContent__c = finalDynamicPayload;
            update session;
        }
        else {
            Log.push('session not found');
            NF_Util.insertSession(input[0].chatKey,finalDynamicPayload, input[0].brandName);
            Logger.logDebug();
        }
    }

}