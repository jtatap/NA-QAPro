@isTest
public class AgileOneTest {
    static Map<String, String> responseHeaders = new Map<String, String>();    
	@isTest
    public static void getC360DataTest(){
        Test.startTest();
        responseHeaders.put('Content-Type', 'application/json');
        SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                                 'OK',
                                                 '{"customerIds":["C0021733313","0031U00000U7ZjxQAF","2019101706050100104305CK"]}',
                                                 responseHeaders);
        
        Test.setMock(HttpCalloutMock.class, fakeResponse);   
        AgileOne.getC360Data('C0021733313','2');
        Test.stopTest();
    }
    
    @isTest
    public static void getTrackerAPIAccesskeyTest(){
        Test.startTest();
        String brandId = '2';
        List<A1_TrackerAPI_creds__mdt> trackerCred = [select id,BrandId__c from A1_TrackerAPI_creds__mdt where BrandId__c=: brandId];
        AgileOne.getTrackerAPIAccesskey(trackerCred[0]);
        Test.stopTest();
    }
    @isTest
    public static void getRewardsDataTest(){
        Test.startTest();
        Reward__c rew = new Reward__c(TransactionId__c='TR101',Status__c='Redeemed',LoyaltyId__c='CK1235999',RewardType__c='33');
        insert rew;
        AgileOne.getRewardsData('CK1235999');
        Test.stopTest();
    }
    @isTest
    public static void parseresourceJSONTest(){
        Test.startTest();
        String response ='{"customerIds":["0032300000O1GnqAAF","E04000146848"],"{\\"displayResourceKey\\":\\"$customerTransaction360\\",\\"resource\\":\\"transaction\\",\\"layout\\":\\"customer\\"}":[{"rowKey":"testTransaction","values":[{"udmColumn":"transaction.Type","value":"TypeTrans"},{"udmColumn":"transaction.SourceTransactionNumber","value":"900"},{"udmColumn":"transaction.Total","value":"900"},{"udmColumn":"transaction.c_finalPoints","value":"900"},{"udmColumn":"transaction.TransactionTimestamp","value":"1584374412000"}],"children":[[{"udmColumn":"product.SourceProductNumber","value":"1011"},{"udmColumn":"product.Name","value":"name"},{"udmColumn":"product.BrandName","value":"brandName"},{"udmColumn":"transactionitem.SaleRevenue","value":"200"},{"udmColumn":"transactionitem.Discount","value":"100"},{"udmColumn":"transactionitem.Quantity","value":"5"}]],"ignore":false}],"{\\"displayResourceKey\\":\\"$customersummaryAttributes\\",\\"resource\\":\\"customersummary\\",\\"layout\\":\\"customer\\"}":[{"rowKey":"testcustomersummary","values":[{"udmColumn":"customersummary.c_balancePoints","value":"900"}],"children":[],"ignore":false}],"{\\"displayResourceKey\\":\\"$customerJourney\\",\\"resource\\":\\"event\\",\\"layout\\":\\"customer\\"}":[{"rowKey":"testevents","values":[{"udmColumn":"event.CustomerID","value":"E04000146848"},{"udmColumn":"event.c_pointsGranted","value":"-1100"},{"udmColumn":"event.c_accrualPeriod","value":"20200309-20200315"},{"udmColumn":"event.c_sfscCaseNumber","value":"00001726"},{"udmColumn":"event.c_sfscAgentId","value":"sona sofiaantony raj"},{"udmColumn":"event.EventTimeStamp","value":"1584374412000"},{"udmColumn":"event.Type","value":"points"},{"udmColumn":"event.Subtype","value":"customerServiceAdhocGrant"},{"udmColumn":"event.Variables","value":"UserAgent=SFDC-Callout%2F48.0"}],"children":[[{"udmColumn":"event.SourceProductNumber","value":null}]],"ignore":false}]}';
        		AgileOne.parseresourceJSON(response);
        		Test.stopTest();
    }
}