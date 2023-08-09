public class NF_DirectMailUndeliverableTriggerHelper{
    public static void handleAfterInsert(List<DirectMailUndeliverablesStaging__c> newList){
        List<String> LoyaltyIdList = new List<String>();
        List<Contact> updatedContactList = new List<Contact>();
        for (DirectMailUndeliverablesStaging__c dmus : newList ){
            if (dmus.LoyaltyId__c != null)
                LoyaltyIdList.add(dmus.LoyaltyId__c);
        }

        Log.push('***LoyaltyIdList:' + LoyaltyIdList);
        List<Contact> contactList = [SELECT Id, LoyaltyID__c, DirectMailUndeliverable__c
                                     FROM Contact
                                     WHERE LoyaltyID__c IN:LoyaltyIdList AND DirectMailUndeliverable__c = false];

        Log.push('***contactList:' + contactList);
        if (contactList.size() > 0){
            for (Contact con : contactList){
                con.DirectMailUndeliverable__c = true;
                updatedContactList.add(con);
            }
        }

        Log.push('***updatedContactList:' + updatedContactList);
        Logger.logDebug();
        if (updatedContactList.size() > 0){
            update updatedContactList;
        }
    }

}