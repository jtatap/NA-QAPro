/*  Json Request
 *  {"Count":"2", "Unsubscribes":[ { "BrandId":"3", "Email":"abc@123.com" }, { "BrandId":"2","Email":"xyc@123.com"}]}
 *
 *  https://instance.salesforce.com/services/apexrest/subscribers/Unsubscribe
 */
@RestResource(urlMapping = '/subscribers/Unsubscribe')
global without sharing class Unsubscribe{
    public class UnSubRequest{
        public String Count;
        public List<Unsubscribes> Unsubscribes;
        public String FileName;
    }

    public class Unsubscribes{
        public String BrandId;
        public String Email;
    }

    @HttpPost
    global static void doUnsubscribe(){
        RestRequest req = RestContext.request;

        List<Contact> conts = new List<Contact>();
        Set<String> emailSet = new Set<String>();
        List<String> brandIdSet = new List<String>();

        String requestData = req.requestBody.toString();
        Log.push('****' + requestData);

        UnSubRequest unSubReq = (UnSubRequest)JSON.deserialize(requestData, UnSubRequest.class);
        Log.push('****' + unSubReq);
        String FileName = unSubReq.FileName;
        String sourceSystem = SYSTEM.LABEL.BlueCore;
        // Create List of Email and BrandId to be used to get matching contacts
        for (Unsubscribes ubs : unSubReq.Unsubscribes){

            emailSet.add(ubs.Email);
            brandIdSet.add(ubs.BrandId);
        }
        Log.push('****' + emailSet);
        Log.push('****' + brandIdSet);

        if (emailSet.size() > 0){
            conts = [SELECT Id, Email, HasOptedOutOfEmail, EmailOptOutDate__c, EmailOptInStatus__c
                     FROM Contact
                     WHERE Email IN:emailSet AND Brand_Id__c = :brandIdSet[0] AND EmailOptInStatus__c = 'Y'];   // using brandIdSet[0] as all entries will have same brandId per call.
        }

        if (conts.size() > 0){

            for (Contact c : conts){

                c.EmailOptInStatus__c = SYSTEM.LABEL.N;
                //c.EmailOptInDate__c = null;
                c.HasOptedOutOfEmail = true;
                c.EmailOptOutDate__c = System.now();

            }

            Database.SaveResult[] results = Database.update (conts, false);
            Log.push('*****' + unSubReq.FileName);
            Logger.logDebug();
            ContactUtility.createErrorLogRecords(results, sourceSystem, FileName);
        }
    }

}