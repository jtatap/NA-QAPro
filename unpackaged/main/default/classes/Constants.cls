public class Constants {
    // Privacy case related constants
    public static string privacyCaseType = SYSTEM.LABEL.Privacy;
    public static string marketingCaseType = SYSTEM.LABEL.Marketing;
    public static string privacyIntervalSettingName = SYSTEM.LABEL.PrivacyIntervalSetting;
    public static string privacyContactGenericRecordSettingName = SYSTEM.LABEL.privacyContact;
    public static string AccountGenericRecordSettingName = SYSTEM.LABEL.genericAccount;
    public static Id brandRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Brand').getRecordTypeId();
    public static Id privacyRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Privacy_Request').getRecordTypeId();
    public static Id privacyReadOnlyRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Privacy_Request_Read_Only').getRecordTypeId();
    public static Id dataOwnerCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Data_Owner_Request').getRecordTypeId();
    public static Id dataOwnerContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Data_Owner').getRecordTypeId();
    public static Id supportCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support_Case').getRecordTypeId();
    public static String modifyBrandPermission = SYSTEM.LABEL.Manage_Brands;
    public static String modifyDataOwnerPermission = SYSTEM.LABEL.Manage_Data_Owners;
    // DO NOT DO THIS.
    //THE LIST DOES NOT CONTAIN THE IDS UNLESS YOU DEBUG OUT THE LIST BEFORE USING IT
    //public static List<String> privacyRecordTypeIds = new List<String>{dataOwnerCaseRecordTypeId, privacyRecordTypeId};
    public static String accessRequestSubType = SYSTEM.LABEL.Access_My_Data1;
    public static String deletionRequestSubType = SYSTEM.LABEL.Delete_My_Data;
    public static String rectifyRequestSubType = 'Rectify My Data';
    public static String doNotSellorShare = 'Do Not Sell/Share';
    public static String dataOwnerRequestSubType = SYSTEM.LABEL.Data_Owner_Request;
    public static String unsubscribeRequestSubType = SYSTEM.LABEL.Unsubscribe;
    public static String privacyEmailSubType = SYSTEM.LABEL.Privacy_Email;
    public static List<String> parentPrivacyCaseSubTypes = new List<String> {accessRequestSubType, deletionRequestSubType};
    public static String dataOwnerInternal = SYSTEM.LABEL.Internal;
    public static String dataOwnerExternal = SYSTEM.LABEL.External;
    public static String dataOwnerExternalPVHManaged = SYSTEM.LABEL.External_Managed_By_PVH;
    public static String dataOwnerSupplemental = SYSTEM.LABEL.Supplemental;
    public static List<String> dataOwnerExternalTypes = new List<String>{dataOwnerExternal, dataOwnerExternalPVHManaged};
    public static List<String> privacyNACountries = new List<String>{'United States of America (USA)', 'Canada', 'Mexico'};
    public static List<String> privacyHighPriorityStates = new List<String>{'California'};
    public static String nonActionablePrivacyCaseQueue = SYSTEM.LABEL.Unverified_Privacy_Request;
    public static String spamQueue =SYSTEM.LABEL.Spam_Queue; 
    public static String defaultQueue =SYSTEM.LABEL.Default_Case_Queue; 
    public static String lowPriorityPrivacyCaseQueue = SYSTEM.LABEL.Privacy_Request;
    public static String highPriorityPrivacyCaseQueue = SYSTEM.LABEL.High_Priority_Privacy_Request;
    public static String unsubscribeCaseQueue = SYSTEM.LABEL.Unsubscribe_Queue;
    public static String unassignedPrivacyQueue = SYSTEM.LABEL.Unassigned_Privacy;
    public static List<String> privacyCaseQueueNames = new List<String>{nonActionablePrivacyCaseQueue, lowPriorityPrivacyCaseQueue, highPriorityPrivacyCaseQueue, unsubscribeCaseQueue, unassignedPrivacyQueue, spamQueue, defaultQueue};

    // Brand Names
    public static string calvinKlein = SYSTEM.LABEL.Calvin_Klein;
    public static string tommyHilfiger = SYSTEM.LABEL.Tommy_Hilfiger;

    // Privacy Email Template Names
    public static string A1RequestEmail = SYSTEM.LABEL.A1_Identity_Verification_Request;
    public static string A2RequestEmail = SYSTEM.LABEL.A2_No_never_requested_automated_response_sent_to_the_consumer;
    public static string A3RequestEmail = SYSTEM.LABEL.A3_Identity_verification_timeout;
    public static string A5RequestEmail = SYSTEM.LABEL.A5_Perfect_Match;
    public static string A7RequestEmail = SYSTEM.LABEL.A7_CSR_alerts_consumer_that_there_is_no_data;
    public static string A8RequestEmail = SYSTEM.LABEL.A8_No_Match_Non_EU_NA_Consumer_CSR_alerts_non_NA_EU;
    public static string A10RequestEmail = SYSTEM.LABEL.A10_Automated_email_out_if_consumer_does_not_respond_to_request_for_physical_ad;
    //delete
    public static string D1RequestEmail = SYSTEM.LABEL.D1_SFSC_send_automated_validation_email;
    public static string D3RequestEmail = SYSTEM.LABEL.D3_Yes_Perfect_Match_CSR_alerts_data_owners_to_delete_records;
    public static string D4RequestEmail = SYSTEM.LABEL.D4_CSR_responds_to_consumer_that_record_has_been_deleted;
    public static string D5RequestEmail = SYSTEM.LABEL.D5_CSR_alerts_consumer_that_there_is_not_record_to_be_deleted;
    //update
	public static string U1RequestEmail = 'U1 SFSC send automated validation email';
	public static string U3RequestEmail = 'U3 -Yes, Perfect Match -> CSR alerts data owners to correct records';
    public static string U4RequestEmail = 'U4 - CSR responds to consumer that record has been corrected';
    public static string U5RequestEmail = 'U5 - CSR alerts consumer that there is not record to be corrected';
    //Advertising/Sharing Opt-Out
    public static string S3RequestEmail = 'S3 -Yes, Perfect Match -> CSR alerts data owners to delete records';
    public static string S4RequestEmail = 'S4 - CSR responds to consumer that record has been deleted';
    public static string S5RequestEmail = 'S5 - CSR alerts consumer that there is not record to be deleted';
    //TODO: D7 missing!
    public static string D7RequestEmail = SYSTEM.LABEL.D7_Never_Requested;
    public static string D8RequestEmail = SYSTEM.LABEL.D8_Automated_email_out_if_consumer_does_not_respond;
    public static string D9RequestEmail = SYSTEM.LABEL.D9_No_Match_Non_EU_NA_Consumer_CSR_alerts_non_NA_EU_consumer;
    public static string D10RequestEmail = SYSTEM.LABEL.D10_Automated_email_out_if_consumer_does_not_respond_to_request_for_phy_address;
    // TEMP: This next one is intended to be a CSR Reminder but that's not in place yet.
    public static string CSRDeletionReminderEmail = SYSTEM.LABEL.Deletion_Data_Owner_Reminder_Email;
    public static string deletionDataOwnerReminderEmail = SYSTEM.LABEL.Deletion_Data_Owner_Reminder_Email;
    public static string updationDataOwnerReminderEmail = 'Correcting Data Owner Reminder Email';//update
    public static string doNotSellorShareDataOwnerReminderEmail = 'Advertising/Sharing Opt-Out Deleting Data Owner Reminder Email';//donot sell/share
    public static string accessDataOwnerReminderEmail = SYSTEM.LABEL.Access_Data_Owner_Reminder_Email;
    public static string deletionDataOwnerEscalationEmail = SYSTEM.LABEL.Deletion_Data_Owner_Reminder_Email_Escalation;
    public static string updationDataOwnerEscalationEmail = 'Correcting Data Owner Reminder Email Escalation';//update
    public static string doNotSellorShareDataOwnerEscalationEmail = 'Advertising/Sharing Opt-Out Data Owner Reminder Email Escalation';//donot sell/share
    public static string accessDataOwnerEscalationEmail = SYSTEM.LABEL.Access_Data_Owner_Reminder_Email_Escalation;
    public static string U1UnsubscribeEmail = SYSTEM.LABEL.U1_Unsubscribe_Verification;
    public static string U2UnsubscribeEmail = SYSTEM.LABEL.U2_No_Never_requested_an_unsubscribe;
    public static string U3UnsubscribeEmail = SYSTEM.LABEL.U3_Identity_verification_timeout;
    public static string U4UnsubscribeEmail = SYSTEM.LABEL.U4_CSR_alerts_consumer_that_no_email_was_found;
    public static string U5UnsubscribeEmail = SYSTEM.LABEL.U5_Unsubscribe_Completed;

    // Privacy Status-related constants
    public static String newPrivacyStatus = SYSTEM.LABEL.New;
    public static String openStatus = SYSTEM.LABEL.Open;
    public static String waitingForResponse = SYSTEM.LABEL.Pending;
    public static String dataOwnersContacted = SYSTEM.LABEL.Processing_Request;
    public static String reviewResponseStatus = 'ReviewResponse';
    public static String resolved = SYSTEM.LABEL.Resolved;
    public static String closed = SYSTEM.LABEL.Closed;
    public static List<String> privacyCaseCompletedStatuses = new List<String> {resolved, closed};

    // Privacy resolution types
    public static String privacyResolvedNoResponse = SYSTEM.LABEL.No_Response;
    public static String privacyResolvedRejectedRequest = SYSTEM.LABEL.Rejected_Request;
    public static String privacyResolvedStalled = SYSTEM.LABEL.No_Response_to_follow_up;
    public static String privacyResolvedNoDataFound = SYSTEM.LABEL.Data_Not_Found;
    public static String privacyResolvedDataProvided = SYSTEM.LABEL.User_Data_Provided;
    public static String privacyResolvedDataDeleted = SYSTEM.LABEL.User_Data_Deleted;
    public static String privacyResolvedDataUpdated = 'User Data Corrected';//Update My Data

}