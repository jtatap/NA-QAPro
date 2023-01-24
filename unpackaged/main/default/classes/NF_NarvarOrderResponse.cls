/**
 * Created by samuel on 10/16/20.
 */

public without sharing class NF_NarvarOrderResponse {


    /**
     * OVERALL STRUCTURE
     * - Order Info: individual items and shipping information, with some tracking info
     * - Tracking Info: More detailed information for the overall order (retail moniker, more carrier info) - UNUSED
     * - Messages: Additional info, used for error tracking
     */
    //public Error[] errors{get;set;} // May be artifact from old implementation
    /*public Order_info order_info;
    public List<tracking_info> tracking_info;
    public Boolean invalid_item_vis_request;
    public String status;
    public List<Messages> messages;

    public class order_item {
        public String item_id {get;set;}
        public String retailer {get;set;}
        public String sku {get;set;}
        public String name {get;set;}
        public String description {get;set;}
        public Integer quantity {get;set;}
        public String item_image {get;set;}
        public String item_url {get;set;}
        public String fulfillment_status {get;set;}
        public String item_promise_date {get;set;}
        public Attributes attributes {get;set;}
        public String color {get;set;}
        public String size {get;set;}
        public String style {get;set;}
    }

    public class Attributes {
    }

    public class Order_info {
        public String order_number {get;set;}
        public String order_date {get;set;}
        public List<Order_item> order_items {get;set;}
        public List<Shipments> shipments {get;set;}
        public Customer customer {get;set;}
    }

    public class Customer {
        public String customer_id { get; set; }
    }

    public class Shipments {
        public String carrier_service_code {get;set;}
        public String ship_method {get;set;}
        public List<Items_info> items_info {get;set;}
        public String promise_date {get;set;}
        public String carrier {get;set;}
        public String tracking_number {get;set;}
        public String type {get;set;}
        public String status {get;set;}
    }

    public class Items_info {
        public Integer quantity {get;set;}
        public String sku {get;set;}
        public String item_id {get;set;}
    }

    public class tracking_info {
        public Boolean resFromDelCr {get;set;}
        public Boolean pickedByCustomer {get;set;}
        public Boolean trackingStatusCodes {get;set;}
        public String retailer_moniker {get;set;}
        public String weight_uom {get;set;}
        public String packageCount {get;set;}
        public String partner_carrier_tracking_number {get;set;}
        public Double weight {get;set;}
        public String source {get;set;}
        public String locale {get;set;}
        public String service_desc {get;set;}
        public String status {get;set;}
        public String fb_uuid {get;set;}
        public String status_token {get;set;}
        public String status_desc {get;set;}
        public String tracking_number {get;set;}
        public String mask_tracking_number {get;set;}
        public String guaranteed_delivery_date {get;set;}
        public String estimated_delivery_date_end {get;set;}
        public String estimated_delivery_date_begin {get;set;}
        public String edd_source {get;set;}
        public String status_code {get;set;}
        public String order_number {get;set;}
        public String class_of_mail_code {get;set;}
        public String pickup_start {get;set;}
        public String pickup_end {get;set;}
        public String ship_date {get;set;}
        public String no_eta_message {get;set;}
        public String tracking_status_code {get;set;}
        public String status_summary {get;set;}
        public String last_status_date {get;set;}
        public List<TrackDetail> TrackDetail {get;set;}
        public List<String> errors {get;set;}
        public String carrier_name {get;set;}
        public String carrier_url {get;set;}
        public String carrier_id {get;set;}
        public String partner_carrier_name {get;set;}
        public String partner_carrier_url {get;set;}
        public String partner_carrier_id {get;set;}
        public Boolean carrier_transfer {get;set;}
        public Integer service_start_day {get;set;}
        public Integer service_end_day {get;set;}
        public List<String> carrier_holidays {get;set;}
        public String tracking_url {get;set;}
        public String narvar_status {get;set;}
        public Boolean undeliverable {get;set;}
        public String package_redirect {get;set;}
        public String ship_by_date {get;set;}
        public String pickup_date {get;set;}
        public Boolean is_label_cancelled {get;set;}
        public Boolean sms_signed_up {get;set;}
        public Boolean fb_messenger_signed_up {get;set;}
        public Boolean generic_tracking {get;set;}
        public String promise_date_begin {get;set;}
        public String promise_date_end {get;set;}
        public String track_Url_Tracking_Id {get;set;}
        public Redirect_to_hold redirect_to_hold {get;set;}
        public Boolean is_tracking_status_codes {get;set;}
        public Schedulable schedulable {get;set;}
        public String redirect_address {get;set;}
        public String slug {get;set;}
        public List<String> broadcast_messages {get;set;}
        public String signature {get;set;}
        public Boolean is_picked_by_customer {get;set;}
        public Boolean is_internal_carrier {get;set;}
        public String pickup_by_date {get;set;}
        public String delivery_instructions {get;set;}
        public String polling {get;set;}
        public String stops {get;set;}
        public String delivery_management_link {get;set;}
        public String line_package_subscription_text {get;set;}
    }

    /* Subclass within TrackDetail */

    /*public class Track_status_code_mapping {
        public String track_status_code {get;set;}
        public String track_status_code_desc {get;set;}
        public String track_status_display_token {get;set;}
        public String track_status_bucket {get;set;}
        public String track_status_bucket_code {get;set;}
        public String track_status_bucket_display_token {get;set;}
    }

    public class Redirect_to_hold {
        public Boolean eligible {get;set;}
        public String redirect_request_number {get;set;}
        public String package_identifier {get;set;}
        public Boolean has_nearby_locations {get;set;}
        public Boolean scheduled {get;set;}
        public String confirmation_number {get;set;}
        public String store_details {get;set;}
    }

    public class TrackDetail {
        public String shipmentLocationType {get;set;}
        public String error {get;set;}
        public String error_code {get;set;}
        public String event {get;set;}
        public String event_code {get;set;}
        public String event_date {get;set;}
        public String event_city {get;set;}
        public String event_state {get;set;}
        public String event_country_code {get;set;}
        public String event_date_offset {get;set;}
        public Track_status_code_mapping track_status_code_mapping {get;set;}
        public String track_status_code_raw {get;set;}
    }

    public class Schedulable {
        public Boolean is_schedulable {get;set;}
        public String reason {get;set;}
        public Boolean is_reschedulable {get;set;}
        public Boolean is_scheduled {get;set;}
        public Boolean is_schedulable_later {get;set;}
        public Boolean is_schedulable_api {get;set;}
        public String eligibility_status {get;set;}
        public String eligibility_message {get;set;}
    }

    public class Message_List {
        public List<Messages> messages;
    }
    public class Messages {
        public String code;
    }*/

        public class Track_status_code_mapping {
            public String track_status_code {get;set;}
            public String track_status_code_desc {get;set;}
            public String track_status_display_token {get;set;}
            public String track_status_bucket {get;set;}
            public String track_status_bucket_code {get;set;}
            public String track_status_bucket_display_token {get;set;}

            public Track_status_code_mapping(JSONParser parser) {
                while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                    if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                        String text = parser.getText();
                        if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                            if (text == 'track_status_code') {
                                track_status_code = parser.getText();
                            } else if (text == 'track_status_code_desc') {
                                track_status_code_desc = parser.getText();
                            } else if (text == 'track_status_display_token') {
                                track_status_display_token = parser.getText();
                            } else if (text == 'track_status_bucket') {
                                track_status_bucket = parser.getText();
                            } else if (text == 'track_status_bucket_code') {
                                track_status_bucket_code = parser.getText();
                            } else if (text == 'track_status_bucket_display_token') {
                                track_status_bucket_display_token = parser.getText();
                            } else {
                                System.debug(LoggingLevel.WARN, 'Track_status_code_mapping consuming unrecognized property: '+text);
                                consumeObject(parser);
                            }
                        }
                    }
                }
            }
        }

        public class Redirect_to_hold {
            public Boolean eligible {get;set;}
            public String redirect_request_number {get;set;}
            public String package_identifier {get;set;}
            public Boolean has_nearby_locations {get;set;}
            public Boolean scheduled {get;set;}
            public String confirmation_number {get;set;}
            public String store_details {get;set;}

            public Redirect_to_hold(JSONParser parser) {
                while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                    if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                        String text = parser.getText();
                        if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                            if (text == 'eligible') {
                                eligible = parser.getBooleanValue();
                            } else if (text == 'redirect_request_number') {
                                redirect_request_number = parser.getText();
                            } else if (text == 'package_identifier') {
                                package_identifier = parser.getText();
                            } else if (text == 'has_nearby_locations') {
                                has_nearby_locations = parser.getBooleanValue();
                            } else if (text == 'scheduled') {
                                scheduled = parser.getBooleanValue();
                            } else if (text == 'confirmation_number') {
                                confirmation_number = parser.getText();
                            } else if (text == 'store_details') {
                                store_details = parser.getText();
                            } else {
                                System.debug(LoggingLevel.WARN, 'Redirect_to_hold consuming unrecognized property: '+text);
                                consumeObject(parser);
                            }
                        }
                    }
                }
            }
        }

        public class Messages {
            public String code {get;set;}

            public Messages(JSONParser parser) {
                while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                    if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                        String text = parser.getText();
                        if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                            if (text == 'code') {
                                code = parser.getText();
                            } else {
                                System.debug(LoggingLevel.WARN, 'Messages consuming unrecognized property: '+text);
                                consumeObject(parser);
                            }
                        }
                    }
                }
            }
        }

        public Order_info order_info {get;set;}
        public List<Tracking_info> tracking_info {get;set;}
        public Boolean invalid_item_vis_request {get;set;}
        public String status {get;set;}
        public List<Messages> messages {get;set;}

        public NF_NarvarOrderResponse(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'order_info') {
                            order_info = new Order_info(parser);
                        } else if (text == 'tracking_info') {
                            tracking_info = arrayOfTracking_info(parser);
                        } else if (text == 'invalid_item_vis_request') {
                            invalid_item_vis_request = parser.getBooleanValue();
                        } else if (text == 'status') {
                            status = parser.getText();
                        } else if (text == 'messages') {
                            messages = arrayOfMessages(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'NF_NarvarOrderResponse consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }

        public class Customer {
            public String customer_id {get;set;}

            public Customer(JSONParser parser) {
                while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                    if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                        String text = parser.getText();
                        if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                            if (text == 'customer_id') {
                                customer_id = parser.getText();
                            } else {
                                System.debug(LoggingLevel.WARN, 'Customer consuming unrecognized property: '+text);
                                consumeObject(parser);
                            }
                        }
                    }
                }
            }
        }

        public class Tracking_info {
            public Boolean resFromDelCr {get;set;}
            public Boolean pickedByCustomer {get;set;}
            public Boolean trackingStatusCodes {get;set;}
            public String retailer_moniker {get;set;}
            public String weight_uom {get;set;}
            public String packageCount {get;set;}
            public String partner_carrier_tracking_number {get;set;}
            public Double weight {get;set;}
            public String source {get;set;}
            public String locale {get;set;}
            public String service_desc {get;set;}
            public String status {get;set;}
            public String fb_uuid {get;set;}
            public String status_token {get;set;}
            public String status_desc {get;set;}
            public String tracking_number {get;set;}
            public String mask_tracking_number {get;set;}
            public String guaranteed_delivery_date {get;set;}
            public String estimated_delivery_date_end {get;set;}
            public String estimated_delivery_date_begin {get;set;}
            public String edd_source {get;set;}
            public String status_code {get;set;}
            public String order_number {get;set;}
            public String class_of_mail_code {get;set;}
            public String pickup_start {get;set;}
            public String pickup_end {get;set;}
            public String ship_date {get;set;}
            public String no_eta_message {get;set;}
            public String tracking_status_code {get;set;}
            public String status_summary {get;set;}
            public String last_status_date {get;set;}
            public List<TrackDetail> TrackDetail {get;set;}
            public String errors {get;set;}
            public String carrier_name {get;set;}
            public String carrier_url {get;set;}
            public String carrier_id {get;set;}
            public String partner_carrier_name {get;set;}
            public String partner_carrier_url {get;set;}
            public String partner_carrier_id {get;set;}
            public Boolean carrier_transfer {get;set;}
            public Integer service_start_day {get;set;}
            public Integer service_end_day {get;set;}
            public String carrier_holidays {get;set;}
            public String tracking_url {get;set;}
            public String narvar_status {get;set;}
            public Boolean undeliverable {get;set;}
            public String package_redirect {get;set;}
            public String ship_by_date {get;set;}
            public String pickup_date {get;set;}
            public Boolean is_label_cancelled {get;set;}
            public Boolean sms_signed_up {get;set;}
            public Boolean fb_messenger_signed_up {get;set;}
            public Boolean generic_tracking {get;set;}
            public String promise_date_begin {get;set;}
            public String promise_date_end {get;set;}
            public String track_Url_Tracking_Id {get;set;}
            public Redirect_to_hold redirect_to_hold {get;set;}
            public Boolean is_tracking_status_codes {get;set;}
            public Schedulable schedulable {get;set;}
            public String redirect_address {get;set;}
            public String slug {get;set;}
            public String broadcast_messages {get;set;}
            public String signature {get;set;}
            public Boolean is_picked_by_customer {get;set;}
            public Boolean is_internal_carrier {get;set;}
            public String pickup_by_date {get;set;}
            public String delivery_instructions {get;set;}
            public String polling {get;set;}
            public String stops {get;set;}
            public String delivery_management_link {get;set;}
            public String line_package_subscription_text {get;set;}

            public Tracking_info(JSONParser parser) {
                while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                    if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                        String text = parser.getText();
                        if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                            if (text == 'resFromDelCr') {
                                resFromDelCr = parser.getBooleanValue();
                            } else if (text == 'pickedByCustomer') {
                                pickedByCustomer = parser.getBooleanValue();
                            } else if (text == 'trackingStatusCodes') {
                                trackingStatusCodes = parser.getBooleanValue();
                            } else if (text == 'retailer_moniker') {
                                retailer_moniker = parser.getText();
                            } else if (text == 'weight_uom') {
                                weight_uom = parser.getText();
                            } else if (text == 'packageCount') {
                                packageCount = parser.getText();
                            } else if (text == 'partner_carrier_tracking_number') {
                                partner_carrier_tracking_number = parser.getText();
                            } else if (text == 'weight') {
                                weight = parser.getDoubleValue();
                            } else if (text == 'source') {
                                source = parser.getText();
                            } else if (text == 'locale') {
                                locale = parser.getText();
                            } else if (text == 'service_desc') {
                                service_desc = parser.getText();
                            } else if (text == 'status') {
                                status = parser.getText();
                            } else if (text == 'fb_uuid') {
                                fb_uuid = parser.getText();
                            } else if (text == 'status_token') {
                                status_token = parser.getText();
                            } else if (text == 'status_desc') {
                                status_desc = parser.getText();
                            } else if (text == 'tracking_number') {
                                tracking_number = parser.getText();
                            } else if (text == 'mask_tracking_number') {
                                mask_tracking_number = parser.getText();
                            } else if (text == 'guaranteed_delivery_date') {
                                guaranteed_delivery_date = parser.getText();
                            } else if (text == 'estimated_delivery_date_end') {
                                estimated_delivery_date_end = parser.getText();
                            } else if (text == 'estimated_delivery_date_begin') {
                                estimated_delivery_date_begin = parser.getText();
                            } else if (text == 'edd_source') {
                                edd_source = parser.getText();
                            } else if (text == 'status_code') {
                                status_code = parser.getText();
                            } else if (text == 'order_number') {
                                order_number = parser.getText();
                            } else if (text == 'class_of_mail_code') {
                                class_of_mail_code = parser.getText();
                            } else if (text == 'pickup_start') {
                                pickup_start = parser.getText();
                            } else if (text == 'pickup_end') {
                                pickup_end = parser.getText();
                            } else if (text == 'ship_date') {
                                ship_date = parser.getText();
                            } else if (text == 'no_eta_message') {
                                no_eta_message = parser.getText();
                            } else if (text == 'tracking_status_code') {
                                tracking_status_code = parser.getText();
                            } else if (text == 'status_summary') {
                                status_summary = parser.getText();
                            } else if (text == 'last_status_date') {
                                last_status_date = parser.getText();
                            } else if (text == 'TrackDetail') {
                                TrackDetail = arrayOfTrackDetail(parser);
                            } else if (text == 'errors') {
                                errors = parser.getText();
                            } else if (text == 'carrier_name') {
                                carrier_name = parser.getText();
                            } else if (text == 'carrier_url') {
                                carrier_url = parser.getText();
                            } else if (text == 'carrier_id') {
                                carrier_id = parser.getText();
                            } else if (text == 'partner_carrier_name') {
                                partner_carrier_name = parser.getText();
                            } else if (text == 'partner_carrier_url') {
                                partner_carrier_url = parser.getText();
                            } else if (text == 'partner_carrier_id') {
                                partner_carrier_id = parser.getText();
                            } else if (text == 'carrier_transfer') {
                                carrier_transfer = parser.getBooleanValue();
                            } else if (text == 'service_start_day') {
                                service_start_day = parser.getIntegerValue();
                            } else if (text == 'service_end_day') {
                                service_end_day = parser.getIntegerValue();
                            } else if (text == 'carrier_holidays') {
                                carrier_holidays = parser.getText();
                            } else if (text == 'tracking_url') {
                                tracking_url = parser.getText();
                            } else if (text == 'narvar_status') {
                                narvar_status = parser.getText();
                            } else if (text == 'undeliverable') {
                                undeliverable = parser.getBooleanValue();
                            } else if (text == 'package_redirect') {
                                package_redirect = parser.getText();
                            } else if (text == 'ship_by_date') {
                                ship_by_date = parser.getText();
                            } else if (text == 'pickup_date') {
                                pickup_date = parser.getText();
                            } else if (text == 'is_label_cancelled') {
                                is_label_cancelled = parser.getBooleanValue();
                            } else if (text == 'sms_signed_up') {
                                sms_signed_up = parser.getBooleanValue();
                            } else if (text == 'fb_messenger_signed_up') {
                                fb_messenger_signed_up = parser.getBooleanValue();
                            } else if (text == 'generic_tracking') {
                                generic_tracking = parser.getBooleanValue();
                            } else if (text == 'promise_date_begin') {
                                promise_date_begin = parser.getText();
                            } else if (text == 'promise_date_end') {
                                promise_date_end = parser.getText();
                            } else if (text == 'track_Url_Tracking_Id') {
                                track_Url_Tracking_Id = parser.getText();
                            } else if (text == 'redirect_to_hold') {
                                redirect_to_hold = new Redirect_to_hold(parser);
                            } else if (text == 'is_tracking_status_codes') {
                                is_tracking_status_codes = parser.getBooleanValue();
                            } else if (text == 'schedulable') {
                                schedulable = new Schedulable(parser);
                            } else if (text == 'redirect_address') {
                                redirect_address = parser.getText();
                            } else if (text == 'slug') {
                                slug = parser.getText();
                            } else if (text == 'broadcast_messages') {
                                broadcast_messages = parser.getText();
                            } else if (text == 'signature') {
                                signature = parser.getText();
                            } else if (text == 'is_picked_by_customer') {
                                is_picked_by_customer = parser.getBooleanValue();
                            } else if (text == 'is_internal_carrier') {
                                is_internal_carrier = parser.getBooleanValue();
                            } else if (text == 'pickup_by_date') {
                                pickup_by_date = parser.getText();
                            } else if (text == 'delivery_instructions') {
                                delivery_instructions = parser.getText();
                            } else if (text == 'polling') {
                                polling = parser.getText();
                            } else if (text == 'stops') {
                                stops = parser.getText();
                            } else if (text == 'delivery_management_link') {
                                delivery_management_link = parser.getText();
                            } else if (text == 'line_package_subscription_text') {
                                line_package_subscription_text = parser.getText();
                            } else {
                                System.debug(LoggingLevel.WARN, 'Tracking_info consuming unrecognized property: '+text);
                                consumeObject(parser);
                            }
                        }
                    }
                }
            }
        }

        public class Schedulable {
            public Boolean is_schedulable {get;set;}
            public String reason {get;set;}
            public Boolean is_reschedulable {get;set;}
            public Boolean is_scheduled {get;set;}
            public Boolean is_schedulable_later {get;set;}
            public Boolean is_schedulable_api {get;set;}
            public String eligibility_status {get;set;}
            public String eligibility_message {get;set;}

            public Schedulable(JSONParser parser) {
                while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                    if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                        String text = parser.getText();
                        if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                            if (text == 'is_schedulable') {
                                is_schedulable = parser.getBooleanValue();
                            } else if (text == 'reason') {
                                reason = parser.getText();
                            } else if (text == 'is_reschedulable') {
                                is_reschedulable = parser.getBooleanValue();
                            } else if (text == 'is_scheduled') {
                                is_scheduled = parser.getBooleanValue();
                            } else if (text == 'is_schedulable_later') {
                                is_schedulable_later = parser.getBooleanValue();
                            } else if (text == 'is_schedulable_api') {
                                is_schedulable_api = parser.getBooleanValue();
                            } else if (text == 'eligibility_status') {
                                eligibility_status = parser.getText();
                            } else if (text == 'eligibility_message') {
                                eligibility_message = parser.getText();
                            } else {
                                System.debug(LoggingLevel.WARN, 'Schedulable consuming unrecognized property: '+text);
                                consumeObject(parser);
                            }
                        }
                    }
                }
            }
        }

        public class Order_items {
            public String item_id {get;set;}
            public String retailer {get;set;}
            public String sku {get;set;}
            public String name {get;set;}
            public String description {get;set;}
            public Integer quantity {get;set;}
            public String item_image {get;set;}
            public String item_url {get;set;}
            public String fulfillment_status {get;set;}
            public String item_promise_date {get;set;}
            public String attributes {get;set;}
            public String color {get;set;}
            public String size {get;set;}
            public String style {get;set;}

            public Order_items(JSONParser parser) {
                while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                    if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                        String text = parser.getText();
                        if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                            if (text == 'item_id') {
                                item_id = parser.getText();
                            } else if (text == 'retailer') {
                                retailer = parser.getText();
                            } else if (text == 'sku') {
                                sku = parser.getText();
                            } else if (text == 'name') {
                                name = parser.getText();
                            } else if (text == 'description') {
                                description = parser.getText();
                            } else if (text == 'quantity') {
                                quantity = parser.getIntegerValue();
                            } else if (text == 'item_image') {
                                item_image = parser.getText();
                            } else if (text == 'item_url') {
                                item_url = parser.getText();
                            } else if (text == 'fulfillment_status') {
                                fulfillment_status = parser.getText();
                            } else if (text == 'item_promise_date') {
                                item_promise_date = parser.getText();
                            } else if (text == 'attributes') {
                                attributes = parser.getText();
                            } else if (text == 'color') {
                                color = parser.getText();
                            } else if (text == 'size') {
                                size = parser.getText();
                            } else if (text == 'style') {
                                style = parser.getText();
                            } else {
                                System.debug(LoggingLevel.WARN, 'Order_items consuming unrecognized property: '+text);
                                consumeObject(parser);
                            }
                        }
                    }
                }
            }
        }

        public class TrackDetail_Z {

            public TrackDetail_Z(JSONParser parser) {
                while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                    if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                        String text = parser.getText();
                        if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                            {
                                System.debug(LoggingLevel.WARN, 'TrackDetail_Z consuming unrecognized property: '+text);
                                consumeObject(parser);
                            }
                        }
                    }
                }
            }
        }

        public class Items_info {
            public Integer quantity {get;set;}
            public String sku {get;set;}
            public String item_id {get;set;}

            public Items_info(JSONParser parser) {
                while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                    if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                        String text = parser.getText();
                        if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                            if (text == 'quantity') {
                                quantity = parser.getIntegerValue();
                            } else if (text == 'sku') {
                                sku = parser.getText();
                            } else if (text == 'item_id') {
                                item_id = parser.getText();
                            } else {
                                System.debug(LoggingLevel.WARN, 'Items_info consuming unrecognized property: '+text);
                                consumeObject(parser);
                            }
                        }
                    }
                }
            }
        }

        public class TrackDetail {
            public String shipmentLocationType {get;set;}
            public String error {get;set;}
            public String error_code {get;set;}
            public String event {get;set;}
            public String event_code {get;set;}
            public String event_date {get;set;}
            public String event_city {get;set;}
            public String event_state {get;set;}
            public String event_country_code {get;set;}
            public String event_date_offset {get;set;}
            public Track_status_code_mapping track_status_code_mapping {get;set;}
            public String track_status_code_raw {get;set;}

            public TrackDetail(JSONParser parser) {
                while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                    if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                        String text = parser.getText();
                        if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                            if (text == 'shipmentLocationType') {
                                shipmentLocationType = parser.getText();
                            } else if (text == 'error') {
                                error = parser.getText();
                            } else if (text == 'error_code') {
                                error_code = parser.getText();
                            } else if (text == 'event') {
                                event = parser.getText();
                            } else if (text == 'event_code') {
                                event_code = parser.getText();
                            } else if (text == 'event_date') {
                                event_date = parser.getText();
                            } else if (text == 'event_city') {
                                event_city = parser.getText();
                            } else if (text == 'event_state') {
                                event_state = parser.getText();
                            } else if (text == 'event_country_code') {
                                event_country_code = parser.getText();
                            } else if (text == 'event_date_offset') {
                                event_date_offset = parser.getText();
                            } else if (text == 'track_status_code_mapping') {
                                track_status_code_mapping = new Track_status_code_mapping(parser);
                            } else if (text == 'track_status_code_raw') {
                                track_status_code_raw = parser.getText();
                            } else {
                                System.debug(LoggingLevel.WARN, 'TrackDetail consuming unrecognized property: '+text);
                                consumeObject(parser);
                            }
                        }
                    }
                }
            }
        }

        public class Order_info {
            public String order_number {get;set;}
            public String order_date {get;set;}
            public List<Order_items> order_items {get;set;}
            public List<Shipments> shipments {get;set;}
            public Customer customer {get;set;}

            public Order_info(JSONParser parser) {
                while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                    if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                        String text = parser.getText();
                        if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                            if (text == 'order_number') {
                                order_number = parser.getText();
                            } else if (text == 'order_date') {
                                order_date = parser.getText();
                            } else if (text == 'order_items') {
                                order_items = arrayOfOrder_items(parser);
                            } else if (text == 'shipments') {
                                shipments = arrayOfShipments(parser);
                            } else if (text == 'customer') {
                                customer = new Customer(parser);
                            } else {
                                System.debug(LoggingLevel.WARN, 'Order_info consuming unrecognized property: '+text);
                                consumeObject(parser);
                            }
                        }
                    }
                }
            }
        }

        public class Shipments {
            public String carrier_service_code {get;set;}
            public String ship_method {get;set;}
            public List<Items_info> items_info {get;set;}
            public String promise_date {get;set;}
            public String carrier {get;set;}
            public String tracking_number {get;set;}
            public String type {get;set;}
            public String status {get;set;}

            public Shipments(JSONParser parser) {
                while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                    if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                        String text = parser.getText();
                        if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                            if (text == 'carrier_service_code') {
                                carrier_service_code = parser.getText();
                            } else if (text == 'ship_method') {
                                ship_method = parser.getText();
                            } else if (text == 'items_info') {
                                items_info = arrayOfItems_info(parser);
                            } else if (text == 'promise_date') {
                                promise_date = parser.getText();
                            } else if (text == 'carrier') {
                                carrier = parser.getText();
                            } else if (text == 'tracking_number') {
                                tracking_number = parser.getText();
                            } else if (text == 'type') {
                                type = parser.getText();
                            } else if (text == 'status') {
                                status = parser.getText();
                            } else {
                                System.debug(LoggingLevel.WARN, 'Shipments consuming unrecognized property: '+text);
                                consumeObject(parser);
                            }
                        }
                    }
                }
            }
        }


        public static NF_NarvarOrderResponse parse(String json) {
            System.JSONParser parser = System.JSON.createParser(json);
            return new NF_NarvarOrderResponse(parser);
        }

        public static void consumeObject(System.JSONParser parser) {
            Integer depth = 0;
            do {
                System.JSONToken curr = parser.getCurrentToken();
                if (curr == System.JSONToken.START_OBJECT ||
                        curr == System.JSONToken.START_ARRAY) {
                    depth++;
                } else if (curr == System.JSONToken.END_OBJECT ||
                        curr == System.JSONToken.END_ARRAY) {
                    depth--;
                }
            } while (depth > 0 && parser.nextToken() != null);
        }





        private static List<Order_items> arrayOfOrder_items(System.JSONParser p) {
            List<Order_items> res = new List<Order_items>();
            if (p.getCurrentToken() == null) p.nextToken();
            while (p.nextToken() != System.JSONToken.END_ARRAY) {
                res.add(new Order_items(p));
            }
            return res;
        }








        private static List<Shipments> arrayOfShipments(System.JSONParser p) {
            List<Shipments> res = new List<Shipments>();
            if (p.getCurrentToken() == null) p.nextToken();
            while (p.nextToken() != System.JSONToken.END_ARRAY) {
                res.add(new Shipments(p));
            }
            return res;
        }


        private static List<Messages> arrayOfMessages(System.JSONParser p) {
            List<Messages> res = new List<Messages>();
            if (p.getCurrentToken() == null) p.nextToken();
            while (p.nextToken() != System.JSONToken.END_ARRAY) {
                res.add(new Messages(p));
            }
            return res;
        }



        private static List<TrackDetail_Z> arrayOfTrackDetail_Z(System.JSONParser p) {
            List<TrackDetail_Z> res = new List<TrackDetail_Z>();
            if (p.getCurrentToken() == null) p.nextToken();
            while (p.nextToken() != System.JSONToken.END_ARRAY) {
                res.add(new TrackDetail_Z(p));
            }
            return res;
        }





        private static List<Items_info> arrayOfItems_info(System.JSONParser p) {
            List<Items_info> res = new List<Items_info>();
            if (p.getCurrentToken() == null) p.nextToken();
            while (p.nextToken() != System.JSONToken.END_ARRAY) {
                res.add(new Items_info(p));
            }
            return res;
        }

        private static List<TrackDetail> arrayOfTrackDetail(System.JSONParser p) {
            List<TrackDetail> res = new List<TrackDetail>();
            if (p.getCurrentToken() == null) p.nextToken();
            while (p.nextToken() != System.JSONToken.END_ARRAY) {
                res.add(new TrackDetail(p));
            }
            return res;
        }

        private static List<Tracking_info> arrayOfTracking_info(System.JSONParser p) {
            List<Tracking_info> res = new List<Tracking_info>();
            if (p.getCurrentToken() == null) p.nextToken();
            while (p.nextToken() != System.JSONToken.END_ARRAY) {
                res.add(new Tracking_info(p));
            }
            return res;
        }

    public Boolean isError(){
        System.debug('>>> ERROR CHECK: ' + messages);
        if (messages == null) {
            System.debug('>> Failed to receive messages - checking for populated order items');
            return (order_info == null);
        }
        else if (messages.size() > 0) {
            return !(messages[0].code == 'response.status.success');
        }
        return true; // If no messages are found, there is an error
    }

    //public static NF_NarvarOrderResponse parse(String json) {
    //    return (NF_NarvarOrderResponse) System.JSON.deserialize(json, NF_NarvarOrderResponse.class);
    //}


}