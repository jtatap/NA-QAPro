/******************************************************************************
* @Description:Makes callout to posts the points data to Agil1’s trackerAPI as an event.
* @Author     : Dhiren 
* @Date       : 01:01.2020
* @JIRA       : NASSC-1182
*
******************************************************************************/ 

public class A1TrackerAPIPoints {
    
    @TestVisible
    private class Events {
        public String Type {get;set;} 
        public String Subtype {get;set;} 
        public String EventTimeStamp {get;set;} 
        public String c_pointsGranted {get;set;} 
        public String c_accrualPeriod {get;set;} 
        public String c_sfscCaseNumber {get;set;} 
        public String c_sfscComments {get;set;} 
        public String c_sfscReasonCode {get;set;} 
        public String c_sfscAgentId {get;set;} 
        public String SourceCustomerNumber {get;set;} 
        public String CustomerID {get;set;} 
        public String Cookie {get;set;} 
    }
    
    @TestVisible
    private class Customers {
        public String SourceCustomerNumber {get;set;} 
        public String c_loyaltyid {get;set;} 
        public String c_loyaltyFlag {get;set;}
        public String ID {get;set;} 
        public String Email {get;set;} 
    }
    
    
    @InvocableMethod(label='A1 Tracker Api' description='Post Tracker API Points')
    public static void invokePostTrackerAPIPoints(List<Id> CaseIds) {
        Log.push('invokePostTrackerAPIPoints called');
        Id CaseId = CaseIds[0];
        futurePostTrackerAPIEvents(CaseId);
        Logger.logDebug();
    }
    
    @future(callout=true)
    public static void futurePostTrackerAPIEvents(Id CaseId){
        Log.push('futurePostTrackerAPIEvents called');
        Map<String,String> LoyaltyMap = new Map<String,String>(); 
        List<Case> CaseList = [SELECT Id, CaseNumber, NFCaseScenario__r.NFScenarioCategory__c, NFCaseScenario__r.NF_Scenario__c, LoyaltyComments__c, PointsGranted__c, PointsAdjustmentTimeStamp__c, OwnerId, NFCaseScenario__c, Contact.Brand_Id__c, Contact.LoyaltyID__c,Contact.LoyaltyFlag__c,Contact.Email,Owner.FirstName,Owner.LastName
                               FROM Case 
                               WHERE Id=:CaseId LIMIT 1];

        Log.push('CaseList:'+CaseList);
        
        List<AccuralPeriods__mdt> accualPeriod = [SELECT Id,MasterLabel, AccuralPeriod__c, EndDate__c, StartDate__c 
                                                  FROM AccuralPeriods__mdt
                                                  WHERE StartDate__c <= :Date.today() and EndDate__c >= :Date.today()];
        Log.push('accualPeriod:'+accualPeriod);
        
        //if records brand is child, assigning brandId with its parent
        //fetching loyalty MDT
        List<LoyaltySettings__mdt> loyaltyList = [Select Id, BrandId__c, Parent_Brand__c from LoyaltySettings__mdt];
        for(LoyaltySettings__mdt loyalRecord : loyaltyList){
            if(loyalRecord.Parent_Brand__c != null){
            	LoyaltyMap.put(loyalRecord.BrandId__c,loyalRecord.Parent_Brand__c);
            }
        }
        Log.push('***Posting Loyalty Map = '+LoyaltyMap);
        String brandIdToPass = CaseList[0].Contact.Brand_Id__c;
        
        //if records brand is child, assigning brandId with its parent
        if(LoyaltyMap.containsKey(brandIdToPass)){
            Log.push('***changing brandIdToPass: subBrand to parentBrand');
            brandIdToPass = LoyaltyMap.get(brandIdToPass);
        }
        Log.push('***brandIdToPass = '+brandIdToPass);
        
        List<A1_TrackerAPI_creds__mdt> creds =[SELECT Id,MasterLabel, Base64__c, BrandId__c, Password__c, Username__c, TenantId__c 
                                               FROM A1_TrackerAPI_creds__mdt
                                               WHERE BrandId__c =: brandIdToPass];
        Log.push('creds:'+creds);
        if(!creds.isEmpty()){
            Events eve = new Events();
            eve.Type='points';
            eve.Subtype='customerServiceAdhocGrant';
       //     eve.EventTimeStamp=String.valueOf(CaseList[0].PointsAdjustmentTimeStamp__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.000\'Z\''));
            eve.EventTimeStamp=String.valueOf(CaseList[0].PointsAdjustmentTimeStamp__c.getTime());
            eve.c_pointsGranted=String.valueOf(CaseList[0].PointsGranted__c);
            eve.c_accrualPeriod = accualPeriod[0].AccuralPeriod__c;
            eve.c_sfscCaseNumber = CaseList[0].CaseNumber;
            eve.c_sfscComments = CaseList[0].LoyaltyComments__c;
            eve.c_sfscReasonCode = CaseList[0].NFCaseScenario__r.NFScenarioCategory__c;
            eve.c_sfscAgentId = (CaseList[0].Owner.FirstName+CaseList[0].Owner.LastName).toLowerCase();
            eve.SourceCustomerNumber = CaseList[0].Contact.LoyaltyID__c;
            eve.CustomerID = CaseList[0].Contact.LoyaltyID__c;
            eve.Cookie = '';
            Log.push('eve:'+eve);

            Customers cust = new Customers();
            cust.SourceCustomerNumber = CaseList[0].Contact.LoyaltyID__c;
            cust.c_loyaltyid = CaseList[0].Contact.LoyaltyID__c;
            cust.ID = CaseList[0].Contact.LoyaltyID__c;
            if (CaseList[0].Contact.LoyaltyFlag__c!=null && CaseList[0].Contact.LoyaltyFlag__c) cust.c_loyaltyFlag = 'Yes';
            cust.Email = CaseList[0].Contact.Email;
            Log.push('cust:'+cust);
            String body = String.valueOf('{"events" :['+JSON.serialize(eve)+'], "customers" : ['+JSON.serialize(cust)+']}');
            //String body = String.valueOf('"events" :['+JSON.serialize(eve)+'], "customers" : ['+JSON.serialize(cust)+']');
            Log.push('body:'+body);
            String trackerAccKey = AgileOne.getTrackerAPIAccesskey(creds[0]);
            Log.push('***AccessKey = '+trackerAccKey);
            //String trackerAccKey = '2a$10$QbZVzccFtgdNW49AekLpWOMQuNXw.RVQMKEkTqHiGO52UluqDjXg2';
            String reqEndPoint = 'callout:A1_TrackerAPI_DataEndPoint/'+creds[0].TenantId__c+'/dw/tracker?scheme=a1webtag&accessKey='+trackerAccKey;
            Log.push('httpCalloutMethod called');

            String responseString = Null;
            HttpRequest req = new HttpRequest();
            req.setHeader('Content-Type', 'application/json');
            req.setBody(body);
            req.setEndpoint(reqEndPoint);
            req.setMethod(SYSTEM.LABEL.POST);
            Log.push('reqEndPoint '+reqEndPoint);
            Http http = new Http();
            try{
                HttpResponse res = http.send(req);
                Log.push('***response body:'+res.getBody());
                responseString = res.getBody();

            }catch(System.CalloutException e) {
                Log.push('Callout error: '+ e);
            }
        }
        Logger.logDebug();
    }
        
}