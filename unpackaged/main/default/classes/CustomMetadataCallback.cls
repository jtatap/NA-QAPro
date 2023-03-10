/******************************************************************************
* @Description: Create Custom MetadataType records
* @Author	  : Dhiren ,Trupti Bhirud 
* @Date		  : 01:01.2020
* @JIRA		  : NASSC-1190
*
******************************************************************************/   
//Classback to insert Metadata record 
public class CustomMetadataCallback implements Metadata.DeployCallback{
    public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context ){
        if(result.status == Metadata.DeployStatus.Succeeded){
            System.debug('Success result : '+result);
        } else{
            System.debug('fails result : '+result);
        }
    }
    
    //Creates A1_C360API_Tokens__mdt metadata record for active c360 toekn
    public static void createMetaDataA1c360APIToken(Map <A1_C360API_creds__mdt,Scheduler_A1C360APITokens.responseClass> responseValAndMetdataMap){
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer(); 
        
        for(A1_C360API_creds__mdt credRec :responseValAndMetdataMap.keyset()){                  
            Scheduler_A1C360APITokens.responseClass resp = responseValAndMetdataMap.get(credRec); 
            System.debug('Metadata name'+credRec.BrandId__c);
            System.debug('Response '+resp.access_token);
            Datetime expireDate = ((System.now().addSeconds(Integer.valueOf(resp.expires_in)))-1);            
            Datetime CurrentTime = datetime.now();
            String currentTimeVal = String.valueOf(CurrentTime.getTime());
            
            Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
            String recName = credRec.DeveloperName+currentTimeVal;
            customMetadata.fullName = 'A1_C360API_Tokens.'+recName;
            customMetadata.label = recName;
            
            Metadata.CustomMetadataValue customField2 = new Metadata.CustomMetadataValue();  
            customField2.field = 'access_token__c' ;
            customField2.value = String.valueOf(resp.access_token);
            customMetadata.values.add(customField2);
            
            Metadata.CustomMetadataValue customField3 = new Metadata.CustomMetadataValue(); 
            customField3.field = 'BrandId__c' ;
            customField3.value = credRec.BrandId__c;
            customMetadata.values.add(customField3); 
            
            Metadata.CustomMetadataValue customField4 = new Metadata.CustomMetadataValue(); 
            customField4.field = 'expires_at__c' ;
            customField4.value = expireDate;
            customMetadata.values.add(customField4);
            
            Metadata.CustomMetadataValue customField5 = new Metadata.CustomMetadataValue(); 
            customField5.field = 'expires_in__c' ;
            customField5.value = resp.expires_in;
            customMetadata.values.add(customField5);            
            
            mdContainer.addMetadata(customMetadata);
        }        
        CustomMetadataCallback callback = new CustomMetadataCallback();
		if(!Test.isRunningTest()){        
        	Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
            System.debug('Metadata JobId:'+jobId);
        }
       
        
    }
   
    //Create A1_TrackerAPI_tokens__mdt record and store access toekn in it
    public static void createTrackerAPITokenMetaData(Map <A1_TrackerAPI_creds__mdt,Scheduler_A1TrackerAPITokens.responseClass> responseValAndMetdataMap){
        System.debug('Respons in custom metadata'+responseValAndMetdataMap);

        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        
        for(A1_TrackerAPI_creds__mdt trackerCredRec: responseValAndMetdataMap.keySet()){
            Scheduler_A1TrackerAPITokens.responseClass respVal = responseValAndMetdataMap.get(trackerCredRec);
            Datetime expireDate = ((System.now().addSeconds(Integer.valueOf(respVal.expires_in)))-1);
            Datetime CurrentTime = datetime.now();
            String currentTimeVal = String.valueOf(CurrentTime.getTime());
                
            Metadata.CustomMetadata CustomMetadata =  new Metadata.CustomMetadata();
            //String recName = trackerCredRec.MasterLabel+currentTimeVal;
            //CustomMetadata.fullName = ('A1_TrackerAPI_tokens__mdt.'+recName).remove(' ');
            
            String recName = trackerCredRec.DeveloperName+currentTimeVal;
			customMetadata.fullName = 'A1_TrackerAPI_tokens__mdt.'+recName;
            System.debug('CustomMetadata.fullName:'+CustomMetadata.fullName);
            CustomMetadata.label = recName;
            
            Metadata.CustomMetadataValue customField2 = new Metadata.CustomMetadataValue();  
            customField2.field = 'access_token__c' ;
            customField2.value = String.valueOf(respVal.access_token);
            CustomMetadata.values.add(customField2);
            
            Metadata.CustomMetadataValue customField3 = new Metadata.CustomMetadataValue(); 
            customField3.field = 'BrandId__c' ;
            customField3.value = trackerCredRec.BrandId__c;
            CustomMetadata.values.add(customField3); 
            
            Metadata.CustomMetadataValue customField4 = new Metadata.CustomMetadataValue(); 
            customField4.field = 'token_expires_at__c' ;
            customField4.value = expireDate;
            CustomMetadata.values.add(customField4); 
            
            Metadata.CustomMetadataValue customField5 = new Metadata.CustomMetadataValue(); 
            customField5.field = 'token_expires_in__c' ;
            customField5.value = respVal.expires_in;
            CustomMetadata.values.add(customField5); 
            
            mdContainer.addMetadata(customMetadata);
            System.debug('customMetadata:'+customMetadata);
        }
        CustomMetadataCallback callback = new CustomMetadataCallback();
        
        if(!Test.isRunningTest()){
            Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
        	System.debug('Metadata JobId:'+jobId);
        }
    }
    //update acccess key and key expires in fields on metadatatype
    public static void updateTrackerAccessKey(A1_TrackerAPI_tokens__mdt trackerkey){
      Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();       
         Metadata.CustomMetadata CustomMetadata =  new Metadata.CustomMetadata();
         CustomMetadata.label = trackerkey.label;
         customMetadata.fullName = 'A1_TrackerAPI_tokens.'+trackerkey.DeveloperName;

         Metadata.CustomMetadataValue customField5 = new Metadata.CustomMetadataValue(); 
         customField5.field = 'access_key__c' ;
         customField5.value = trackerkey.access_key__c;
         CustomMetadata.values.add(customField5); 
                        
         Metadata.CustomMetadataValue customField4 = new Metadata.CustomMetadataValue(); 
         customField4.field = 'key_expires_at__c' ;
         customField4.value = System.now().addDays(1);
         CustomMetadata.values.add(customField4);            

         mdContainer.addMetadata(customMetadata);
         System.debug('customMetadata:'+customMetadata);
        CustomMetadataCallback callback = new CustomMetadataCallback();        
        if(!Test.isRunningTest()){
            Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
        	System.debug('Metadata JobId:'+jobId);
        } 
     }
    
}