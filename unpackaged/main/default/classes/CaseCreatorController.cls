public class CaseCreatorController {
    
    private ApexPages.StandardController standardController;
    
    public CaseCreatorController(ApexPages.StandardController standardController){
                this.standardController = standardController;
    }
    
    public PageReference createSupportCase(){
        // Apex code for handling record from a Detail page goes here
        Id contactRecordId = standardController.getId();
        System.debug('Contact ID:'+contactRecordId);
        Contact[] contacts = [SELECT Id,Brand_Id__c,RingCentralChannel__c,Phone,MobilePhone,OtherPhone FROM Contact WHERE id = :contactRecordId];
       	Contact selectedContact = contacts[0];
        System.debug('selectedContact:'+selectedContact);
        String recordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Support Case').getRecordTypeId();
        //pick first not null phone number of contact in order of priority, Phone >MobilePhone>OtherPhone
        String incomingPhoneNumber = String.isNotBlank(selectedContact.Phone)?selectedContact.Phone:selectedContact.MobilePhone;  
        if(String.isBlank(incomingPhoneNumber)){ //if still blank after checking phone and mobilePhone, default to otherPhone
            incomingPhoneNumber = selectedContact.OtherPhone;
        }
        Case c = new Case();
        c.RecordTypeId = recordTypeId;
        c.Origin = 'Phone';
        c.Brand__c = selectedContact.Brand_Id__c;
        c.SuppliedPhone = incomingPhoneNumber;
        if(String.isNotBlank(selectedContact.RingCentralChannel__c)){
           c.Channel__c = selectedContact.RingCentralChannel__c;
        }
        c.ContactId = contactRecordId;
        insert c;
        String urlvalue=Apexpages.currentPage().getUrl();
        System.debug('current page URL:'+urlvalue);

		ApexPages.StandardController sc = new ApexPages.StandardController(c);
        PageReference pr= sc.view();
        pr.setRedirect(true);
        return pr;
    }
   
    /*
    public PageReference save() {
        System.debug('Hitting save in CaseCreator');
        PageReference detailPage = standardController.save();
        if (detailPage != null) {
            // Construct URL of edit page or whatever other page you want
            PageReference editPage = new PageReference(detailPage.getUrl() + '/e');
            return editPage;
        } else {
            return detailPage;
        }
    }*/
    
    

 /*
    public static PageReference Search(){
        // Get the caller's number
       String ani = ApexPages.CurrentPage().getParameters().get('ANI');
         
        System.debug('received ani '+ani);
        // Search for contacts with that phone number
        Contact[] contacts = [SELECT Id FROM Contact WHERE Phone = :ani];
        
        // Create a Case and automatically populate some of the fields
                //Contact[] contacts = [SELECT Id FROM Contact WHERE id = :I];

        Case c = new Case();
        //c.Subject = 'Case created for inbound call from: ' + ani;
        c.Origin = 'Phone';
         
        // If we have a single match create and link to Case. Then pop the Case in edit mode.
        If (contacts.Size() > 0) {
            c.ContactId = contacts[0].Id;
        }
        insert c;
 
        return new PageReference('/' + c.Id + '/e');
    }*/
}