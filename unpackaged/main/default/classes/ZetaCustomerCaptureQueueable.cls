/**
 * Created by dimitrisavelieff on 2019-10-15.
 */

public with sharing class ZetaCustomerCaptureQueueable implements Queueable, Database.AllowsCallouts {
    private Id contactId;
    private String ZetaGUID;

    public ZetaCustomerCaptureQueueable(Id contactId, string ZetaGUID) {
        this.contactId = contactId;
        this.ZetaGUID = ZetaGUID;
    }

    public void execute(QueueableContext context) {
        Contact contactObj = [SELECT id, Channel__c, Source__c, CreatedDate, Salutation__c, Gender__c, FirstName, MiddleName,LastName,
                MailingCity, MailingState, MailingPostalCode, MailingCountry, Birthdate, Email,
                HomePhone, Phone, MailingStreet,
                MobilePhone, DirectMailOptin__c, HomeStore__c, LoyaltyFlag__c,Brand_Id__c, EmailOptInStatus__c,
                StoreOfCapture__c, Language__c, SMSOptinStatus__c
        from contact
        WHERE id = :this.contactId];

        ZetaCustomerCaptureWrapper objWrapContact = new ZetaCustomerCaptureWrapper(contactObj);
        String jsB2 = JSON.serialize(objWrapContact);
        Log.push('serialized string is ==>'+jsB2);

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Zeta');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('iid', this.ZetaGUID);
        req.setMethod('POST');
        req.setBody(jsB2);

        Http http = new Http();

        try {
            HttpResponse res = http.send(req);
            String returnVal = res.getBody();
            Log.push('returnVal---->'+res.getBody());
            if(returnVal != null && returnVal != ''){
                contactObj.Zeta_Callout_Response__c = res.getBody();
                update contactObj;
            }
            //Log.push('response---->'+res.getBody());
        } catch(System.CalloutException e) {
            Logger.logException(e);
        }
        Logger.logDebug();
    }
}