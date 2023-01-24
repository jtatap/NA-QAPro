trigger ZenDeskCaseDMTrigger on Case (before insert) {

        Map<String, Contact> ZdTnCContactMap = new Map<String, Contact>();
        Map<String, Contact> ZdPVHContactMap = new Map<String, Contact>();
        Set<String> setCaseZdTnCUserIds = new Set<String>();
        Set<String> setCaseZdPVHUserIds = new Set<String>();
        Id zdPVHRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ZdPVH').getRecordTypeId();
        Id zdTnCRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ZdTnC').getRecordTypeId();

        for(Case newCase : Trigger.New) {
           if (newCase.ZdTnCTicketId__c != null ) {
               setCaseZdTnCUserIds.add(newCase.ZdTnCUserId__c) ;
               newCase.RecordTypeId = zdTnCRecordTypeId;
           }
           if (newCase.ZdPVHTicketId__c != null ) {
               setCaseZdPVHUserIds.add(newCase.ZdPVHUserId__c) ;
               newCase.RecordTypeId = zdPVHRecordTypeId;

           }
            
        }

        for (Contact c: [SELECT Id, AccountId, ZdTnCUserId__c, ZdPVHUserId__c
                                FROM Contact
                                WHERE ZdTnCUserId__c IN  :setCaseZdTnCUserIds OR ZdPVHUserId__c IN :setCaseZdPVHUserIds ]){
            if(c.ZdTnCUserId__c != null)   ZdTnCContactMap.put(c.ZdTnCUserId__c,c);
            if(c.ZdPVHUserId__c!=null)  ZdPVHContactMap.put(c.ZdPVHUserId__c,c);


        }

        
        for(Case newCase : Trigger.new) {
            Contact con;
            if(newCase.ZdTnCUserId__c !=null && ZdTnCContactMap.containsKey(newCase.ZdTnCUserId__c)){
                con = ZdTnCContactMap.get(newCase.ZdTnCUserId__c);
            } else if(newCase.ZdPVHUserId__c !=null && ZdPVHContactMap.containsKey(newCase.ZdPVHUserId__c )!=null){
                con = ZdPVHContactMap.get(newCase.ZdPVHUserId__c);
            }



            if(con != null) {
                newCase.ContactId = con.id;
                newCase.AccountId = con.AccountId;
            }

        }

}