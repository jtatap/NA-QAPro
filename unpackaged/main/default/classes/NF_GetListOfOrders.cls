/**
 * Created by samuel on 10/7/20.
 */

public without sharing class NF_GetListOfOrders {
    public class Input {
        /**
         * THIS MIGHT NOT BE NECESSARY, IF ORDER INFORMATION IS PROVIDED BY PVH
         * LIST OF ORDERS CAN THEN BE COMPILED INTO ONE STRING HERE, WITH HANDLER RECEIVING DIFFERENT ORDER NUMBER
         * FOR EACH MINICARD
         */

        @InvocableVariable(Required=false)
        public String chatKey;

        @InvocableVariable(Required=false)
        public String customerId;

        @InvocableVariable(Required=false)
        public String orderId;

        @InvocableVariable(Required=false)
        public String orderNumber;

        @InvocableVariable(Required=false)
        public String brandName;

        @InvocableVariable(Required=false)
        public String email;

        @InvocableVariable(Required=false)
        public String formattedStatusLink;
    }
    public class Output {
        @InvocableVariable(Required=false)
        public Integer numberOfOrders = 0;

        @InvocableVariable(Required=false)
        public String dynamicPayloadName;

        @InvocableVariable(Required=false)
        public String cancellationStatus;

        @InvocableVariable(Required=false)
        public Boolean orderAPI_error = false;
    }

    private String endpoint = 'https://narvar.com/tracking/itemvisibility/v1/{retailer}/orders/{orderNumber}'; //'https://narvar.com/api/v2/orders/tracking?retailer_moniker=:PVH';
    private static String secretKey = '';
    private static String retailer_moniker = '';
    private static String resourcePathBrand = '';

    @InvocableMethod (Label = 'NeuraFlash - Get List of Orders')
    public static List<Output> getListOfOrders(List<Input> inputs) {

        Input input = inputs[0];
        Output out = new Output();

        // Get Resource URL
        Site[] mySite = [select Id from Site where Name = 'PVH'];

        String resourceBaseURL = '';

        if (mySite.size() > 0) {
            SiteDetail[] mySiteDetail = [select SecureURL from SiteDetail where DurableId = :mySite[0].Id];
            if (mySiteDetail.size() > 0)
                resourceBaseURL = mySiteDetail[0].SecureURL;
        }
        System.debug('>>> Site Resource URL: ' + resourceBaseURL);

        ebotdata__Bot_Session__c[] botSessionToUpdate = [
                SELECT Id, ebotdata__Live_Agent_Session_Id__c, MinicardPayload__c
                FROM ebotdata__Bot_Session__c
                WHERE ebotdata__Live_Agent_Session_Id__c =: input.chatKey
        ];

        Boolean realItemsFound = false; // Check for if a *real* item was found, to counteract Narvar's "ghost" shipments


        switch on input.brandName {
            when 'Calvin Klein' {
                retailer_moniker = 'calvinklein2';
                resourcePathBrand = 'CK';
            }
            when 'Tommy Hilfiger' {
                retailer_moniker = 'tommy2';
                resourcePathBrand = 'TH';
            }
            when 'Speedo' {
                retailer_moniker = 'speedo1';
                resourcePathBrand = 'PB';
            }
            when else {
                retailer_moniker = 'partnerbrands1';
                resourcePathBrand = 'PB';
            }
        }

        System.debug('>> Email: ' + input.email);
        System.debug('>> Order #:' + input.orderNumber);

        String response = callNarvarOrderAPI(retailer_moniker, input.orderNumber, input.email);

        NF_NarvarOrderResponse orderResponse; //= new NF_NarvarOrderResponse();

        try {
            orderResponse = NF_NarvarOrderResponse.parse(response); //NF_NarvarOrderResponse) JSON.deserialize(response, NF_NarvarOrderResponse.class);
            System.debug(response);
            System.debug(orderResponse.toString());
            System.debug('API response extracted: ' + orderResponse.order_info.shipments.size() + ' shipments found');
        }
        catch (Exception e){
            System.debug('ERROR EXTRACTING API RESPONSE');
            System.debug(' >> ' + e.getMessage() + ', ' + e.getLineNumber());
            System.debug(' >> ' + e.getCause());
            System.debug(' >> ' + e.getStackTraceString());
            System.debug(response);
            out.orderAPI_error = true;
            return new List<Output>{out};
        }

        /**
         * Populate bot session MinicardPayload__c with minicards, separated by TrackingNumber
         */

        if (orderResponse.isError()) {
            out.numberOfOrders = 0;
            out.orderAPI_error = true;
            return new List<Output>{out};
        }

        if (botSessionToUpdate.size() > 0) {

            NF_NarvarOrderResponse.Order_info orderInfo = orderResponse.order_info;
            List<NF_NarvarOrderResponse.Tracking_info> trackingInfo = orderResponse.tracking_info;
            List<NF_NarvarOrderResponse.order_items> orderItems = orderResponse.order_info.order_items;
            List<NF_NarvarOrderResponse.Shipments> shipments = orderResponse.order_info.shipments;

            List<NF_NarvarOrderResponse.Shipments> shipmentsAlreadyScanned = new List<NF_NarvarOrderResponse.Shipments>{};    // To verify against previously scanned items

            NF_MinicardBuilder mcb = new NF_MinicardBuilder();

            // Start by reversing the shipments array, so more 'complete' shipments are read first
            //List<NF_NarvarOrderResponse.Shipments> reversedShipments = shipments;
            /*for (Integer i = 0; i < shipments.size(); i++) {
                NF_NarvarOrderResponse.Shipments temp = shipments[i];
                shipments[i] = shipments[shipments.size()-1 - i];
                shipments[shipments.size()-1 - i] = temp;
            }*/

            Integer shipmentNumber = 0;
            for (NF_NarvarOrderResponse.Shipments shipment : shipments) {
                System.debug('===== SHIPMENT #' + (++shipmentNumber) + ' FOUND (Status: ' + shipment.status + ') =====');
                System.debug(shipment.toString());
                if (!(shipment.status == 'SHIPPED' || shipment.status == 'JUSTSHIPPED' || shipment.status == 'PRESHIPMENT0' || shipment.status == 'INTRANSIT' || shipment.status == 'NOT_SHIPPED' || shipment.status == 'CANCELLED' || shipment.status == 'DELIVERED')) {
                    System.debug('>>> Shipment status not found');
                    continue;
                }
                NF_MinicardBuilder.NF_Minicard newCard = mcb.addMinicard();

                String thisShipmentVerbiage = 'contains';
                Boolean trackingLinkAvailable = true;

                switch on shipment.status {
                    when 'SHIPPED', 'INTRANSIT' {
                        System.debug('===== SHIPMENT # ' + shipmentNumber + ' Shipment in transit');
                        newCard.setTitle(NF_MinicardBuilder.bold('Status: Shipped'));
                        //newCard.setImageURL(URL.getSalesforceBaseUrl().toExternalForm()+'/pvh/resource/NF_Minicard_Resources/' + resourcePathBrand + '/shipping_truck.svg');
                        newCard.setImageURL(resourceBaseURL + '/resource/NF_Minicard_Resources/' + resourcePathBrand + '/clock.svg');
                        thisShipmentVerbiage = 'contains';
                    }
                    when 'JUSTSHIPPED', 'PRESHIPMENT0' {
                        System.debug('===== SHIPMENT # ' + shipmentNumber + ' Shipment in \'pre-shipment\' state');
                        newCard.setTitle(NF_MinicardBuilder.bold('Status: Just Ordered'));
                        //newCard.setImageURL(URL.getSalesforceBaseUrl().toExternalForm()+'/pvh/resource/NF_Minicard_Resources/' + resourcePathBrand + '/clock.svg');
                        newCard.setImageURL(resourceBaseURL + '/resource/NF_Minicard_Resources/' + resourcePathBrand + '/clock.svg');
                        thisShipmentVerbiage = 'contains';
                        trackingLinkAvailable = false;
                    }
                    when 'NOT_SHIPPED' {
                        System.debug('===== SHIPMENT # ' + shipmentNumber + ' Shipment not shipped');
                        newCard.setTitle(NF_MinicardBuilder.bold('Status: Not Shipped'));
                        //newCard.setImageURL(URL.getSalesforceBaseUrl().toExternalForm()+'/pvh/resource/NF_Minicard_Resources/' + resourcePathBrand + '/clock.svg');
                        newCard.setImageURL(resourceBaseURL + '/resource/NF_Minicard_Resources/' + resourcePathBrand + '/clock.svg');
                        thisShipmentVerbiage = 'contains';
                    }
                    when 'DELIVERED' {
                        System.debug('===== SHIPMENT # ' + shipmentNumber + ' Shipment delivered');
                        newCard.setTitle(NF_MinicardBuilder.bold('Status: Delivered'));
                        //newCard.setImageURL(URL.getSalesforceBaseUrl().toExternalForm()+'/pvh/resource/NF_Minicard_Resources/' + resourcePathBrand + '/clock.svg');
                        newCard.setImageURL(resourceBaseURL + '/resource/NF_Minicard_Resources/' + resourcePathBrand + '/shipping_truck.svg');
                        thisShipmentVerbiage = 'contained';
                    }
                    when 'CANCELLED' {
                        System.debug('===== SHIPMENT # ' + shipmentNumber + ' Shipment cancelled');
                        newCard.setTitle(NF_MinicardBuilder.bold('Status: Cancelled'));
                        //newCard.setImageURL(URL.getSalesforceBaseUrl().toExternalForm()+'/pvh/resource/NF_Minicard_Resources/' + resourcePathBrand + '/notification.svg');
                        newCard.setImageURL(resourceBaseURL + '/resource/NF_Minicard_Resources/' + resourcePathBrand + '/notification.svg');
                        thisShipmentVerbiage = 'contained';
                    }
                    when else {
                        System.debug('===== SHIPMENT # ' + shipmentNumber + ' Unexpected shipping status found: ' + shipment.status);
                        continue;
                    }
                }

                System.debug('===== SHIPMENT # ' + shipmentNumber + ' GETTING TRACKING URL');
                if (trackingLinkAvailable) {
                    String trackingURLforThisOrder = '';
                    if (String.isNotBlank(shipment.tracking_number)) {
                        System.debug(shipment.tracking_number);
                        for (NF_NarvarOrderResponse.Tracking_info ti : trackingInfo) {
                            if (ti.tracking_number == shipment.tracking_number)
                                trackingURLforThisOrder = ti.tracking_url;
                        }
                    }
                    newCard.addLineToTopofTitle(NF_MinicardBuilder.bold('Track it: ' + NF_MinicardBuilder.link(shipment.tracking_number, trackingURLforThisOrder)));//'https://narvar.com')));
                } else {
                    newCard.addLineToTopofTitle(NF_MinicardBuilder.bold('No tracking info yet'));
                }
                System.debug('===== SHIPMENT # ' + shipmentNumber + ' ORDER INFO');
                System.debug(orderInfo.toString());
                System.debug('===== SHIPMENT # ' + shipmentNumber + ' ORDER ITEMS');
                System.debug(orderItems.toString());

                System.debug('===== SHIPMENT # ' + shipmentNumber + ' SHIPMENT ITEMS ');
                //System.debug(shipment.items_info.toString());

                String formattedOrderDate = '';
                if (orderInfo.order_date != null) {
                    formattedOrderDate = DateTime.valueOf(orderInfo.order_date.replace('T', ' ')).date().format();
                    newCard.addLineToTitle(NF_MinicardBuilder.bold('Ordered: ' + formattedOrderDate));
                }

                Integer numItemsInThisShipment = 0;

                for (NF_NarvarOrderResponse.Items_info i : shipment.items_info) {
                    System.debug(i.toString());
                    String thisItemID = i.item_id;
                    String thisItemSku = i.sku;
                    Integer thisItemQuantity = i.quantity;

                    if (thisItemID == null) { System.debug(LoggingLevel.WARN, '!! Empty Item ID !!'); }
                    if (thisItemSku == null) {} System.debug(LoggingLevel.WARN, '!! Empty Item SKU !!');

                    if (orderInfo != null && orderItems != null) {
                        System.debug('===== SHIPMENT # ' + shipmentNumber + ' - SCANNING ORDER ITEMS <<<');

                        Boolean matchFoundThisLoop = false;

                        for (NF_NarvarOrderResponse.Order_items item : orderItems) {
                            System.debug(item.toString());
                            if ((item.item_id != null && item.item_id == thisItemID) || (item.sku != null && item.sku == thisItemSku)) { // Need extra check here for null item_id values
                                if (i.quantity > 0) {
                                    if (out.cancellationStatus == 'Total') {
                                        out.cancellationStatus = 'Partial';             // Change from 'Total' to 'Partial' cancellation if an item is found
                                    }
                                    System.debug('== Match found! Adding item to minicard description.');
                                    System.debug('== Item name:\t ' + item.name);
                                    System.debug('== Item quantity in Shipment:\t' + item.quantity);
                                    System.debug('== Item quantity in OrderItem:\t' + thisItemQuantity);
                                    if (item.quantity != thisItemQuantity) {
                                        System.debug(LoggingLevel.WARN, '!! Item quantities DO NOT MATCH !!');
                                    }
                                    realItemsFound = true;
                                    matchFoundThisLoop = true;
                                    newCard.addLineToDescription(NF_MinicardBuilder.bold(item.name.replace('"', '\\\"')) + ' x' + thisItemQuantity);//item.quantity);
                                    out.numberOfOrders++;
                                    numItemsInThisShipment++;
                                }
                            }
                        }

                        if (!matchFoundThisLoop && shipment.status == 'JUSTSHIPPED' && i.quantity == 0) {
                            System.debug('~~~~ Cancelled item found! Verifying this is not from a doppelganger shipment.'); // The API occasionally returns a duplicate shipment with quantities 0 - this logic counteracts that
                            Boolean doppelgangerFound = false;
                            for (NF_NarvarOrderResponse.Shipments verificationShipment : shipments) {
                                for (NF_NarvarOrderResponse.Items_info ii : verificationShipment.items_info) {
                                    if (i.sku == ii.sku && ii.quantity != 0) {
                                        doppelgangerFound = true;
                                        break;
                                    }
                                }
                                if (doppelgangerFound)
                                    break;
                            }

                            if (doppelgangerFound)
                                continue;

                            System.debug('~~~~ Cancelled item verified! Adding item to minicard description.');
                            newCard.setTitle(NF_MinicardBuilder.bold('Status: Cancelled'));
                            //newCard.setImageURL(URL.getSalesforceBaseUrl().toExternalForm()+'/pvh/resource/NF_Minicard_Resources/' + resourcePathBrand + '/notification.svg');
                            newCard.setImageURL(resourceBaseURL + '/resource/NF_Minicard_Resources/' + resourcePathBrand + '/notification.svg');
                            thisShipmentVerbiage = 'contained';
                            newCard.addLineToDescription(NF_MinicardBuilder.bold(i.sku.replace('"', '\\\"'))); // + ' x' + i.quantity);
                            out.numberOfOrders++;
                            numItemsInThisShipment++;

                            if (!realItemsFound && String.isBlank(out.cancellationStatus)) {
                                System.debug('~~~~ First cancelled item found, assuming full cancellation until disproven');
                                out.cancellationStatus = 'Total';                   // Assume order is fully cancelled on first 0 item, until a non-cancelled item is found
                            }                                                       // If NO 0-quantity items are found, cancellationStatus will be blank
                            continue;
                        }
                    }


                    else {
                        newCard.setDescription('We couldn\'t find any order info.');
                        break;
                    }
                }

                shipmentsAlreadyScanned.add(shipment);  // Once this shipment is done, add it to the already-scanned list

                if (numItemsInThisShipment == 0) {
                    mcb.dropMinicard(-1);
                }

                newCard.addLineToTopofDescription('This shipment ' + thisShipmentVerbiage + ':<br>');

                newCard.addLineToDescription();
                String trackingURL = input.formattedStatusLink; //'https://www.narvar.com';
                newCard.addLineToDescription('Your full order details can be found ' + NF_MinicardBuilder.link('here', trackingURL));
            }

            String minicardPayload = mcb.generatePayload();
            System.debug(minicardPayload);

            botSessionToUpdate[0].MinicardPayload__c = minicardPayload;

            System.debug('===== CANCELLATION STATUS: ' + out.cancellationStatus);

            /** Create Dynamic Payload **/
            try {
                ebcm__Dynamic_Payload__c newPayload = new ebcm__Dynamic_Payload__c();
                newPayload.ebcm__Bot_Name__c = 'Digital Assistant';
                newPayload.ebcm__RoutableId__c = input.chatKey;
                newPayload.ebcm__Dialog_Request_Payload__c = minicardPayload;
                newPayload.ebcm__Auto_Delete__c = true;
                insert newPayload;

                System.debug(newPayload.Name);

                ebcm__Dynamic_Payload__c[] payloadToGetNameFrom = [SELECT Name FROM ebcm__Dynamic_Payload__c WHERE ebcm__RoutableId__c =: input.chatKey ORDER BY CreatedDate DESC LIMIT 1];
                if (payloadToGetNameFrom.size() > 0) {
                    System.debug(payloadToGetNameFrom[0].Name);
                    out.dynamicPayloadName = payloadToGetNameFrom[0].Name;
                }

            } catch(Exception e) {
                System.debug('>> Error trying to insert Dynamic Payload!');
                System.debug('>> ' + e.getMessage());
                System.debug('>> ' + e.getStackTraceString());
            }


            update botSessionToUpdate[0];
        }
        return new List<Output>{out};
    }

    public static String callNarvarOrderAPI(String retailer, String orderNumber, String email) {

        String endpoint = 'callout:Narvar_Orders_API/' + retailer; //'callout:Narvar_API/' + retailer; //'htttps://tracking.narvar.com/tracking/itemvisibility/v1/' + retailer;
        endpoint += '/orders/' + orderNumber;
        endpoint += '?email=' + email;

        if (Test.isRunningTest()) {
            switch on orderNumber {
                when '11111111' {
                    return '{"order_info":{"order_number":"11111111","order_date":"2021-06-22T07:04:22-04:00","order_items":[{"item_id":"3074457345633000321","retailer":null,"sku":"194998027245","name":"Curve Organic Cotton Linear Logo T-Shirt","description":null,"quantity":1,"item_image":"https://shoptommy.scene7.com/is/image/ShopTommy/DW11342_650_FNT?wid=194&hei=259&fmt=jpeg&qlt=90%2c0&op_sharpen=1&resMode=trilin&op_usm=0.8%2c1.0%2c6%2c0&iccEmbed=0","item_url":"https://usa.tommy.com/en/product/curve-organic-cotton-linear-logo-t-shirt-dw11342","fulfillment_status":"SHIPPED","item_promise_date":"2021-06-25T07:04:22Z","attributes":null,"color":"ROMANTIC PINK","size":"3XL","style":null}],"shipments":[{"carrier_service_code":"UPS2D","ship_method":"Ground","items_info":[{"quantity":1,"sku":"194998027245","item_id":"3074457345633000321"}],"promise_date":"2021-06-25T07:04:22","carrier":"ups","tracking_number":"1Z6F741A0219172073","type":"shipment","status":"INTRANSIT"},{"carrier_service_code":"UPS","ship_method":"Ground","items_info":[{"quantity":0,"sku":"194998027245","item_id":"3074457345633000321"}],"promise_date":"2021-06-25T07:04:22","carrier":"ups","tracking_number":"66534104","type":"shipment","status":"JUSTSHIPPED"}],"customer":{"customer_id":""}},"tracking_info":[{"resFromDelCr":false,"trackingStatusCodes":true,"pickedByCustomer":false,"retailer_moniker":"tommy1","weight_uom":"LBS","packageCount":null,"partner_carrier_tracking_number":null,"weight":0.5,"source":"WEB","locale":"en_US","service_desc":"UPS 2nd Day Air","status":"On its way","fb_uuid":"1a07d73628834f83852bba2f411e1c04::1625234149498","status_token":"widgets_tracking_status_intransit_status","status_desc":"Departed from Facility","tracking_number":"1Z6F741A0219172073","mask_tracking_number":null,"guaranteed_delivery_date":null,"estimated_delivery_date_end":null,"estimated_delivery_date_begin":"2021-07-06 00:00:00","edd_source":"CARRIEREDD","status_code":"DP","order_number":null,"class_of_mail_code":"002","pickup_start":null,"pickup_end":null,"ship_date":"2021-07-01 00:00:00","no_eta_message":null,"tracking_status_code":"INTR","status_summary":"Departed from Facility","last_status_date":"2021-07-02 08:26:00","TrackDetail":[{"shipmentLocationType":null,"error":null,"error_code":null,"event":"Departed from Facility","event_code":"DP","event_date":"2021-07-02 08:26:00","event_city":"South Charleston","event_state":"WV","event_country_code":"US","event_date_offset":null,"track_status_code_mapping":{"track_status_code":"300","track_status_code_desc":"Picked-up by Carrier / In-Transit: General","track_status_display_token":"tracking_status_intransit_pick_carrier","track_status_bucket":"In Transit","track_status_bucket_code":"INTR","track_status_bucket_display_token":"widgets_tracking_status_intransit_status"},"track_status_code_raw":"300"},{"shipmentLocationType":null,"error":null,"error_code":null,"event":"Arrived at Facility","event_code":"AR","event_date":"2021-07-02 04:04:00","event_city":"South Charleston","event_state":"WV","event_country_code":"US","event_date_offset":null,"track_status_code_mapping":{"track_status_code":"300","track_status_code_desc":"Picked-up by Carrier / In-Transit: General","track_status_display_token":"tracking_status_intransit_pick_carrier","track_status_bucket":"In Transit","track_status_bucket_code":"INTR","track_status_bucket_display_token":"widgets_tracking_status_intransit_status"},"track_status_code_raw":"300"},{"shipmentLocationType":null,"error":null,"error_code":null,"event":"Departed from Facility","event_code":"DP","event_date":"2021-07-02 01:04:00","event_city":"Roanoke","event_state":"VA","event_country_code":"US","event_date_offset":null,"track_status_code_mapping":{"track_status_code":"300","track_status_code_desc":"Picked-up by Carrier / In-Transit: General","track_status_display_token":"tracking_status_intransit_pick_carrier","track_status_bucket":"In Transit","track_status_bucket_code":"INTR","track_status_bucket_display_token":"widgets_tracking_status_intransit_status"},"track_status_code_raw":"300"},{"shipmentLocationType":null,"error":null,"error_code":null,"event":"En Route to Delivery Location","event_code":"X6","event_date":"2021-07-01 19:09:00","event_city":"ROANOKE","event_state":"VA","event_country_code":"US","event_date_offset":null,"track_status_code_mapping":{"track_status_code":"300","track_status_code_desc":"Picked-up by Carrier / In-Transit: General","track_status_display_token":"tracking_status_intransit_pick_carrier","track_status_bucket":"In Transit","track_status_bucket_code":"INTR","track_status_bucket_display_token":"widgets_tracking_status_intransit_status"},"track_status_code_raw":"300"},{"shipmentLocationType":null,"error":null,"error_code":null,"event":"Origin Scan","event_code":"OR","event_date":"2021-07-01 19:08:00","event_city":"Roanoke","event_state":"VA","event_country_code":"US","event_date_offset":null,"track_status_code_mapping":{"track_status_code":"300","track_status_code_desc":"Picked-up by Carrier / In-Transit: General","track_status_display_token":"tracking_status_intransit_pick_carrier","track_status_bucket":"In Transit","track_status_bucket_code":"INTR","track_status_bucket_display_token":"widgets_tracking_status_intransit_status"},"track_status_code_raw":"300"},{"shipmentLocationType":null,"error":null,"error_code":null,"event":"Shipper created a label, UPS has not received the package yet.","event_code":"MP","event_date":"2021-07-01 19:08:00","event_city":null,"event_state":null,"event_country_code":null,"event_date_offset":null,"track_status_code_mapping":{"track_status_code":"300","track_status_code_desc":"Picked-up by Carrier / In-Transit: General","track_status_display_token":"tracking_status_intransit_pick_carrier","track_status_bucket":"In Transit","track_status_bucket_code":"INTR","track_status_bucket_display_token":"widgets_tracking_status_intransit_status"},"track_status_code_raw":"200"},{"shipmentLocationType":null,"error":null,"error_code":null,"event":"En Route to Delivery Location","event_code":"X6","event_date":"2021-07-01 19:05:00","event_city":null,"event_state":null,"event_country_code":null,"event_date_offset":null,"track_status_code_mapping":{"track_status_code":"300","track_status_code_desc":"Picked-up by Carrier / In-Transit: General","track_status_display_token":"tracking_status_intransit_pick_carrier","track_status_bucket":"In Transit","track_status_bucket_code":"INTR","track_status_bucket_display_token":"widgets_tracking_status_intransit_status"},"track_status_code_raw":"300"}],"errors":null,"carrier_name":"UPS","carrier_url":"https://www.ups.com/content/us/en/contact/index.html","carrier_id":"ups","partner_carrier_name":null,"partner_carrier_url":null,"partner_carrier_id":null,"carrier_transfer":false,"service_start_day":0,"service_end_day":0,"carrier_holidays":null,"tracking_url":"https://wwwapps.ups.com/WebTracking/track?track=yes&trackNums=1Z6F741A0219172073&loc=en_US","narvar_status":"INTRANSIT","undeliverable":false,"package_redirect":null,"ship_by_date":null,"pickup_date":null,"is_label_cancelled":false,"sms_signed_up":false,"fb_messenger_signed_up":false,"generic_tracking":false,"promise_date_begin":null,"promise_date_end":null,"track_Url_Tracking_Id":"1Z6F741A0219172073","redirect_to_hold":{"eligible":false,"redirect_request_number":null,"package_identifier":null,"has_nearby_locations":true,"scheduled":false,"confirmation_number":null,"store_details":null},"is_tracking_status_codes":true,"schedulable":{"is_schedulable":false,"reason":null,"is_reschedulable":false,"is_scheduled":false,"is_schedulable_later":false,"is_schedulable_api":false,"eligibility_status":null,"eligibility_message":null},"redirect_address":null,"slug":"ups","broadcast_messages":null,"signature":null,"is_picked_by_customer":false,"is_internal_carrier":false,"pickup_by_date":null,"delivery_instructions":null,"polling":null,"stops":null,"delivery_management_link":"https://www.ups.com/us/en/services/tracking/mychoice.page","line_package_subscription_text":"c0720176e6e8742cf3ca707b9ec8995e69717c415e8f67c30cc3588f1d830865d083515237e8d48e0917aa484366dda56b5d74f74fbe9c3c3c28454d04c4eaa4dff4430f8a8eca59f62723ab104a90bc26264fd5a71cfb6c8338ee0d2855fc1357fcf0f68dcaa9dcb5c65d9901a993ee36861bf328d2d0a382b26095573af6f0efee7abef2dfda9ce9bc39c9e7e66b3dc437d60d23656ca4c6387a2"},{"resFromDelCr":false,"trackingStatusCodes":true,"pickedByCustomer":false,"retailer_moniker":"tommy1","weight_uom":null,"packageCount":null,"partner_carrier_tracking_number":null,"weight":null,"source":"WEB","locale":"en_US","service_desc":null,"status":"Awaiting Carrier Pickup","fb_uuid":"7c103f707563474889bf496490785277::1625234149540","status_token":"widgets_tracking_status_justshipped_status","status_desc":null,"tracking_number":"66534104","mask_tracking_number":null,"guaranteed_delivery_date":null,"estimated_delivery_date_end":null,"estimated_delivery_date_begin":null,"edd_source":"STALEEDDMSG","status_code":null,"order_number":null,"class_of_mail_code":null,"pickup_start":null,"pickup_end":null,"ship_date":null,"no_eta_message":null,"tracking_status_code":"SHPD","status_summary":null,"last_status_date":null,"TrackDetail":[],"errors":null,"carrier_name":"UPS","carrier_url":"https://www.ups.com/content/us/en/contact/index.html","carrier_id":"ups","partner_carrier_name":null,"partner_carrier_url":null,"partner_carrier_id":null,"carrier_transfer":false,"service_start_day":0,"service_end_day":0,"carrier_holidays":null,"tracking_url":"https://wwwapps.ups.com/WebTracking/track?track=yes&trackNums=66534104&loc=en_US","narvar_status":"JUSTSHIPPED","undeliverable":false,"package_redirect":null,"ship_by_date":null,"pickup_date":null,"is_label_cancelled":false,"sms_signed_up":false,"fb_messenger_signed_up":false,"generic_tracking":false,"promise_date_begin":null,"promise_date_end":null,"track_Url_Tracking_Id":null,"redirect_to_hold":{"eligible":false,"redirect_request_number":null,"package_identifier":null,"has_nearby_locations":true,"scheduled":false,"confirmation_number":null,"store_details":null},"is_tracking_status_codes":true,"schedulable":{"is_schedulable":false,"reason":null,"is_reschedulable":false,"is_scheduled":false,"is_schedulable_later":false,"is_schedulable_api":false,"eligibility_status":null,"eligibility_message":null},"redirect_address":null,"slug":"ups","broadcast_messages":null,"signature":null,"is_picked_by_customer":false,"is_internal_carrier":false,"pickup_by_date":null,"delivery_instructions":null,"polling":null,"stops":null,"delivery_management_link":"https://www.ups.com/us/en/services/tracking/mychoice.page","line_package_subscription_text":"c072017514a8c0befade0da93604b0e54c246387b612c3f45b02ec108a87db7d61e56cd77389008115b047026d3bf5e917f33cddc7835a843ce1d805d33b5328f634964412e7dfca6e8ca1169eca0a2a5a41a26b390757646c8df826187e7c5ad8615456559bd1ae913ea8c616abbf056eae6ea556ab9ac5b64f247c5edba0bfa0c15304ca11ec51f0d8194"}],"invalid_item_vis_request":false,"status":"SUCCESS","messages":[{"code":"response.status.success"}]}';
                }
                when '22222222' {
                    return '{"order_info":{"order_number":"22222222","order_date":"2021-06-22T07:04:22-04:00","order_items":[{"item_id":"3074457345633000321","retailer":null,"sku":"194998027245","name":"Curve Organic Cotton Linear Logo T-Shirt","description":null,"quantity":1,"item_image":"https://shoptommy.scene7.com/is/image/ShopTommy/DW11342_650_FNT?wid=194&hei=259&fmt=jpeg&qlt=90%2c0&op_sharpen=1&resMode=trilin&op_usm=0.8%2c1.0%2c6%2c0&iccEmbed=0","item_url":"https://usa.tommy.com/en/product/curve-organic-cotton-linear-logo-t-shirt-dw11342","fulfillment_status":"NOT_SHIPPED","item_promise_date":"2021-06-25T07:04:22Z","attributes":null,"color":"ROMANTIC PINK","size":"3XL","style":null}],"shipments":[{"carrier_service_code":"UPS2D","ship_method":"Ground","items_info":[{"quantity":1,"sku":"194998027245","item_id":"3074457345633000321"}],"promise_date":"2021-06-25T07:04:22","carrier":"ups","tracking_number":"1Z6F741A0219172073","type":"shipment","status":"WAITING"},{"carrier_service_code":"UPS","ship_method":"Ground","items_info":[{"quantity":0,"sku":"194998027245","item_id":"3074457345633000321"}],"promise_date":"2021-06-25T07:04:22","carrier":"ups","tracking_number":"66534104","type":"shipment","status":"NOT_SHIPPED"}],"customer":{"customer_id":""}},"tracking_info":[{"resFromDelCr":false,"trackingStatusCodes":true,"pickedByCustomer":false,"retailer_moniker":"tommy1","weight_uom":"LBS","packageCount":null,"partner_carrier_tracking_number":null,"weight":0.5,"source":"WEB","locale":"en_US","service_desc":"UPS 2nd Day Air","status":"On its way","fb_uuid":"1a07d73628834f83852bba2f411e1c04::1625234149498","status_token":"widgets_tracking_status_intransit_status","status_desc":"Departed from Facility","tracking_number":"1Z6F741A0219172073","mask_tracking_number":null,"guaranteed_delivery_date":null,"estimated_delivery_date_end":null,"estimated_delivery_date_begin":"2021-07-06 00:00:00","edd_source":"CARRIEREDD","status_code":"DP","order_number":null,"class_of_mail_code":"002","pickup_start":null,"pickup_end":null,"ship_date":"2021-07-01 00:00:00","no_eta_message":null,"tracking_status_code":"INTR","status_summary":"Departed from Facility","last_status_date":"2021-07-02 08:26:00","TrackDetail":[{"shipmentLocationType":null,"error":null,"error_code":null,"event":"Departed from Facility","event_code":"DP","event_date":"2021-07-02 08:26:00","event_city":"South Charleston","event_state":"WV","event_country_code":"US","event_date_offset":null,"track_status_code_mapping":{"track_status_code":"300","track_status_code_desc":"Picked-up by Carrier / In-Transit: General","track_status_display_token":"tracking_status_intransit_pick_carrier","track_status_bucket":"In Transit","track_status_bucket_code":"INTR","track_status_bucket_display_token":"widgets_tracking_status_intransit_status"},"track_status_code_raw":"300"},{"shipmentLocationType":null,"error":null,"error_code":null,"event":"Arrived at Facility","event_code":"AR","event_date":"2021-07-02 04:04:00","event_city":"South Charleston","event_state":"WV","event_country_code":"US","event_date_offset":null,"track_status_code_mapping":{"track_status_code":"300","track_status_code_desc":"Picked-up by Carrier / In-Transit: General","track_status_display_token":"tracking_status_intransit_pick_carrier","track_status_bucket":"In Transit","track_status_bucket_code":"INTR","track_status_bucket_display_token":"widgets_tracking_status_intransit_status"},"track_status_code_raw":"300"},{"shipmentLocationType":null,"error":null,"error_code":null,"event":"Departed from Facility","event_code":"DP","event_date":"2021-07-02 01:04:00","event_city":"Roanoke","event_state":"VA","event_country_code":"US","event_date_offset":null,"track_status_code_mapping":{"track_status_code":"300","track_status_code_desc":"Picked-up by Carrier / In-Transit: General","track_status_display_token":"tracking_status_intransit_pick_carrier","track_status_bucket":"In Transit","track_status_bucket_code":"INTR","track_status_bucket_display_token":"widgets_tracking_status_intransit_status"},"track_status_code_raw":"300"},{"shipmentLocationType":null,"error":null,"error_code":null,"event":"En Route to Delivery Location","event_code":"X6","event_date":"2021-07-01 19:09:00","event_city":"ROANOKE","event_state":"VA","event_country_code":"US","event_date_offset":null,"track_status_code_mapping":{"track_status_code":"300","track_status_code_desc":"Picked-up by Carrier / In-Transit: General","track_status_display_token":"tracking_status_intransit_pick_carrier","track_status_bucket":"In Transit","track_status_bucket_code":"INTR","track_status_bucket_display_token":"widgets_tracking_status_intransit_status"},"track_status_code_raw":"300"},{"shipmentLocationType":null,"error":null,"error_code":null,"event":"Origin Scan","event_code":"OR","event_date":"2021-07-01 19:08:00","event_city":"Roanoke","event_state":"VA","event_country_code":"US","event_date_offset":null,"track_status_code_mapping":{"track_status_code":"300","track_status_code_desc":"Picked-up by Carrier / In-Transit: General","track_status_display_token":"tracking_status_intransit_pick_carrier","track_status_bucket":"In Transit","track_status_bucket_code":"INTR","track_status_bucket_display_token":"widgets_tracking_status_intransit_status"},"track_status_code_raw":"300"},{"shipmentLocationType":null,"error":null,"error_code":null,"event":"Shipper created a label, UPS has not received the package yet.","event_code":"MP","event_date":"2021-07-01 19:08:00","event_city":null,"event_state":null,"event_country_code":null,"event_date_offset":null,"track_status_code_mapping":{"track_status_code":"300","track_status_code_desc":"Picked-up by Carrier / In-Transit: General","track_status_display_token":"tracking_status_intransit_pick_carrier","track_status_bucket":"In Transit","track_status_bucket_code":"INTR","track_status_bucket_display_token":"widgets_tracking_status_intransit_status"},"track_status_code_raw":"200"},{"shipmentLocationType":null,"error":null,"error_code":null,"event":"En Route to Delivery Location","event_code":"X6","event_date":"2021-07-01 19:05:00","event_city":null,"event_state":null,"event_country_code":null,"event_date_offset":null,"track_status_code_mapping":{"track_status_code":"300","track_status_code_desc":"Picked-up by Carrier / In-Transit: General","track_status_display_token":"tracking_status_intransit_pick_carrier","track_status_bucket":"In Transit","track_status_bucket_code":"INTR","track_status_bucket_display_token":"widgets_tracking_status_intransit_status"},"track_status_code_raw":"300"}],"errors":null,"carrier_name":"UPS","carrier_url":"https://www.ups.com/content/us/en/contact/index.html","carrier_id":"ups","partner_carrier_name":null,"partner_carrier_url":null,"partner_carrier_id":null,"carrier_transfer":false,"service_start_day":0,"service_end_day":0,"carrier_holidays":null,"tracking_url":"https://wwwapps.ups.com/WebTracking/track?track=yes&trackNums=1Z6F741A0219172073&loc=en_US","narvar_status":"INTRANSIT","undeliverable":false,"package_redirect":null,"ship_by_date":null,"pickup_date":null,"is_label_cancelled":false,"sms_signed_up":false,"fb_messenger_signed_up":false,"generic_tracking":false,"promise_date_begin":null,"promise_date_end":null,"track_Url_Tracking_Id":"1Z6F741A0219172073","redirect_to_hold":{"eligible":false,"redirect_request_number":null,"package_identifier":null,"has_nearby_locations":true,"scheduled":false,"confirmation_number":null,"store_details":null},"is_tracking_status_codes":true,"schedulable":{"is_schedulable":false,"reason":null,"is_reschedulable":false,"is_scheduled":false,"is_schedulable_later":false,"is_schedulable_api":false,"eligibility_status":null,"eligibility_message":null},"redirect_address":null,"slug":"ups","broadcast_messages":null,"signature":null,"is_picked_by_customer":false,"is_internal_carrier":false,"pickup_by_date":null,"delivery_instructions":null,"polling":null,"stops":null,"delivery_management_link":"https://www.ups.com/us/en/services/tracking/mychoice.page","line_package_subscription_text":"c0720176e6e8742cf3ca707b9ec8995e69717c415e8f67c30cc3588f1d830865d083515237e8d48e0917aa484366dda56b5d74f74fbe9c3c3c28454d04c4eaa4dff4430f8a8eca59f62723ab104a90bc26264fd5a71cfb6c8338ee0d2855fc1357fcf0f68dcaa9dcb5c65d9901a993ee36861bf328d2d0a382b26095573af6f0efee7abef2dfda9ce9bc39c9e7e66b3dc437d60d23656ca4c6387a2"},{"resFromDelCr":false,"trackingStatusCodes":true,"pickedByCustomer":false,"retailer_moniker":"tommy1","weight_uom":null,"packageCount":null,"partner_carrier_tracking_number":null,"weight":null,"source":"WEB","locale":"en_US","service_desc":null,"status":"Awaiting Carrier Pickup","fb_uuid":"7c103f707563474889bf496490785277::1625234149540","status_token":"widgets_tracking_status_justshipped_status","status_desc":null,"tracking_number":"66534104","mask_tracking_number":null,"guaranteed_delivery_date":null,"estimated_delivery_date_end":null,"estimated_delivery_date_begin":null,"edd_source":"STALEEDDMSG","status_code":null,"order_number":null,"class_of_mail_code":null,"pickup_start":null,"pickup_end":null,"ship_date":null,"no_eta_message":null,"tracking_status_code":"SHPD","status_summary":null,"last_status_date":null,"TrackDetail":[],"errors":null,"carrier_name":"UPS","carrier_url":"https://www.ups.com/content/us/en/contact/index.html","carrier_id":"ups","partner_carrier_name":null,"partner_carrier_url":null,"partner_carrier_id":null,"carrier_transfer":false,"service_start_day":0,"service_end_day":0,"carrier_holidays":null,"tracking_url":"https://wwwapps.ups.com/WebTracking/track?track=yes&trackNums=66534104&loc=en_US","narvar_status":"JUSTSHIPPED","undeliverable":false,"package_redirect":null,"ship_by_date":null,"pickup_date":null,"is_label_cancelled":false,"sms_signed_up":false,"fb_messenger_signed_up":false,"generic_tracking":false,"promise_date_begin":null,"promise_date_end":null,"track_Url_Tracking_Id":null,"redirect_to_hold":{"eligible":false,"redirect_request_number":null,"package_identifier":null,"has_nearby_locations":true,"scheduled":false,"confirmation_number":null,"store_details":null},"is_tracking_status_codes":true,"schedulable":{"is_schedulable":false,"reason":null,"is_reschedulable":false,"is_scheduled":false,"is_schedulable_later":false,"is_schedulable_api":false,"eligibility_status":null,"eligibility_message":null},"redirect_address":null,"slug":"ups","broadcast_messages":null,"signature":null,"is_picked_by_customer":false,"is_internal_carrier":false,"pickup_by_date":null,"delivery_instructions":null,"polling":null,"stops":null,"delivery_management_link":"https://www.ups.com/us/en/services/tracking/mychoice.page","line_package_subscription_text":"c072017514a8c0befade0da93604b0e54c246387b612c3f45b02ec108a87db7d61e56cd77389008115b047026d3bf5e917f33cddc7835a843ce1d805d33b5328f634964412e7dfca6e8ca1169eca0a2a5a41a26b390757646c8df826187e7c5ad8615456559bd1ae913ea8c616abbf056eae6ea556ab9ac5b64f247c5edba0bfa0c15304ca11ec51f0d8194"}],"invalid_item_vis_request":false,"status":"SUCCESS","messages":[{"code":"response.status.success"}]}';
                }
                when '33333333' {
                   return '{"order_info":{"order_number":"33333333","order_date":"2021-06-22T07:04:22-04:00","order_items":[{"item_id":"3074457345633000321","retailer":null,"sku":"194998027245","name":"Curve Organic Cotton Linear Logo T-Shirt","description":null,"quantity":1,"item_image":"https://shoptommy.scene7.com/is/image/ShopTommy/DW11342_650_FNT?wid=194&hei=259&fmt=jpeg&qlt=90%2c0&op_sharpen=1&resMode=trilin&op_usm=0.8%2c1.0%2c6%2c0&iccEmbed=0","item_url":"https://usa.tommy.com/en/product/curve-organic-cotton-linear-logo-t-shirt-dw11342","fulfillment_status":"CANCELLED","item_promise_date":"2021-06-25T07:04:22Z","attributes":null,"color":"ROMANTIC PINK","size":"3XL","style":null}],"shipments":[{"carrier_service_code":"UPS2D","ship_method":"Ground","items_info":[{"quantity":1,"sku":"194998027245","item_id":"3074457345633000321"}],"promise_date":"2021-06-25T07:04:22","carrier":"ups","tracking_number":"1Z6F741A0219172073","type":"shipment","status":"CANCELLED"},{"carrier_service_code":"UPS","ship_method":"Ground","items_info":[{"quantity":0,"sku":"194998027245","item_id":"3074457345633000321"}],"promise_date":"2021-06-25T07:04:22","carrier":"ups","tracking_number":"66534104","type":"shipment","status":"CANCELLED"}],"customer":{"customer_id":""}},"tracking_info":[{"resFromDelCr":false,"trackingStatusCodes":true,"pickedByCustomer":false,"retailer_moniker":"tommy1","weight_uom":"LBS","packageCount":null,"partner_carrier_tracking_number":null,"weight":0.5,"source":"WEB","locale":"en_US","service_desc":"UPS 2nd Day Air","status":"On its way","fb_uuid":"1a07d73628834f83852bba2f411e1c04::1625234149498","status_token":"widgets_tracking_status_intransit_status","status_desc":"Departed from Facility","tracking_number":"1Z6F741A0219172073","mask_tracking_number":null,"guaranteed_delivery_date":null,"estimated_delivery_date_end":null,"estimated_delivery_date_begin":"2021-07-06 00:00:00","edd_source":"CARRIEREDD","status_code":"DP","order_number":null,"class_of_mail_code":"002","pickup_start":null,"pickup_end":null,"ship_date":"2021-07-01 00:00:00","no_eta_message":null,"tracking_status_code":"INTR","status_summary":"Departed from Facility","last_status_date":"2021-07-02 08:26:00","TrackDetail":[{"shipmentLocationType":null,"error":null,"error_code":null,"event":"Departed from Facility","event_code":"DP","event_date":"2021-07-02 08:26:00","event_city":"South Charleston","event_state":"WV","event_country_code":"US","event_date_offset":null,"track_status_code_mapping":{"track_status_code":"300","track_status_code_desc":"Picked-up by Carrier / In-Transit: General","track_status_display_token":"tracking_status_intransit_pick_carrier","track_status_bucket":"In Transit","track_status_bucket_code":"INTR","track_status_bucket_display_token":"widgets_tracking_status_intransit_status"},"track_status_code_raw":"300"},{"shipmentLocationType":null,"error":null,"error_code":null,"event":"Arrived at Facility","event_code":"AR","event_date":"2021-07-02 04:04:00","event_city":"South Charleston","event_state":"WV","event_country_code":"US","event_date_offset":null,"track_status_code_mapping":{"track_status_code":"300","track_status_code_desc":"Picked-up by Carrier / In-Transit: General","track_status_display_token":"tracking_status_intransit_pick_carrier","track_status_bucket":"In Transit","track_status_bucket_code":"INTR","track_status_bucket_display_token":"widgets_tracking_status_intransit_status"},"track_status_code_raw":"300"},{"shipmentLocationType":null,"error":null,"error_code":null,"event":"Departed from Facility","event_code":"DP","event_date":"2021-07-02 01:04:00","event_city":"Roanoke","event_state":"VA","event_country_code":"US","event_date_offset":null,"track_status_code_mapping":{"track_status_code":"300","track_status_code_desc":"Picked-up by Carrier / In-Transit: General","track_status_display_token":"tracking_status_intransit_pick_carrier","track_status_bucket":"In Transit","track_status_bucket_code":"INTR","track_status_bucket_display_token":"widgets_tracking_status_intransit_status"},"track_status_code_raw":"300"},{"shipmentLocationType":null,"error":null,"error_code":null,"event":"En Route to Delivery Location","event_code":"X6","event_date":"2021-07-01 19:09:00","event_city":"ROANOKE","event_state":"VA","event_country_code":"US","event_date_offset":null,"track_status_code_mapping":{"track_status_code":"300","track_status_code_desc":"Picked-up by Carrier / In-Transit: General","track_status_display_token":"tracking_status_intransit_pick_carrier","track_status_bucket":"In Transit","track_status_bucket_code":"INTR","track_status_bucket_display_token":"widgets_tracking_status_intransit_status"},"track_status_code_raw":"300"},{"shipmentLocationType":null,"error":null,"error_code":null,"event":"Origin Scan","event_code":"OR","event_date":"2021-07-01 19:08:00","event_city":"Roanoke","event_state":"VA","event_country_code":"US","event_date_offset":null,"track_status_code_mapping":{"track_status_code":"300","track_status_code_desc":"Picked-up by Carrier / In-Transit: General","track_status_display_token":"tracking_status_intransit_pick_carrier","track_status_bucket":"In Transit","track_status_bucket_code":"INTR","track_status_bucket_display_token":"widgets_tracking_status_intransit_status"},"track_status_code_raw":"300"},{"shipmentLocationType":null,"error":null,"error_code":null,"event":"Shipper created a label, UPS has not received the package yet.","event_code":"MP","event_date":"2021-07-01 19:08:00","event_city":null,"event_state":null,"event_country_code":null,"event_date_offset":null,"track_status_code_mapping":{"track_status_code":"300","track_status_code_desc":"Picked-up by Carrier / In-Transit: General","track_status_display_token":"tracking_status_intransit_pick_carrier","track_status_bucket":"In Transit","track_status_bucket_code":"INTR","track_status_bucket_display_token":"widgets_tracking_status_intransit_status"},"track_status_code_raw":"200"},{"shipmentLocationType":null,"error":null,"error_code":null,"event":"En Route to Delivery Location","event_code":"X6","event_date":"2021-07-01 19:05:00","event_city":null,"event_state":null,"event_country_code":null,"event_date_offset":null,"track_status_code_mapping":{"track_status_code":"300","track_status_code_desc":"Picked-up by Carrier / In-Transit: General","track_status_display_token":"tracking_status_intransit_pick_carrier","track_status_bucket":"In Transit","track_status_bucket_code":"INTR","track_status_bucket_display_token":"widgets_tracking_status_intransit_status"},"track_status_code_raw":"300"}],"errors":null,"carrier_name":"UPS","carrier_url":"https://www.ups.com/content/us/en/contact/index.html","carrier_id":"ups","partner_carrier_name":null,"partner_carrier_url":null,"partner_carrier_id":null,"carrier_transfer":false,"service_start_day":0,"service_end_day":0,"carrier_holidays":null,"tracking_url":"https://wwwapps.ups.com/WebTracking/track?track=yes&trackNums=1Z6F741A0219172073&loc=en_US","narvar_status":"INTRANSIT","undeliverable":false,"package_redirect":null,"ship_by_date":null,"pickup_date":null,"is_label_cancelled":false,"sms_signed_up":false,"fb_messenger_signed_up":false,"generic_tracking":false,"promise_date_begin":null,"promise_date_end":null,"track_Url_Tracking_Id":"1Z6F741A0219172073","redirect_to_hold":{"eligible":false,"redirect_request_number":null,"package_identifier":null,"has_nearby_locations":true,"scheduled":false,"confirmation_number":null,"store_details":null},"is_tracking_status_codes":true,"schedulable":{"is_schedulable":false,"reason":null,"is_reschedulable":false,"is_scheduled":false,"is_schedulable_later":false,"is_schedulable_api":false,"eligibility_status":null,"eligibility_message":null},"redirect_address":null,"slug":"ups","broadcast_messages":null,"signature":null,"is_picked_by_customer":false,"is_internal_carrier":false,"pickup_by_date":null,"delivery_instructions":null,"polling":null,"stops":null,"delivery_management_link":"https://www.ups.com/us/en/services/tracking/mychoice.page","line_package_subscription_text":"c0720176e6e8742cf3ca707b9ec8995e69717c415e8f67c30cc3588f1d830865d083515237e8d48e0917aa484366dda56b5d74f74fbe9c3c3c28454d04c4eaa4dff4430f8a8eca59f62723ab104a90bc26264fd5a71cfb6c8338ee0d2855fc1357fcf0f68dcaa9dcb5c65d9901a993ee36861bf328d2d0a382b26095573af6f0efee7abef2dfda9ce9bc39c9e7e66b3dc437d60d23656ca4c6387a2"},{"resFromDelCr":false,"trackingStatusCodes":true,"pickedByCustomer":false,"retailer_moniker":"tommy1","weight_uom":null,"packageCount":null,"partner_carrier_tracking_number":null,"weight":null,"source":"WEB","locale":"en_US","service_desc":null,"status":"Awaiting Carrier Pickup","fb_uuid":"7c103f707563474889bf496490785277::1625234149540","status_token":"widgets_tracking_status_justshipped_status","status_desc":null,"tracking_number":"66534104","mask_tracking_number":null,"guaranteed_delivery_date":null,"estimated_delivery_date_end":null,"estimated_delivery_date_begin":null,"edd_source":"STALEEDDMSG","status_code":null,"order_number":null,"class_of_mail_code":null,"pickup_start":null,"pickup_end":null,"ship_date":null,"no_eta_message":null,"tracking_status_code":"SHPD","status_summary":null,"last_status_date":null,"TrackDetail":[],"errors":null,"carrier_name":"UPS","carrier_url":"https://www.ups.com/content/us/en/contact/index.html","carrier_id":"ups","partner_carrier_name":null,"partner_carrier_url":null,"partner_carrier_id":null,"carrier_transfer":false,"service_start_day":0,"service_end_day":0,"carrier_holidays":null,"tracking_url":"https://wwwapps.ups.com/WebTracking/track?track=yes&trackNums=66534104&loc=en_US","narvar_status":"JUSTSHIPPED","undeliverable":false,"package_redirect":null,"ship_by_date":null,"pickup_date":null,"is_label_cancelled":false,"sms_signed_up":false,"fb_messenger_signed_up":false,"generic_tracking":false,"promise_date_begin":null,"promise_date_end":null,"track_Url_Tracking_Id":null,"redirect_to_hold":{"eligible":false,"redirect_request_number":null,"package_identifier":null,"has_nearby_locations":true,"scheduled":false,"confirmation_number":null,"store_details":null},"is_tracking_status_codes":true,"schedulable":{"is_schedulable":false,"reason":null,"is_reschedulable":false,"is_scheduled":false,"is_schedulable_later":false,"is_schedulable_api":false,"eligibility_status":null,"eligibility_message":null},"redirect_address":null,"slug":"ups","broadcast_messages":null,"signature":null,"is_picked_by_customer":false,"is_internal_carrier":false,"pickup_by_date":null,"delivery_instructions":null,"polling":null,"stops":null,"delivery_management_link":"https://www.ups.com/us/en/services/tracking/mychoice.page","line_package_subscription_text":"c072017514a8c0befade0da93604b0e54c246387b612c3f45b02ec108a87db7d61e56cd77389008115b047026d3bf5e917f33cddc7835a843ce1d805d33b5328f634964412e7dfca6e8ca1169eca0a2a5a41a26b390757646c8df826187e7c5ad8615456559bd1ae913ea8c616abbf056eae6ea556ab9ac5b64f247c5edba0bfa0c15304ca11ec51f0d8194"}],"invalid_item_vis_request":false,"status":"SUCCESS","messages":[{"code":"response.status.success"}]}';
                }
                when '44444444' {
                    return '{"order_info":{"order_number":"44444444","order_date":"2021-06-22T07:04:22-04:00","order_items":[],"shipments":[{"carrier_service_code":"UPS2D","ship_method":"Ground","items_info":[],"promise_date":"2021-06-25T07:04:22","carrier":"ups","tracking_number":"1Z6F741A0219172073","type":"shipment","status":"INTRANSIT"},{"carrier_service_code":"UPS","ship_method":"Ground","items_info":[],"promise_date":"2021-06-25T07:04:22","carrier":"ups","tracking_number":"66534104","type":"shipment","status":"JUSTSHIPPED"}],"customer":{"customer_id":""}},"tracking_info":[{"resFromDelCr":false,"trackingStatusCodes":true,"pickedByCustomer":false,"retailer_moniker":"tommy1","weight_uom":"LBS","packageCount":null,"partner_carrier_tracking_number":null,"weight":0.5,"source":"WEB","locale":"en_US","service_desc":"UPS 2nd Day Air","status":"On its way","fb_uuid":"1a07d73628834f83852bba2f411e1c04::1625234149498","status_token":"widgets_tracking_status_intransit_status","status_desc":"Departed from Facility","tracking_number":"1Z6F741A0219172073","mask_tracking_number":null,"guaranteed_delivery_date":null,"estimated_delivery_date_end":null,"estimated_delivery_date_begin":"2021-07-06 00:00:00","edd_source":"CARRIEREDD","status_code":"DP","order_number":null,"class_of_mail_code":"002","pickup_start":null,"pickup_end":null,"ship_date":"2021-07-01 00:00:00","no_eta_message":null,"tracking_status_code":"INTR","status_summary":"Departed from Facility","last_status_date":"2021-07-02 08:26:00","TrackDetail":[{"shipmentLocationType":null,"error":null,"error_code":null,"event":"Departed from Facility","event_code":"DP","event_date":"2021-07-02 08:26:00","event_city":"South Charleston","event_state":"WV","event_country_code":"US","event_date_offset":null,"track_status_code_mapping":{"track_status_code":"300","track_status_code_desc":"Picked-up by Carrier / In-Transit: General","track_status_display_token":"tracking_status_intransit_pick_carrier","track_status_bucket":"In Transit","track_status_bucket_code":"INTR","track_status_bucket_display_token":"widgets_tracking_status_intransit_status"},"track_status_code_raw":"300"},{"shipmentLocationType":null,"error":null,"error_code":null,"event":"Arrived at Facility","event_code":"AR","event_date":"2021-07-02 04:04:00","event_city":"South Charleston","event_state":"WV","event_country_code":"US","event_date_offset":null,"track_status_code_mapping":{"track_status_code":"300","track_status_code_desc":"Picked-up by Carrier / In-Transit: General","track_status_display_token":"tracking_status_intransit_pick_carrier","track_status_bucket":"In Transit","track_status_bucket_code":"INTR","track_status_bucket_display_token":"widgets_tracking_status_intransit_status"},"track_status_code_raw":"300"},{"shipmentLocationType":null,"error":null,"error_code":null,"event":"Departed from Facility","event_code":"DP","event_date":"2021-07-02 01:04:00","event_city":"Roanoke","event_state":"VA","event_country_code":"US","event_date_offset":null,"track_status_code_mapping":{"track_status_code":"300","track_status_code_desc":"Picked-up by Carrier / In-Transit: General","track_status_display_token":"tracking_status_intransit_pick_carrier","track_status_bucket":"In Transit","track_status_bucket_code":"INTR","track_status_bucket_display_token":"widgets_tracking_status_intransit_status"},"track_status_code_raw":"300"},{"shipmentLocationType":null,"error":null,"error_code":null,"event":"En Route to Delivery Location","event_code":"X6","event_date":"2021-07-01 19:09:00","event_city":"ROANOKE","event_state":"VA","event_country_code":"US","event_date_offset":null,"track_status_code_mapping":{"track_status_code":"300","track_status_code_desc":"Picked-up by Carrier / In-Transit: General","track_status_display_token":"tracking_status_intransit_pick_carrier","track_status_bucket":"In Transit","track_status_bucket_code":"INTR","track_status_bucket_display_token":"widgets_tracking_status_intransit_status"},"track_status_code_raw":"300"},{"shipmentLocationType":null,"error":null,"error_code":null,"event":"Origin Scan","event_code":"OR","event_date":"2021-07-01 19:08:00","event_city":"Roanoke","event_state":"VA","event_country_code":"US","event_date_offset":null,"track_status_code_mapping":{"track_status_code":"300","track_status_code_desc":"Picked-up by Carrier / In-Transit: General","track_status_display_token":"tracking_status_intransit_pick_carrier","track_status_bucket":"In Transit","track_status_bucket_code":"INTR","track_status_bucket_display_token":"widgets_tracking_status_intransit_status"},"track_status_code_raw":"300"},{"shipmentLocationType":null,"error":null,"error_code":null,"event":"Shipper created a label, UPS has not received the package yet.","event_code":"MP","event_date":"2021-07-01 19:08:00","event_city":null,"event_state":null,"event_country_code":null,"event_date_offset":null,"track_status_code_mapping":{"track_status_code":"300","track_status_code_desc":"Picked-up by Carrier / In-Transit: General","track_status_display_token":"tracking_status_intransit_pick_carrier","track_status_bucket":"In Transit","track_status_bucket_code":"INTR","track_status_bucket_display_token":"widgets_tracking_status_intransit_status"},"track_status_code_raw":"200"},{"shipmentLocationType":null,"error":null,"error_code":null,"event":"En Route to Delivery Location","event_code":"X6","event_date":"2021-07-01 19:05:00","event_city":null,"event_state":null,"event_country_code":null,"event_date_offset":null,"track_status_code_mapping":{"track_status_code":"300","track_status_code_desc":"Picked-up by Carrier / In-Transit: General","track_status_display_token":"tracking_status_intransit_pick_carrier","track_status_bucket":"In Transit","track_status_bucket_code":"INTR","track_status_bucket_display_token":"widgets_tracking_status_intransit_status"},"track_status_code_raw":"300"}],"errors":null,"carrier_name":"UPS","carrier_url":"https://www.ups.com/content/us/en/contact/index.html","carrier_id":"ups","partner_carrier_name":null,"partner_carrier_url":null,"partner_carrier_id":null,"carrier_transfer":false,"service_start_day":0,"service_end_day":0,"carrier_holidays":null,"tracking_url":"https://wwwapps.ups.com/WebTracking/track?track=yes&trackNums=1Z6F741A0219172073&loc=en_US","narvar_status":"INTRANSIT","undeliverable":false,"package_redirect":null,"ship_by_date":null,"pickup_date":null,"is_label_cancelled":false,"sms_signed_up":false,"fb_messenger_signed_up":false,"generic_tracking":false,"promise_date_begin":null,"promise_date_end":null,"track_Url_Tracking_Id":"1Z6F741A0219172073","redirect_to_hold":{"eligible":false,"redirect_request_number":null,"package_identifier":null,"has_nearby_locations":true,"scheduled":false,"confirmation_number":null,"store_details":null},"is_tracking_status_codes":true,"schedulable":{"is_schedulable":false,"reason":null,"is_reschedulable":false,"is_scheduled":false,"is_schedulable_later":false,"is_schedulable_api":false,"eligibility_status":null,"eligibility_message":null},"redirect_address":null,"slug":"ups","broadcast_messages":null,"signature":null,"is_picked_by_customer":false,"is_internal_carrier":false,"pickup_by_date":null,"delivery_instructions":null,"polling":null,"stops":null,"delivery_management_link":"https://www.ups.com/us/en/services/tracking/mychoice.page","line_package_subscription_text":"c0720176e6e8742cf3ca707b9ec8995e69717c415e8f67c30cc3588f1d830865d083515237e8d48e0917aa484366dda56b5d74f74fbe9c3c3c28454d04c4eaa4dff4430f8a8eca59f62723ab104a90bc26264fd5a71cfb6c8338ee0d2855fc1357fcf0f68dcaa9dcb5c65d9901a993ee36861bf328d2d0a382b26095573af6f0efee7abef2dfda9ce9bc39c9e7e66b3dc437d60d23656ca4c6387a2"},{"resFromDelCr":false,"trackingStatusCodes":true,"pickedByCustomer":false,"retailer_moniker":"tommy1","weight_uom":null,"packageCount":null,"partner_carrier_tracking_number":null,"weight":null,"source":"WEB","locale":"en_US","service_desc":null,"status":"Awaiting Carrier Pickup","fb_uuid":"7c103f707563474889bf496490785277::1625234149540","status_token":"widgets_tracking_status_justshipped_status","status_desc":null,"tracking_number":"66534104","mask_tracking_number":null,"guaranteed_delivery_date":null,"estimated_delivery_date_end":null,"estimated_delivery_date_begin":null,"edd_source":"STALEEDDMSG","status_code":null,"order_number":null,"class_of_mail_code":null,"pickup_start":null,"pickup_end":null,"ship_date":null,"no_eta_message":null,"tracking_status_code":"SHPD","status_summary":null,"last_status_date":null,"TrackDetail":[],"errors":null,"carrier_name":"UPS","carrier_url":"https://www.ups.com/content/us/en/contact/index.html","carrier_id":"ups","partner_carrier_name":null,"partner_carrier_url":null,"partner_carrier_id":null,"carrier_transfer":false,"service_start_day":0,"service_end_day":0,"carrier_holidays":null,"tracking_url":"https://wwwapps.ups.com/WebTracking/track?track=yes&trackNums=66534104&loc=en_US","narvar_status":"JUSTSHIPPED","undeliverable":false,"package_redirect":null,"ship_by_date":null,"pickup_date":null,"is_label_cancelled":false,"sms_signed_up":false,"fb_messenger_signed_up":false,"generic_tracking":false,"promise_date_begin":null,"promise_date_end":null,"track_Url_Tracking_Id":null,"redirect_to_hold":{"eligible":false,"redirect_request_number":null,"package_identifier":null,"has_nearby_locations":true,"scheduled":false,"confirmation_number":null,"store_details":null},"is_tracking_status_codes":true,"schedulable":{"is_schedulable":false,"reason":null,"is_reschedulable":false,"is_scheduled":false,"is_schedulable_later":false,"is_schedulable_api":false,"eligibility_status":null,"eligibility_message":null},"redirect_address":null,"slug":"ups","broadcast_messages":null,"signature":null,"is_picked_by_customer":false,"is_internal_carrier":false,"pickup_by_date":null,"delivery_instructions":null,"polling":null,"stops":null,"delivery_management_link":"https://www.ups.com/us/en/services/tracking/mychoice.page","line_package_subscription_text":"c072017514a8c0befade0da93604b0e54c246387b612c3f45b02ec108a87db7d61e56cd77389008115b047026d3bf5e917f33cddc7835a843ce1d805d33b5328f634964412e7dfca6e8ca1169eca0a2a5a41a26b390757646c8df826187e7c5ad8615456559bd1ae913ea8c616abbf056eae6ea556ab9ac5b64f247c5edba0bfa0c15304ca11ec51f0d8194"}],"invalid_item_vis_request":false,"status":"SUCCESS","messages":[{"code":"response.status.success"}]}';
                }
            }
        }
        return orderAPIcall(endpoint);
    }


    public static String orderAPIcall (String endpoint) {
        System.debug('API Call Endpoint: ' + endpoint);

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        Http http = new Http();

        HttpResponse response = http.send(req);
        System.debug('API Call Status: ' + response.getStatusCode() + ' - ' + response.getStatus());

        return response.getBody();
    }

    /*private static String generateHmacSHA256Signature(String privateKey, String secretKeyValue) {
        String algorithmName = 'HmacSHA256';
        Blob hmacData = Crypto.generateMac(algorithmName, Blob.valueOf(privateKey), Blob.valueOf(secretKeyValue));

        return EncodingUtil.convertToHex(hmacData);
    }*/
}