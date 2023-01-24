public class CreateMetadataRecords implements Metadata.DeployCallback {
    public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context ){
        if(result.status == Metadata.DeployStatus.Succeeded){
            System.debug('Success result : '+result);
        } else{
            System.debug('fails result : '+result);
        }
    }     
        
    //method: To update valid access token in SFMC_AccessTokens Metadata
    public static void updateSFMC_AccessTokens_mdtRecords(Scheduler_SFMCAccessTokens.responseClass responseClassValues){
        SFMC_AccessTokens__mdt tokenRecord = [Select DeveloperName, MasterLabel, Access_Token__c, Expires_In__c, Expires_At__c
                                              FROM SFMC_AccessTokens__mdt where DeveloperName='Token_1'  LIMIT 1];
        
        System.debug('*** Old Access Token Record = '+tokenRecord);
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer(); 
        Scheduler_SFMCAccessTokens.responseClass getResponse = responseClassValues;
        System.debug('*****get token = '+getResponse.access_token);
        System.debug('*****get expired in = '+getResponse.expires_in);
        
        Datetime tokenExpiryDate = ((System.now().addSeconds(Integer.valueOf(getResponse.expires_in))));
        
        System.debug('*****get expirydate = '+tokenExpiryDate);
        tokenExpiryDate = tokenExpiryDate.addMinutes(-4);
        System.debug('*****get final expirydate = '+tokenExpiryDate);
        Datetime CurrentTime = datetime.now();
        String currentTimeVal = String.valueOf(CurrentTime.getTime());
        
        Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
        String recordName = tokenRecord.DeveloperName;
        System.debug('*****Record Name = '+recordName);
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
            System.debug('*****Update Metadata JobId:'+jobId);
        }

    }
    //method: To update valid access token in SFMC_AccessTokens Metadata
    public static void CKupdateSFMC_AccessTokens_mdtRecords(CKScheduler_SFMCAccessTokens.responseClass responseClassValues){
        SFMC_AccessTokens__mdt tokenRecord = [Select DeveloperName, MasterLabel, Access_Token__c, Expires_In__c, Expires_At__c
                                              FROM SFMC_AccessTokens__mdt where DeveloperName!='Token_1' LIMIT 1];
        
        System.debug('*** Old Access Token Record = '+tokenRecord);
       Metadata.DeployContainer mdContainer = new Metadata.DeployContainer(); 
        CKScheduler_SFMCAccessTokens.responseClass getResponse = responseClassValues;
        System.debug('*****get token = '+getResponse.access_token);
        System.debug('*****get expired in = '+getResponse.expires_in);
        
        Datetime tokenExpiryDate = ((System.now().addSeconds(Integer.valueOf(getResponse.expires_in))));
        
        System.debug('*****get expirydate = '+tokenExpiryDate);
        tokenExpiryDate = tokenExpiryDate.addMinutes(-4);
        System.debug('*****get final expirydate = '+tokenExpiryDate);
        Datetime CurrentTime = datetime.now();
        String currentTimeVal = String.valueOf(CurrentTime.getTime());
        
        Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
        String recordName = tokenRecord.DeveloperName;
        System.debug('*****Record Name = '+recordName);
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
            System.debug('*****Update Metadata JobId:'+jobId);
        }

    }
    
    
    
    
    /*
    public static void createSFMC_AccessTokens_mdtRecords(Scheduler_SFMCAccessTokens.responseClass responseClassValues)
    {
        
        System.debug('*****inside createSFMC_AccessTokens_mdtRecords()');
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer(); 
        Scheduler_SFMCAccessTokens.responseClass getResponse = responseClassValues;
        System.debug('*****get token = '+getResponse.access_token);
        System.debug('*****get expired in = '+getResponse.expires_in);
        
        Datetime tokenExpiryDate = ((System.now().addSeconds(Integer.valueOf(getResponse.expires_in))));
        
        System.debug('*****get expirydate = '+tokenExpiryDate);
        tokenExpiryDate = tokenExpiryDate.addMinutes(-4);
        System.debug('*****get final expirydate = '+tokenExpiryDate);
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
            System.debug('*****Insert Metadata JobId:'+jobId);
        }
     
    }
    */
    
}