/******************************************************************************
* @Description: Scheduler to C360API Token
* @Author     : Trupti Bhirud 
* @Date       : 01:01.2020
* @JIRA       : NASSC-1162,NASSC-1163,NASSC-1180
*
******************************************************************************/ 
global class AgileOne {
    

    @auraEnabled
    public static List<TransactionRec> getC360Data(String LoyatlyId, String BrandId){
        String accessToken = Null;
        String authBearer   = Null;
        String reqEndPoint  = Null;
        String responseVal  = Null;
        string loyaltyId=LoyatlyId;
    
        List<TransactionRec> transactionlist = new List<TransactionRec>();
        //Get C360 APi Creds from Custom Metadatatype
        A1_C360API_creds__mdt credsRecord = [SELECT BrandId__c, TenantId__c, Username__c, Password__c,Base64__c, MasterLabel
                                             FROM A1_C360API_creds__mdt WHERE BrandId__c=:BrandId LIMIT 1];

        accessToken = getC360APIToken(credsRecord);
        authBearer   = 'Bearer '+accessToken;
        //reqEndPoint  = 'callout:A1_360API_DataEndPoint/'+credsRecord.TenantId__c+'/dw/a360/customers/'+LoyatlyId; 
        reqEndPoint  = 'callout:A1_360API_DataEndPoint/'+credsRecord.TenantId__c+'/dw/a360/customers/'+LoyatlyId+'?'+System.Label.Limit; 
        responseVal = httpCalloutMethod(reqEndPoint,authBearer, 'GET'); 
        System.debug('** 360API Response: '+ responseVal);
        if(! String.isEmpty(responseVal)){
             transactionlist = parseresourceJSON(responseVal);
        }
        System.debug('***transactionlist = '+transactionlist);
        return transactionlist;
    }
    
    //Fetch and return active C360 API token from custom metadata type 
    private static String getC360APIToken(A1_C360API_creds__mdt credsRecord){
       String accessToken = Null;
       List<A1_C360API_Tokens__mdt> tokenRecord = [SELECT BrandId__c, access_token__c 
                                                    FROM A1_C360API_Tokens__mdt 
                                                    WHERE BrandId__c = :credsRecord.BrandId__c AND expires_at__c > :System.now()  LIMIT 1];
        if (tokenRecord.size()>0){
            accessToken = tokenRecord[0].access_token__c;
        } 
        return accessToken;
    }
    
    public static string getTrackerAPIAccesskey(A1_TrackerAPI_creds__mdt trackerCred){
         String accessKey = Null;
        List<A1_TrackerAPI_tokens__mdt> trackerCredsList = [select id,BrandId__c,access_token__c,access_key__c,token_expires_at__c
                                                           from A1_TrackerAPI_tokens__mdt where BrandId__c =:trackerCred.BrandId__c 
                                                           and token_expires_at__c  >: System.now() and key_expires_at__c >: System.now()];
        
         if (!trackerCredsList.isEmpty()){
            accessKey = trackerCredsList[0].access_key__c;
        } 
        return accessKey;
        
    }

    private static String httpCalloutMethod(String reqEP,String authBrr, String method){
        String responseString = Null;
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', authBrr);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Content-Length', '0');
        req.setEndpoint(reqEP);
        req.setMethod(method);
        Http http = new Http();
        try{
            HttpResponse res = http.send(req);
            responseString = res.getBody();
            
        }catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
        }
        return responseString;
    }
    
   
    @AuraEnabled
    public static List<Reward__c> getRewardsData(String LoyaltyId)
    {
        List<Reward__c> listRewards = [Select Id,RewardId__c,ExpireDate__c,TransactionId__c, RewardType__c,Status__c,Expire_Date_form__c from Reward__c WHERE LoyaltyId__c=:LoyaltyId ORDER BY LastModifiedDate DESC];
        return listRewards;
    } 
    
    //parse JSON to generate wrapperlist of trasaction and event resource    
    public static List<TransactionRec> parseresourceJSON(String jsonResponse){
        List<TransactionRec> transactionRecordList = new List<TransactionRec>();
        List<ResourceData> transactionList = new list<ResourceData>();
        List<ResourceData> eventList = new list<ResourceData>();
        List<ResourceData> customersummaryList = new list<ResourceData>();
        List<String> customerIdsList = new List<String>();
        JSONParser parser = JSON.createParser(jsonResponse);
        while (parser.nextToken() != null) {
         if (parser.getCurrentToken() == JSONToken.FIELD_NAME){
                if(parser.getText() == 'customerIds'){
                    String customerIds = parser.getText();
                    customerIdsList =customerIds.split(',');
                }
                if(parser.getText() =='{"displayResourceKey":"$customerTransaction360","resource":"transaction","layout":"customer"}'){
                  parser.nextToken();
                    transactionList = (List<ResourceData>)parser.readValueAs(List<ResourceData>.class); 
                }
                //parser.nextToken();
                if(parser.getText() =='{\"displayResourceKey\":\"$customersummaryAttributes\",\"resource\":\"customersummary\",\"layout\":\"customer\"}'){
                      parser.nextToken();
                    customersummaryList = (List<ResourceData>)parser.readValueAs(List<ResourceData>.class); 
                }
                 
                if(parser.getText() =='{\"displayResourceKey\":\"$customerJourney\",\"resource\":\"event\",\"layout\":\"customer\"}'){
                     parser.nextToken();
                    eventList = (List<ResourceData>)parser.readValueAs(List<ResourceData>.class); 
                }
             
            }
        }
        Double currentPointBalance;
        if(!customersummaryList.isEmpty()){            
            for(ResourceData transactionRec : customersummaryList){   
                TransactionRec rec = new TransactionRec(); 
                    for(Values val :transactionRec.values){
                        if(val.udmColumn =='customersummary.c_balancePoints' && String.isNotBlank(val.value)){
                            currentPointBalance = Double.valueOf(val.value); 
                            rec.currentPointBalance= currentPointBalance;
                        }
                    }
                  rec.Category ='Customer Summary';
                  transactionRecordList.add(rec);
            }
        }
        if(!transactionList.isEmpty()){
            for(ResourceData transactionRec : transactionList){
                TransactionRec rec = new TransactionRec();                
                for(Values val :transactionRec.values){
                    System.debug('Transaction val '+val);
                    if(val.udmColumn =='transaction.Type' && String.isNotBlank(val.value)){ 
                        rec.Type = val.value;
                    }
                    if(val.udmColumn =='transaction.SourceTransactionNumber' && String.isNotBlank(val.value)){
                        rec.Description = val.value;
                    }
                    if(val.udmColumn =='transaction.Total' && String.isNotBlank(val.value)){
                        rec.Total = val.value;
                    }
                    if(val.udmColumn =='transaction.c_finalPoints' && String.isNotBlank(val.value)){
                        rec.PointsIssued = val.value;
                    }
                    if(val.udmColumn =='organization.SourceOrganizationNumber' && String.isNotBlank(val.value)){
                    //    String inputStore = val.value;
                    //    System.debug('^^^Mall Name = '+inputStore);
                    //    List<String> listStore = inputStore.split(' ');
                    //    String storeCode = listStore[0];
                        String storeCode = val.value;
                        if (storeCode.left(1)=='0') storeCode = storeCode.substring(1);  //to strip first leading 0
                        if (storeCode.left(1)=='0') storeCode = storeCode.substring(1); //to strip second leading 0, if exists
                        if (storeCode.left(1)=='0') storeCode = storeCode.substring(1); //to strip third leading 0, if exists
                        System.debug('^^^storeCode = '+storeCode);
                        String storeBrand = storeCode.right(2);
                        storeCode = storeCode.remove(storeBrand);
                        System.debug('^^^final Store = '+storeBrand+storeCode);
                        rec.StoreofPurchase = storeBrand+storeCode;
                    }
                    if(val.udmColumn =='transaction.TransactionTimestamp' && String.isNotBlank(val.value)){
                        Long dt1 =  Long.valueOf(val.value);
                        DateTime issueDateTime = DateTime.newInstance(dt1);
                        Date issueDate = date.newinstance(issueDateTime.year(), issueDateTime.month(), issueDateTime.day());
                        rec.IssueDate = issueDate;
                    }
                   
                }  
                List<TransactionItem> transactionItemList = new List<TransactionItem>();
                List<List<Values>>  childrenList = transactionRec.children;   
                for(List<Values> childList :childrenList){
                    TransactionItem item = new TransactionItem();
                    for(values child :childList){                        
                        if(child.udmColumn =='product.SourceProductNumber' && String.isNotBlank(child.value)){
                            item.ProductNumber = child.value;
                        }
                        if(child.udmColumn =='product.Name' && String.isNotBlank(child.value)){
                            item.ProductName   = child.value; 
                        }
                        if(child.udmColumn =='product.BrandName' && String.isNotBlank(child.value)){
                            item.BrandName = child.value;
                        }
                        if(child.udmColumn =='transactionitem.SaleRevenue' && String.isNotBlank(child.value)){
                            item.NetPrice = Double.valueOf(child.value);
                        }
                        if(child.udmColumn =='transactionitem.Discount' && String.isNotBlank(child.value)){
                            item.Discount = Double.valueOf(child.value);
                        }   
                        if(child.udmColumn =='transactionitem.Quantity' && String.isNotBlank(child.value)){
                            item.Quantity = Integer.valueOf(child.value);
                        }   
                    }
                     System.debug('Transaction item'+item);
                    transactionItemList.add(item);
                }
                
                /*
                rec.transactionItemList = transactionItemList;                
                rec.Category ='Transaction';
                transactionRecordList.add(rec);
                */
                //checking is TransactionRecord.Type == Purchase AND TransactionRecord.transaction.c_finalPoints is NOT NULL
                if(rec.Type == 'Purchase' && String.isNotBlank(rec.PointsIssued)){
                    System.debug('***PointsIssued OR transaction.c_finalPoints = '+rec.PointsIssued );
                    rec.Category ='Transaction';
                    rec.transactionItemList = transactionItemList;
                    transactionRecordList.add(rec);
                }
             }
                
            }
        string caseNumber;
        //traverse eventlist to cretare wrapper list
        if(!eventList.isEmpty()){
            for(ResourceData transactionRec : eventList){
                TransactionRec eventRec = new TransactionRec();
                for(Values val :transactionRec.values){
                     if(val.udmColumn =='event.Type' && String.isNotBlank(val.value)){
                         eventRec.Type = val.value;
                     }
                     if(val.udmColumn =='event.c_sfscReasonCode' && String.isNotBlank(val.value)){
                        eventRec.ReasonCode = val.value;
                     }
                     if(val.udmColumn =='event.EventTimeStamp' && String.isNotBlank(val.value)){
                        Long dt1 =  Long.valueOf(val.value);
                        DateTime issueDateTime = DateTime.newInstance(dt1);
                        Date issueDate = date.newinstance(issueDateTime.year(), issueDateTime.month(), issueDateTime.day());
                        eventRec.IssueDate = issueDate;
                     }
                     if(val.udmColumn =='event.c_pointsGranted' && String.isNotBlank(val.value)){
                        eventRec.PointsIssued = val.value;
                     }
                     if(val.udmColumn =='Event.c_sfscCaseNumber' && String.isNotBlank(val.value)){
                        eventRec.Casenumber = val.value; 
                        caseNumber=val.value;
                     }                   
                    
                }
                
                /* OLD CODE
                eventRec.Description = System.Label.Event_Description;
                eventRec.Type = System.Label.Event_Type;
                eventRec.Category ='Event';
                transactionRecordList.add(eventRec); 
                */
               //Checking if EventRecord.Type == Points 
               if(eventRec.Type == 'points')
               {
                   eventRec.Type = System.Label.Event_Type;
                   eventRec.Description = System.Label.Event_Description;
                   eventRec.Category ='Event';
                   transactionRecordList.add(eventRec); 
               }
                
            }
        } 
      // List<Case> caseList=[Select Id,CaseNumber,ContactId from Case CaseNumber=:caseNumber];
       //List<Contact> conList=[Select Id, Name ,Current_Point_Balance__c ];
        System.debug(transactionRecordList);
        for(TransactionRec r :transactionRecordList){
            System.debug(r);
            
        }
        
        
        return transactionRecordList;
    }
    
    //Wrapper class to display data in lightening components
    public class TransactionRec{
        @AuraEnabled
        public String Category{get;set;}
        @AuraEnabled
        public Double currentPointBalance {get;set;}
        @AuraEnabled
        public String Description  {get; set;}
        @AuraEnabled
        public String TransactionBarcode {get; set;}
        @AuraEnabled
        public Date IssueDate {get; set;}
        @AuraEnabled
        public String Type {get; set;}
        @AuraEnabled
        public String Total {get; set;}
        @AuraEnabled
        public String PointsIssued{get; set;}
        @AuraEnabled
        public String StoreofPurchase{get; set;}
        @AuraEnabled
        public String ReasonCode {get; set;}
        @AuraEnabled
        public String Casenumber{get;set;}
        @AuraEnabled
        public List<TransactionItem> transactionItemList;
    }
    public class TransactionItem{
        @AuraEnabled
        public String ProductNumber {get; set;}
        @AuraEnabled
        public String ProductName {get; set;}
        @AuraEnabled
        public String BrandName {get; set;}
        @AuraEnabled
        public Double Discount {get; set;}
        @AuraEnabled
        public Double NetPrice {get; set;}
        @AuraEnabled
        public Integer Quantity {get; set;}
        
    } 
    public class values{
        public String udmColumn ;
        public String value ;
    }
    public class children{
        public String udmColumn;
        public String  value;
    }
    public class ResourceData{
        public String rowKey; 
        public List<Values> values ;
        public List<List<Values>> children; 
        public Boolean ignore ;
    
    }

}