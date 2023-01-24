/**
NASSC-1105
NASSC-1447
*/

public class SignUpActivity {
	public Id contactId;
    public DateTime eventDate;
    public String dataSource;
    public String BrandId;
	    
    public static void logSignUpActivity(List<SignUpActivity> activityList){

        List <LoyaltySettings__mdt> SignUpEnabledMDTList = new List<LoyaltySettings__mdt>();
        SignUpEnabledMDTList = [select BrandId__c from LoyaltySettings__mdt where LogSignupActivity__c = true];
        Set <String> SignUpActivityEnabledBrands = new Set<String>();
        if (SignUpEnabledMDTList.size()>0) {
            for (LoyaltySettings__mdt LS : SignUpEnabledMDTList){
                SignUpActivityEnabledBrands.add(LS.BrandId__c);
            }
        }
        
        // get the generated loyalty id of contact
        List<ID> contactIdList = new List<ID>();
        for(SignUpActivity activity: activityList){
            contactIdList.add(activity.contactId);
        }
        
        Map <Id,Contact> newIDContactMap;
        if (!contactIdList.isEmpty()) newIDContactMap = new Map<Id,Contact>([SELECT Id,  LoyaltyID__c FROM Contact WHERE Id IN :contactIdList]);

        List<TrackerEvents__c> eventList = new List<TrackerEvents__c>();
        
        for(SignUpActivity activity: activityList){
 
            if (SignUpActivityEnabledBrands.contains(activity.BrandId)) {
                
                String LoyaltyId = '';   
                if(newIDContactMap.size()>0) LoyaltyId = newIDContactMap.get(activity.contactId).LoyaltyID__c;
                
                TrackerEvents__c event = new TrackerEvents__c(EventDate__c = activity.eventDate, Customer__c = activity.ContactId, DataSource__c = activity.DataSource, BrandId__c = activity.BrandId, CustomerId__c = activity.ContactId, LoyaltyId__c = LoyaltyId);
                eventList.add(event);
            }
        }
        
        if(eventList.size()>0){
            insert eventList;
        }
    }
    
    //Set signupActicity
    public Static SignUpActivity signupActivity(Id conId, String dataSource, String BrandId){
        SignUpActivity act = new SignUpActivity();
        act.ContactId = conId;
        act.DataSource = datasource;
        act.EventDate = System.now();
        act.BrandId = BrandId;        
        
        return act;        
    }
}