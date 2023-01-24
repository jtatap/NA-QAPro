/******************************************************************************
* @Description: insert record into TrackerEvents__c for SignUps
* @Date		  : April 13, 2020
* @JIRA		  : NASSC-1665
*
******************************************************************************/
public class LogSignupActivities{

    @InvocableMethod(label='invocable LogSignUpActivity' description='pass thru method to call LogSignupActivities')
    public static void LogSignUpActivity(List<SignUpActivityData> contactSignUpData) {

        String jsonString = json.serialize(contactSignUpData);
       	createSignUpActivity(jsonString);
    }
    
    @future
    public static void createSignUpActivity(String contactDataAsString){
        System.debug('***inside createSignUpActivity');
        List<TrackerEvents__c> eventList = new List<TrackerEvents__c>();
        List<SignUpActivityData> conList = (List<SignUpActivityData>)Json.deserialize(contactDataAsString,List<SignUpActivityData>.class);
        Map<String,Boolean> mapBrandLogSignUp = new Map<String,Boolean>();
        List<LoyaltySettings__mdt> listLoyalty = [Select Id, BrandId__c, LogSignupActivity__c from LoyaltySettings__mdt];
        for(LoyaltySettings__mdt loyalRecord : listLoyalty){
            mapBrandLogSignUp.put(loyalRecord.BrandId__c,loyalRecord.LogSignupActivity__c);
        }
        System.debug('^^^mapBrandLogSignUp = '+mapBrandLogSignUp);
        for(SignUpActivityData signUpData : conList){
            //check if LogSignupActivity__c is CHECKED for brand
            System.debug('^^^Status of Log = '+mapBrandLogSignUp.get(signUpData.BrandId));
            if(mapBrandLogSignUp.get(signUpData.BrandId)){
                TrackerEvents__c eventRecord = new TrackerEvents__c();
                eventRecord.Type__c = 'SignUp';
                eventRecord.DataSource__c = signUpData.dataSource;
                eventRecord.CustomerId__c = signUpData.ContactId;
                eventRecord.BrandId__c 	  = signUpData.BrandId;
                eventRecord.EventDate__c  = signUpData.eventDate;
                eventRecord.LoyaltyId__c  = signUpData.loyaltyId;
                eventRecord.StoreCode__c  = signUpData.StoreCode;
                eventList.add(eventRecord);
            }
            else{
                System.debug('^^^LogSignupActivity__c is DISABLED for this Brand');
            }
        }
        
        try {
            if(eventList.size() > 0){
                insert eventList;
                System.debug('***Records Inserted: TrackerEvents__c'); 
            }            
        }
        catch (Exception e) {
            System.debug('An exception occurred while inserting records in : TrackerEvents__c' + e.getMessage());
        }
       
    }
  
    public class SignUpActivityData {
       	@InvocableVariable
        public Id ContactId;
        @InvocableVariable
        public DateTime eventDate;
        @InvocableVariable
        public String dataSource;
        @InvocableVariable
        public String BrandId;
        @InvocableVariable
        public String loyaltyId;
        @InvocableVariable
        public String StoreCode;
       
    }
}