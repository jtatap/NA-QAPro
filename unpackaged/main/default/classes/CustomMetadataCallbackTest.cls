@isTest
public class CustomMetadataCallbackTest {
    static testMethod void testCreateMetaDataA1c360APIToken() {
        // Create test data
        A1_C360API_creds__mdt credRec = new A1_C360API_creds__mdt();
        credRec.BrandId__c = 'TestBrand';
        Scheduler_A1C360APITokens.responseClass resp = new Scheduler_A1C360APITokens.responseClass();
        resp.access_token = 'TestAccessToken';
        resp.expires_in = 3600;
        Map<A1_C360API_creds__mdt, Scheduler_A1C360APITokens.responseClass> responseValAndMetdataMap = new Map<A1_C360API_creds__mdt, Scheduler_A1C360APITokens.responseClass>();
        responseValAndMetdataMap.put(credRec, resp);

        // Call method to test
        CustomMetadataCallback.createMetaDataA1c360APIToken(responseValAndMetdataMap);

    }

    static testMethod void testCreateTrackerAPITokenMetaData() {
        A1_TrackerAPI_creds__mdt trackerCredRec = new A1_TrackerAPI_creds__mdt();
        trackerCredRec.BrandId__c = 'TestBrand';
        Scheduler_A1TrackerAPITokens.responseClass resp = new Scheduler_A1TrackerAPITokens.responseClass();
        resp.access_token = 'TestAccessToken';
        resp.expires_in = 3600; 
        Map<A1_TrackerAPI_creds__mdt, Scheduler_A1TrackerAPITokens.responseClass> responseValAndMetdataMap = new Map<A1_TrackerAPI_creds__mdt, Scheduler_A1TrackerAPITokens.responseClass>();
        responseValAndMetdataMap.put(trackerCredRec, resp);
        // Call method to test
        CustomMetadataCallback.createTrackerAPITokenMetaData(responseValAndMetdataMap);
    }
}