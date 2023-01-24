/**
 * @description       :
 * @author            : chayan.batabyal@neuraflash.com
 * @last modified on  : 10-07-2021
 * @last modified by  : chayan.batabyal@neuraflash.com
**/
global class NF_RingCentralDataSyncSchBatch
    implements Database.Batchable<String>, Database.Stateful, Database.AllowsCallouts, Schedulable{

    private String access_token = '';
    private String resource_server_base_uri = '';
    private DateTime access_token_valid_till;
    private String encodedStartDate = '';
    private String encodedEndDate = '';
    private Boolean authorizationActive = false;
    private List<String> activeAPIsForDataSync;
    private Date operationStartDate;
    private Date historicalLoadFromDate;
    private Date historicalLoadToDate;
    private Boolean isHistorical = false;
    private String specificId = '';
    @TestVisible private Boolean authorizationError = true;

    /**
    * @description Default constructor
    * @author chayan.batabyal@neuraflash.com | 09-09-2021
    **/
    public NF_RingCentralDataSyncSchBatch(){}

    /**
    * @description Custom constructor to enable chaining of batches or running without being scheduled
    * @author chayan.batabyal@neuraflash.com | 09-09-2021
    * @param apiStartDate
    * @param apiEndDate
    * @param isHistoricalDataLoad
    * @param opStart
    **/
    public NF_RingCentralDataSyncSchBatch(
        Date apiStartDate, Date apiEndDate, Boolean isHistoricalDataLoad, Date opStart
    ){
        operationStartDate = (opStart == null || opStart > Date.today()) ? Date.today() : opStart;
        isHistoricalDataLoad = isHistoricalDataLoad == null ? false : isHistoricalDataLoad;

        if(
            apiStartDate != null && (
                (
                    isHistoricalDataLoad && apiEndDate != null && apiEndDate <= operationStartDate &&
                    apiStartDate < apiEndDate.addDays(1) && apiStartDate < operationStartDate
                )
                ||
                (
                    !isHistoricalDataLoad && apiEndDate == null
                )
            )
        ){
            isHistorical = isHistoricalDataLoad;
            apiEndDate = apiEndDate != null ? apiEndDate : apiStartDate.addDays(1);

            if(isHistorical){
                historicalLoadFromDate = apiStartDate;
                historicalLoadToDate = apiEndDate;
            }

            DateTime singleCallStart = DateTime.newInstance(
                apiStartDate,  Time.newInstance(0, 0, 0, 0)
            );
            DateTime singleCallEnd = singleCallStart.addDays(1);

            encodedStartDate = EncodingUtil.urlEncode(
                String.valueOf(singleCallStart).replace(' ', 'T'), 'UTF-8'
            );
            encodedEndDate = EncodingUtil.urlEncode(
                String.valueOf(singleCallEnd).replace(' ', 'T'), 'UTF-8'
            );
        }
    }

    /**
    * @description Override execute method of schedulable interface
    * @author chayan.batabyal@neuraflash.com | 09-08-2021
    * @param SC
    **/
    global void execute(SchedulableContext SC) {
        NF_RingCentralDataSyncSchBatch batchable = new NF_RingCentralDataSyncSchBatch(
            Date.today().addDays(-1), null, false, Date.today()
        );
        Database.executeBatch(batchable, 1);
    }

    /**
    * @description Override start method of batchable interface
    * @author chayan.batabyal@neuraflash.com | 09-09-2021
    * @param ctx
    * @return Iterable
    **/
    public Iterable<String> start(Database.BatchableContext ctx) {
        activeAPIsForDataSync = fetchAPIsToCall();
        System.debug('activeAPIsForDataSync :: ' + activeAPIsForDataSync);

        if(authorizationActive && activeAPIsForDataSync != null && !activeAPIsForDataSync.isEmpty()){
            try{
                activeAPIsForDataSync.sort();
                fetchRequestedDetailsAndInsertData('Authorization');
            }
            catch(Exception e){
                System.debug('Error: ' + e.getLineNumber() + ' : ' + e.getMessage());
            }
            finally{
                if(authorizationError){
                    System.debug('Error in authorization');
                }
            }
        }
        return authorizationError ? new List<String>() : (
            Test.isRunningTest() ? (new List<String>{activeAPIsForDataSync[0]}) : activeAPIsForDataSync
        );
    }

    /**
    * @description Makes a callout to the Ring Central APIs and creates the needed records.
    * @author chayan.batabyal@neuraflash.com | 09-09-2021
    * @param ctx
    * @param apiToCall
    **/
    public void execute(Database.BatchableContext ctx, List<String> apiToCall) {
        if(apiToCall != null && !apiToCall.isEmpty()){
            try{
                if(
                    String.isBlank(access_token) || String.isBlank(resource_server_base_uri) ||
                    access_token_valid_till == null || access_token_valid_till <= System.now()
                ){
                    authorizationError = true;
                    fetchRequestedDetailsAndInsertData('Authorization');
                }
                if(!authorizationError){
                    if(apiToCall[0].indexOf(':') > 0){
                        specificId = apiToCall[0].split(':')[1];
                    }
                    else{
                        specificId = '';
                    }
                    fetchRequestedDetailsAndInsertData(apiToCall[0].split(':')[0]);
                }
            }
            catch(Exception e){
                System.debug('Error: ' + e.getLineNumber() + ' : ' + e.getMessage());
            }
            finally{
                if(authorizationError){
                    System.debug('Error in authorization');
                }
            }
        }
    }

    /**
    * @description If it's a part of historical data load then it queues the data sync for next day's data
    * @author chayan.batabyal@neuraflash.com | 09-09-2021
    * @param ctx
    **/
    public void finish(Database.BatchableContext ctx) {
        if(
            isHistorical &&
            activeAPIsForDataSync != null && !activeAPIsForDataSync.isEmpty() &&
            historicalLoadFromDate != null && historicalLoadFromDate <= operationStartDate.addDays(-1) &&
            historicalLoadToDate != null && historicalLoadFromDate < historicalLoadToDate
        ){
            NF_RingCentralDataSyncSchBatch batchable = new NF_RingCentralDataSyncSchBatch(
                historicalLoadFromDate.addDays(1), historicalLoadToDate, isHistorical, operationStartDate
            );
            Database.executeBatch(batchable, 1);
        }
    }

    /**
    * @description Fetches the names of the APIs that need to be called
    * @author chayan.batabyal@neuraflash.com | 09-09-2021
    * @return List<String>
    **/
    @TestVisible
    private List<String> fetchAPIsToCall(){
        List<String> lstOfActiveAPIs = new List<String>();
        for(
            NF_Nice_InContact_API_Config__mdt eachMetaRecord : [
                SELECT DeveloperName, Is_Active__c, Specific_Ids__c
                FROM NF_Nice_InContact_API_Config__mdt
            ]
        ){
            if(eachMetaRecord.Is_Active__c){
                if(eachMetaRecord.DeveloperName.equalsIgnoreCase('Authorization')){
                    authorizationActive = true;
                }
                else{
                    if(String.isBlank(eachMetaRecord.Specific_Ids__c)){
                        lstOfActiveAPIs.add(eachMetaRecord.DeveloperName);
                    }
                    else{
                        for(String eachSpecificId : eachMetaRecord.Specific_Ids__c.split(',')){
                            lstOfActiveAPIs.add(eachMetaRecord.DeveloperName + ':' + eachSpecificId);
                        }
                    }
                }
            }
        }
        return lstOfActiveAPIs;
    }

    /**
    * @description Receives the name of the actual api to call, creates the records if configured to
    * @author chayan.batabyal@neuraflash.com | 09-07-2021
    * @param requestedAPI
    **/
    @TestVisible
    private void fetchRequestedDetailsAndInsertData(String requestedAPI){
        NF_Nice_InContact_API_Config__mdt metaRecord = [
            SELECT
                DeveloperName, Attribute_Name_to_search_in_response__c, Check_Response_Body__c,
                Create_Records__c, Object_to_Create__c, Request_Body__c,
                Request_Endpoint__c, Request_Headers__c, Request_Timeout__c,
                Request_Type__c, Successful_Callout_Status_Code__c, Contain_conditions_In_Response_s_Records__c
            FROM
                NF_Nice_InContact_API_Config__mdt
            WHERE
                DeveloperName =: requestedAPI LIMIT 1
        ];

        HttpResponse resp = NF_CalloutUtility.doCallout(
            metaRecord.Request_Endpoint__c
            .replace('[BASE_URL]', resource_server_base_uri)
            .replace('[API_VERSION]', LABEL.NF_RC_API_VERSION_NUMBER)
            .replace('[START_DATE]', encodedStartDate)
            .replace('[END_DATE]', encodedEndDate)
            .replace('[SPECIFIC_ID]', specificId),
            metaRecord.Request_Type__c,
            Integer.valueOf(metaRecord.Request_Timeout__c),
            String.isNotBlank(metaRecord.Request_Headers__c) ?
                (Map<String, Object>)JSON.deserializeUntyped(
                    metaRecord.Request_Headers__c.replace('[ACCESS_TOKEN]', access_token)
                ) : null,
            metaRecord.Request_Body__c,
            Integer.valueOf(metaRecord.Successful_Callout_Status_Code__c),
            metaRecord.Check_Response_Body__c
        );

        switch on requestedAPI {
            when 'Authorization' {
                processAuthorization(resp.getBody());
            }
            when else {
                if(
                    metaRecord.Create_Records__c &&
                    String.isNotBlank(metaRecord.Object_to_Create__c) &&
                    String.isNotBlank(metaRecord.Attribute_Name_to_search_in_response__c)
                ){
                    processRecordCreation(
                        resp.getBody(), metaRecord.Object_to_Create__c,
                        requestedAPI, metaRecord.Attribute_Name_to_search_in_response__c,
                        metaRecord.Contain_conditions_In_Response_s_Records__c
                    );
                }
            }
        }
    }

    /**
    * @description Processes the authorization response and separates out the access key & url
    * @author chayan.batabyal@neuraflash.com | 09-07-2021
    * @param body
    **/
    @TestVisible
    private void processAuthorization(String body){
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(body);
        if(
            responseMap != null && !responseMap.keySet().isEmpty() &&
            String.isNotBlank(String.valueOf(responseMap.get('access_token'))) &&
            String.isNotBlank(String.valueOf(responseMap.get('resource_server_base_uri'))) &&
            String.isNotBlank(String.valueOf(responseMap.get('expires_in')))
        ){
            access_token = String.valueOf(responseMap.get('access_token'));
            resource_server_base_uri = String.valueOf(responseMap.get('resource_server_base_uri'));
            access_token_valid_till =
                System.now().addSeconds(Integer.valueOf(responseMap.get('expires_in')));
            authorizationError = false;
        }
        else{
            throw new NF_CalloutUtility.CalloutException(
                'Access token/Base URI/Access token expiry not received'
            );
        }
    }

    /**
    * @description Processes the response from actual API callout and inserts the records into DB
    * @author chayan.batabyal@neuraflash.com | 09-07-2021
    * @param response
    * @param sObjectAPIName
    * @param requestedAPI
    * @param attributeName
    **/
    @TestVisible
    private void processRecordCreation(
        String response, String sObjectAPIName, String requestedAPI, String attributeName, String containsCheck
    ){
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);

        if(responseMap != null && !responseMap.keySet().isEmpty()){
            if(
                responseMap.containsKey(attributeName) &&
                responseMap.get(attributeName) != null
            ){
                List<Object> lstRecords = (List<Object>)JSON.deserializeUntyped(
                    JSON.serialize(responseMap.get(attributeName))
                );

                if(lstRecords != null && !lstRecords.isEmpty()){
                    for(Integer count = 0; count < lstRecords.size(); count++){
                        String strRecord = String.valueOf(lstRecords[count]);
                        if(String.isNotBlank(containsCheck)){
                            for(String eachCheck : containsCheck.split('#^#')){
                                if(strRecord.toLowerCase().indexOf(eachCheck.toLowerCase()) == -1){
                                    lstRecords.remove(count--);
                                    break;
                                }
                            }
                        }
                    }

                    List<SObject> lstRecordsToInsert = createSObjectRecords(sObjectAPIName, lstRecords);
                    Database.insert(lstRecordsToInsert, false);
                }
            }
        }
    }

    /**
    * @description Creates list of SObject instances which are to be inserted.
    * @author chayan.batabyal@neuraflash.com | 09-07-2021
    * @param sObjectAPIName
    * @param lstRecords
    * @return List<SObject>
    **/
    @TestVisible
    private List<SObject> createSObjectRecords(String sObjectAPIName, List<Object> lstRecords){
        List<SObject> recordsToReturn = new List<SObject>();

        for(Object eachObjRecord : lstRecords){
            Map<String, Object> fieldMap = (Map<String, Object>)JSON.deserializeUntyped(
                JSON.serialize(eachObjRecord)
            );
            Schema.SObjectType targetType = Schema.getGlobalDescribe().get(sObjectAPIName);
            SObject newSobject = targetType.newSObject();
            Map<String, Schema.sObjectField> targetFields = targetType.getDescribe().fields.getMap();

            for (String key : fieldMap.keySet()){
                Object value = fieldMap.get(key);
                key = key + '__c'; // Every API Name is JSON attribute name + '__c'
                Schema.DisplayType valueType = targetFields.get(key).getDescribe().getType();

                if (value instanceof String && valueType != Schema.DisplayType.String){
                    String svalue = (String)value;
                    if(valueType == Schema.DisplayType.Boolean){
                        newSobject.put(key, Boolean.valueOf(svalue));
                    }
                    else if (valueType == Schema.DisplayType.Double){
                        newSobject.put(key, svalue == '' ? null : Double.valueOf(svalue));
                    }
                    else if(valueType == Schema.DisplayType.DateTime){
                        newSobject.put(key, DateTime.valueOfGmt(svalue.replace('T', ' ').replace('.000Z', '')));
                    }
                    /*else if (valueType == Schema.DisplayType.Integer){
                        newSobject.put(key, Integer.valueOf(svalue));
                    }
                    else if (valueType == Schema.DisplayType.Date){
                        newSobject.put(key, Date.valueOf(svalue));
                    }
                    else if (
                        valueType == Schema.DisplayType.Percent ||
                        valueType == Schema.DisplayType.Currency
                    ){
                        newSobject.put(key, svalue == '' ? null : Decimal.valueOf(svalue));
                    }
                    else if (valueType == Schema.DisplayType.Base64){
                        newSobject.put(key, Blob.valueOf(svalue));
                    } */
                    else{
                        newSobject.put(key, svalue);
                    }
                }
                else if (valueType == Schema.DisplayType.String){
                    newSobject.put(key, String.valueOf(value));
                }
                else{
                    newSobject.put(key, value);
                }
            }
            newSobject.put('Start_Date__c', DateTime.valueOf(
                EncodingUtil.urlDecode(encodedStartDate, 'UTF-8').replace('T', ' ')
            ));
            newSobject.put('End_Date__c', DateTime.valueOf(
                EncodingUtil.urlDecode(encodedEndDate, 'UTF-8').replace('T', ' ')
            ));

            if(targetFields.containsKey('Specific_Id__c')){
                newSobject.put('Specific_Id__c', specificId);
            }

            recordsToReturn.add(newSobject);
        }

        return recordsToReturn;
    }
}