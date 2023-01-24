public class Constants {
    // Privacy case related constants
    public static string privacyCaseType = 'Privacy';
    public static string marketingCaseType = 'Marketing';
    public static string privacyIntervalSettingName = 'PrivacyIntervalSetting';
    public static string privacyContactGenericRecordSettingName = 'privacyContact';
    public static string AccountGenericRecordSettingName = 'genericAccount';
    public static Id brandRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Brand').getRecordTypeId();
    public static Id privacyRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Privacy_Request').getRecordTypeId();
    public static Id privacyReadOnlyRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Privacy_Request_Read_Only').getRecordTypeId();
    public static Id dataOwnerCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Data_Owner_Request').getRecordTypeId();
    public static Id dataOwnerContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Data_Owner').getRecordTypeId();
    public static Id supportCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support_Case').getRecordTypeId();
    public static String modifyBrandPermission = 'Manage_Brands';
    public static String modifyDataOwnerPermission = 'Manage_Data_Owners';
    // DO NOT DO THIS.
    //THE LIST DOES NOT CONTAIN THE IDS UNLESS YOU DEBUG OUT THE LIST BEFORE USING IT
    //public static List<String> privacyRecordTypeIds = new List<String>{dataOwnerCaseRecordTypeId, privacyRecordTypeId};
    public static String accessRequestSubType = 'Access My Data';
    public static String deletionRequestSubType = 'Delete My Data';
	public static String rectifyRequestSubType = 'Rectify My Data';
    public static String doNotSellorShare = 'Do Not Sell/Share';
    public static String dataOwnerRequestSubType = 'Data Owner Request';
    public static String unsubscribeRequestSubType = 'Unsubscribe';
    public static String privacyEmailSubType = 'Privacy Email';
    public static List<String> parentPrivacyCaseSubTypes = new List<String> {accessRequestSubType, deletionRequestSubType,rectifyRequestSubType};
    public static String dataOwnerInternal = 'Internal';
    public static String dataOwnerExternal = 'External';
    public static String dataOwnerExternalPVHManaged = 'External - Managed By PVH';
    public static String dataOwnerSupplemental = 'Supplemental';
    public static List<String> dataOwnerExternalTypes = new List<String>{dataOwnerExternal, dataOwnerExternalPVHManaged};
    public static List<String> privacyNACountries = new List<String>{'United States of America (USA)', 'Canada', 'Mexico'};
    public static List<String> privacyHighPriorityStates = new List<String>{'California'};
    public static String nonActionablePrivacyCaseQueue = 'Unverified_Privacy_Request';
    public static String lowPriorityPrivacyCaseQueue = 'Privacy_Request';
    public static String highPriorityPrivacyCaseQueue = 'High_Priority_Privacy_Request';
    public static String unsubscribeCaseQueue = 'Unsubscribe_Queue';
    public static String unassignedPrivacyQueue = 'Unassigned_Privacy';
    public static List<String> privacyCaseQueueNames = new List<String>{nonActionablePrivacyCaseQueue, lowPriorityPrivacyCaseQueue, highPriorityPrivacyCaseQueue, unsubscribeCaseQueue, unassignedPrivacyQueue};

    // Brand Names
    public static string calvinKlein = 'Calvin Klein';
    public static string tommyHilfiger = 'Tommy Hilfiger';

    // Privacy Email Template Names
    public static string A1RequestEmail = 'A1 - Identity Verification Request';
    public static string A2RequestEmail = 'A2 - No never requested -> automated response sent to the consumer';
    public static string A3RequestEmail = 'A3 - Identity verification timeout';
    public static string A5RequestEmail = 'A5 - Perfect Match';
    public static string A7RequestEmail = 'A7 - CSR alerts consumer that there is no data';
    public static string A8RequestEmail = 'A8 - No Match -> Non EU/NA Consumer -> CSR alerts non NA/EU';
    public static string A10RequestEmail = 'A10 -Automated email out if consumer does not respond to request for physical ad';
	//delete
	public static string D1RequestEmail = 'D1 SFSC send automated validation email';
	public static string D3RequestEmail = 'D3 -Yes, Perfect Match -> CSR alerts data owners to delete records';
    public static string D4RequestEmail = 'D4 - CSR responds to consumer that record has been deleted';
    public static string D5RequestEmail = 'D5 - CSR alerts consumer that there is not record to be deleted';
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
    public static string D7RequestEmail = 'D7 - Never Requested';
    public static string D8RequestEmail = 'D8 - Automated email out if consumer does not respond';
    public static string D9RequestEmail = 'D9 -No Match -> Non EU/NA Consumer -> CSR alerts non NA/EU consumer';
    public static string D10RequestEmail = 'D10-Automated email out if consumer does not respond to request for phy address';
    // TEMP: This next one is intended to be a CSR Reminder but that's not in place yet.
    public static string CSRDeletionReminderEmail = 'Deletion Data Owner Reminder Email';
    public static string deletionDataOwnerReminderEmail = 'Deletion Data Owner Reminder Email';//delete
	public static string updationDataOwnerReminderEmail = 'Correcting Data Owner Reminder Email';//update
    public static string doNotSellorShareDataOwnerReminderEmail = 'Advertising/Sharing Opt-Out Deleting Data Owner Reminder Email';//donot sell/share
	public static string accessDataOwnerReminderEmail = 'Access Data Owner Reminder Email';
    public static string deletionDataOwnerEscalationEmail = 'Deletion Data Owner Reminder Email Escalation';//delete
	public static string updationDataOwnerEscalationEmail = 'Correcting Data Owner Reminder Email Escalation';//update
    public static string doNotSellorShareDataOwnerEscalationEmail = 'Advertising/Sharing Opt-Out Data Owner Reminder Email Escalation';//donot sell/share
	public static string accessDataOwnerEscalationEmail = 'Access Data Owner Reminder Email Escalation';
    public static string U1UnsubscribeEmail = 'U1 - Unsubscribe Verification';
    public static string U2UnsubscribeEmail = 'U2 – No, Never requested an unsubscribe';
    public static string U3UnsubscribeEmail = 'U3 - Identity verification timeout';
    public static string U4UnsubscribeEmail = 'U4 - CSR alerts consumer that no email was found';
    public static string U5UnsubscribeEmail = 'U5 – Unsubscribe Completed';

    // Privacy Status-related constants
    public static String newPrivacyStatus = 'New';
    public static String openStatus = 'Open';
    public static String waitingForResponse = 'Pending';
    public static String dataOwnersContacted = 'Processing Request';
    public static String reviewResponseStatus = 'ReviewResponse';
    public static String resolved = 'Resolved';
    public static String closed = 'Closed';
    public static List<String> privacyCaseCompletedStatuses = new List<String> {resolved, closed};

    // Privacy resolution types
    public static String privacyResolvedNoResponse = 'No Response';
    public static String privacyResolvedRejectedRequest = 'Rejected Request';
    public static String privacyResolvedStalled = 'No Response to follow-up';
    public static String privacyResolvedNoDataFound = 'Data Not Found';
    public static String privacyResolvedDataProvided = 'User Data Provided';
    public static String privacyResolvedDataDeleted = 'User Data Deleted';//Delete My Data
    public static String privacyResolvedDataUpdated = 'User Data Corrected';//Update My Data

}