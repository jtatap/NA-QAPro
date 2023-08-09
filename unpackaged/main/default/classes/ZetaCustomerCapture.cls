/*
* Task: NASSC-841 [Customer Capture API Callout]
* 
* Objective:  When a customer contact record is directly created in SFSC, SFSC has to make a callout to Zeta and submit the customer data.  
* Zeta will create a corresponding customer record in its system and will return response code.
*
* Date: Oct 2019
*/

global class ZetaCustomerCapture {

    @InvocableMethod(label='FetchContact' description='Inserts the contacts')
    public static void sendCustomerData(List<id> ContactIds) {
        Map<String, string> brandIdToGUID = new Map<String, string>();
        Set<String> brandIds = new Set<String>();
        List<Contact> conObjs = [SELECT Id,  Source__c, Channel__c, FirstName, LastName, Brand_Id__c, Gender__c,
                Zeta_Callout_Response__c
        FROM contact
        WHERE
                id IN :ContactIds];
        if(conObjs.size()>0) {
            for(Contact cc : conObjs) {
                brandIds.add(cc.Brand_Id__c);
            }
            if(brandIds.size()>0) {
                List<LoyaltySettings__mdt> LoyaltySettings = [SELECT BrandId__c,ZetaGUID__c
                FROM LoyaltySettings__mdt
                where BrandId__c IN :brandIds];
                for(LoyaltySettings__mdt LoyaltySetting: LoyaltySettings) {
                    if(LoyaltySetting.ZetaGUID__c != null)
                        brandIdToGUID.put(LoyaltySetting.BrandId__c,LoyaltySetting.ZetaGUID__c);
                }
                if(brandIdToGUID.size()>0) {
                    for(Contact cc : conObjs) {
                        if(brandIdToGUID.containsKey(cc.Brand_Id__c)){
                            System.enqueueJob(new ZetaCustomerCaptureQueueable(cc.id, brandIdToGUID.get(cc.Brand_Id__c)));
                            //makeCallOut(cc.id, brandIdToGUID.get(cc.Brand_Id__c));
                        }
                    }
                }
            }
        }
    }
    
    
    @future (callout=true) 
    public static void makeCallOut(Id contactId, string ZetaGUID) { 
        
        //Log.push('The contact id is::'+contactId+' and zetaguid is::'+ZetaGUID);                 
        Contact contactObj = [SELECT Channel__c, Source__c, CreatedDate, Salutation__c, Gender__c, FirstName, MiddleName,LastName,
                              MailingCity, MailingState, MailingPostalCode, MailingCountry, Birthdate, Email, 
                              HomePhone, Phone, MailingStreet,
                              MobilePhone, DirectMailOptin__c, HomeStore__c, LoyaltyFlag__c,Brand_Id__c, EmailOptInStatus__c,
                              StoreOfCapture__c, Language__c, SMSOptinStatus__c
                              from contact 
                              WHERE id = :contactId];
       
       ZetaCustomerCaptureWrapper objWrapContact = new ZetaCustomerCaptureWrapper(contactObj); 
       String jsB2 = JSON.serialize(objWrapContact);       
       Log.push('serialized string is ==>'+jsB2);
                    
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Zeta');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('iid', ZetaGUID);
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