trigger get_accountId on Contact (before insert, before update) {

    if (utilityClass.triggerEnabled( String.valueOf(this).substring(0,String.valueOf(this).indexOf(':')))) {

        Set<String> custIds = new Set<String>();
        List<Account> newAccountList = new List<Account>();
        Id customerAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        for (Contact cont : Trigger.new) {
            if (cont.Customer_Id__c != null) custIds.add(cont.Customer_Id__c);
        }


        if (custIds.size() > 0) {
            Map<String, Id> accMap = new Map<String, Id>();

            for (Account acc : [Select Name, Customer_Id__c, Id from Account Where Customer_Id__c in:custIds]) {
                accMap.put(acc.Customer_Id__c, acc.id);
            }
            Set<String> accCustomerIdsSet = new Set<String>();
            for (Contact myContact : Trigger.new) {
                if ((myContact.Customer_Id__c != null) && (accMap.get(myContact.Customer_Id__c) == null) && (!accCustomerIdsSet.contains(myContact.Customer_Id__c))) {
                    Account acc = new Account();

                    if (myContact.FirstName != null) acc.FirstName__c = myContact.FirstName; else acc.FirstName__c = 'Unknown';
                    if (myContact.LastName != null) acc.LastName__c = myContact.LastName; else acc.LastName__c = 'Unknown';
                    acc.Name = acc.FirstName__c + ' ' + acc.LastName__c;
                    acc.Status__c = 'ACTIVE';
                    acc.RecordTypeId = customerAccountRecordTypeId;
                    acc.Customer_Id__c = myContact.Customer_Id__c;

                    newAccountList.add(acc);
                    accCustomerIdsSet.add(myContact.Customer_Id__c);


                }

            }
            if (newAccountList.size() > 0) {
                insert newAccountList;
                for (Account a : newAccountList) {
                    accMap.put(a.Customer_Id__c, a.id);
                }
            }

            for (Contact myContact : Trigger.new) {

                if ((myContact.Customer_Id__c != null) && (accMap.get(myContact.Customer_Id__c) != null)) {
                    myContact.AccountId = accMap.get(myContact.Customer_Id__c);

                }

            }


        }
    }
}