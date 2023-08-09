/*
* @Author: PVH
*
* Purpose: REST Resource to sync Contact informaiton
*
* JIRA NO		UPDATE DATE		UPDATED BY		UPDATE DESCRIPTION
* -------		-----------		----------		------------------
* GDC-352							Divya		New Class created
*/

@RestResource(urlMapping='/A1subscribers/pointBalance')
global with sharing class A1CustomerPointBalanceUpdate {
    global class SubRequest{
        public String code;
        public String Count;
        public Set<String> LoyaltyId;
    }
    
    global class SubResponse {
        public String code;
        public string message;
    }
    
    @HttpPost
    global static void doUpdate() {
        RestRequest req = RestContext.request;
        RestResponse response = RestContext.response;
        Blob body = req.requestBody;
        String requestString = body.toString(); // retrieve request string
        
        Log.push('requestString' + requestString);
        
        requestWrapper rw = (requestWrapper)JSON.deserialize(requestString,requestWrapper.class); // deserialize request payload
        Log.push('rw' + rw);
        
        Set<String> LoyaltyIds = new Set<String>();
        Map<String,requestwrapper.subscriber_class> subscribermap = new Map<String,requestwrapper.subscriber_class>();
        
        for(requestwrapper.subscriber_class scs : rw.Subscribers) { // loop through subscriber_class from request
            Log.push('String.isBlank(scs.LoyaltyId)' + String.isBlank(scs.LoyaltyId) + 'String.isBlank(scs.BrandId)' + String.isBlank(scs.BrandId));

            if(String.isNotBlank(scs.LoyaltyId) && String.isNotBlank(scs.BrandId)) { // check if both LoyaltyId and BrandId are not blank
                subscribermap.put(scs.LoyaltyId, scs);
            }
            else { // return missing LoyaltyId in response
                Log.push('It is in else loop');
                response.statusCode = 400;
                SubResponse fres = new SubResponse();
                fres.code = SYSTEM.LABEL.INVALID_QUERY;
                fres.message = SYSTEM.LABEL.Missing_required_parameters_LoyaltyId;
                response.responseBody = Blob.valueOf(JSON.serialize(fres));
                return ;
            }   
        } 
        
        // query contacts with matching LoyaltyId
        List<Contact> contactlist = new List<Contact>([Select Id,Point_Balance__c,Brand_Id__c,LoyaltyID__c from Contact where B2C_Customer_No__c != null And Ecomm_Connected__c= true And LoyaltyID__c in :subscribermap.KeySet()]);
        List<Contact> updateconlist = new List<Contact>();
        
        if (contactlist.size() > 0) {
            for(Contact cons: contactlist) { // update Contacts LoyaltyId and BrandId
                cons.Point_Balance__c = Decimal.valueOf(subscribermap.get(cons.LoyaltyID__c).balancepoints);
                cons.Brand_Id__c = subscribermap.get(cons.LoyaltyID__c).BrandId;
                updateconlist.add(cons);
            }
        }

        try {
            Database.update(updateconlist); // update contacts
            response.statusCode = 200;
            SubRequest successres = new SubRequest();
            successres.code = 'OK';
            successres.Count = String.Valueof(updateconlist.size());
            successres.LoyaltyId = subscribermap.KeySet();
            response.responseBody = Blob.valueOf(JSON.serialize(successres));
            Log.push('response.responseBody'+response.responseBody);
            Logger.logDebug();
            return;
        }
        catch (Exception e) { // exception
            Log.push('Update failed due to' + e.getMessage());
            Logger.logDebug();
        }
        
    }
}