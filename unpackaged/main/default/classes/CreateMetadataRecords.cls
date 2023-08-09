public class CreateMetadataRecords implements Metadata.DeployCallback{
    public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context){
        if (result.status == Metadata.DeployStatus.Succeeded){
            Log.push('Success result : ' + result);
        } else{
            Log.push('fails result : ' + result);
        }
        Logger.logDebug();
    }

    //method: To update valid access token in SFMC_AccessTokens Metadata
    public static void updateSFMC_AccessTokens_mdtRecords(Scheduler_SFMCAccessTokens.responseClass responseClassValues){
        SFMC_AccessTokens__mdt tokenRecord = [Select DeveloperName, MasterLabel, Access_Token__c, Expires_In__c, Expires_At__c
                                              FROM SFMC_AccessTokens__mdt
                                              where DeveloperName =: SYSTEM.LABEL.Token_1
                                              LIMIT 1];

        Log.push('*** Old Access Token Record = ' + tokenRecord);
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        Scheduler_SFMCAccessTokens.responseClass getResponse = responseClassValues;
        Log.push('*****get token = ' + getResponse.access_token);
        Log.push('*****get expired in = ' + getResponse.expires_in);

        Datetime tokenExpiryDate = ((System.now().addSeconds(Integer.valueOf(getResponse.expires_in))));

        Log.push('*****get expirydate = ' + tokenExpiryDate);
        tokenExpiryDate = tokenExpiryDate.addMinutes(-4);
        Log.push('*****get final expirydate = ' + tokenExpiryDate);
        Datetime CurrentTime = datetime.now();
        String currentTimeVal = String.valueOf(CurrentTime.getTime());

        Metadata.CustomMetadata customMetadata = new Metadata.CustomMetadata();
        String recordName = tokenRecord.DeveloperName;
        Log.push('*****Record Name = ' + recordName);
        customMetadata.fullName = SYSTEM.LABEL.SFMC_AccessTokens + recordName;
        customMetadata.label = recordName;

        Metadata.CustomMetadataValue accessTokenValue = new Metadata.CustomMetadataValue();
        accessTokenValue.field = SYSTEM.LABEL.Access_Token;
        accessTokenValue.value = String.valueOf(getResponse.access_token);
        customMetadata.values.add(accessTokenValue);

        Metadata.CustomMetadataValue expiresAtValue = new Metadata.CustomMetadataValue();
        expiresAtValue.field = SYSTEM.LABEL.Expires_At;
        expiresAtValue.value = tokenExpiryDate;
        customMetadata.values.add(expiresAtValue);

        Metadata.CustomMetadataValue expiresInValue = new Metadata.CustomMetadataValue();
        expiresInValue.field = SYSTEM.LABEL.Expires_In;
        expiresInValue.value = String.valueOf(getResponse.expires_in);
        customMetadata.values.add(expiresInValue);

        mdContainer.addMetadata(customMetadata);

        CreateMetadataRecords callback = new CreateMetadataRecords();
        if (!Test.isRunningTest()){
            Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
            Log.push('*****Update Metadata JobId:' + jobId);
        }
    }

    //method: To update valid access token in SFMC_AccessTokens Metadata
    public static void CKupdateSFMC_AccessTokens_mdtRecords(CKScheduler_SFMCAccessTokens.responseClass responseClassValues){
        SFMC_AccessTokens__mdt tokenRecord = [Select DeveloperName, MasterLabel, Access_Token__c, Expires_In__c, Expires_At__c
                                              FROM SFMC_AccessTokens__mdt
                                              where DeveloperName =: SYSTEM.LABEL.Token_2
                                              LIMIT 1];

        Log.push('*** Old Access Token Record = ' + tokenRecord);
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        CKScheduler_SFMCAccessTokens.responseClass getResponse = responseClassValues;
        Log.push('*****get token = ' + getResponse.access_token);
        Log.push('*****get expired in = ' + getResponse.expires_in);

        Datetime tokenExpiryDate = ((System.now().addSeconds(Integer.valueOf(getResponse.expires_in))));

        Log.push('*****get expirydate = ' + tokenExpiryDate);
        tokenExpiryDate = tokenExpiryDate.addMinutes(-4);
        Log.push('*****get final expirydate = ' + tokenExpiryDate);
        Datetime CurrentTime = datetime.now();
        String currentTimeVal = String.valueOf(CurrentTime.getTime());

        Metadata.CustomMetadata customMetadata = new Metadata.CustomMetadata();
        String recordName = tokenRecord.DeveloperName;
        Log.push('*****Record Name = ' + recordName);
        customMetadata.fullName = 'SFMC_AccessTokens.' + recordName;
        customMetadata.label = recordName;

        Metadata.CustomMetadataValue accessTokenValue = new Metadata.CustomMetadataValue();
        accessTokenValue.field = SYSTEM.LABEL.Access_Token;
        accessTokenValue.value = String.valueOf(getResponse.access_token);
        customMetadata.values.add(accessTokenValue);

        Metadata.CustomMetadataValue expiresAtValue = new Metadata.CustomMetadataValue();
        expiresAtValue.field = SYSTEM.LABEL.Expires_At;
        expiresAtValue.value = tokenExpiryDate;
        customMetadata.values.add(expiresAtValue);

        Metadata.CustomMetadataValue expiresInValue = new Metadata.CustomMetadataValue();
        expiresInValue.field = SYSTEM.LABEL.Expires_In;
        expiresInValue.value = String.valueOf(getResponse.expires_in);
        customMetadata.values.add(expiresInValue);

        mdContainer.addMetadata(customMetadata);

        CreateMetadataRecords callback = new CreateMetadataRecords();
        if (!Test.isRunningTest()){
            Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
            Log.push('*****Update Metadata JobId:' + jobId);
        }
        Logger.logDebug();
    }

    /*
     public static void createSFMC_AccessTokens_mdtRecords(Scheduler_SFMCAccessTokens.responseClass responseClassValues)
     {

     Log.push('*****inside createSFMC_AccessTokens_mdtRecords()');
     Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
     Scheduler_SFMCAccessTokens.responseClass getResponse = responseClassValues;
     Log.push('*****get token = '+getResponse.access_token);
     Log.push('*****get expired in = '+getResponse.expires_in);

     Datetime tokenExpiryDate = ((System.now().addSeconds(Integer.valueOf(getResponse.expires_in))));

     Log.push('*****get expirydate = '+tokenExpiryDate);
     tokenExpiryDate = tokenExpiryDate.addMinutes(-4);
     Log.push('*****get final expirydate = '+tokenExpiryDate);
     Datetime CurrentTime = datetime.now();
     String currentTimeVal = String.valueOf(CurrentTime.getTime());

     Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
     String recordName = 'Token'+currentTimeVal;
     customMetadata.fullName = 'SFMC_AccessTokens.'+recordName;
     customMetadata.label = recordName;

     Metadata.CustomMetadataValue accessTokenValue = new Metadata.CustomMetadataValue();
     accessTokenValue.field = 'Access_Token__c';
     accessTokenValue.value = String.valueOf(getResponse.access_token);
     customMetadata.values.add(accessTokenValue);

     Metadata.CustomMetadataValue expiresAtValue = new Metadata.CustomMetadataValue();
     expiresAtValue.field = 'Expires_At__c';
     expiresAtValue.value = tokenExpiryDate;
     customMetadata.values.add(expiresAtValue);

     Metadata.CustomMetadataValue expiresInValue = new Metadata.CustomMetadataValue();
     expiresInValue.field = 'Expires_In__c';
     expiresInValue.value = String.valueOf(getResponse.expires_in);
     customMetadata.values.add(expiresInValue);

     mdContainer.addMetadata(customMetadata);

     CreateMetadataRecords callback  = new CreateMetadataRecords();
     if(!Test.isRunningTest()){
     Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback );
     Log.push('*****Insert Metadata JobId:'+jobId);
     }

     }
     */
}