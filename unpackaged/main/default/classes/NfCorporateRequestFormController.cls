/**
* @author : Luis Rocha / Neuraflash
* @description : Controller for LWC that displays corporate form.
* All data that is used here is in a public site. Therefore without sharing is used to 
* --be able to upload files and create a case with the recordtype provided in the builder. 
* Ver       Date            Modification 
* 1.0       04/05/2022      Initial Version
*/
public without sharing class NfCorporateRequestFormController {
    /**
     * @description uploadFile description
     * @param  caseId   caseId description
     * @param  file     file description
     * @param  fileName fileName description
     * @return          return description
     */
    @AuraEnabled  
    public static string uploadFile(String caseId, string file, string fileName) {  
        try{  
            String base64File = EncodingUtil.urlDecode(file, 'UTF-8');     
            ContentVersion contentVersionRec = new ContentVersion();  
            contentVersionRec.Title = fileName;  
            contentVersionRec.PathOnClient = '/' + fileName;  
            contentVersionRec.FirstPublishLocationId = caseId;
            contentVersionRec.VersionData = EncodingUtil.base64Decode(base64File);  
            contentVersionRec.IsMajorVersion = true;  
            Insert contentVersionRec;  
        } catch(Exception ex){  
            Logger.logException(ex);
            throw new AuraHandledException(ex.getMessage());
        }  
        return caseId;  
    }
    /**
     * @description retrieveFormConfiguration description
     * @return   return description
     */ 
    @AuraEnabled
    public static List<Corporate_Form_Configuration__c>  retrieveFormConfiguration(){
        List<Corporate_Form_Configuration__c> cfcList = new List<Corporate_Form_Configuration__c>();
        try {
            cfcList = [Select BusinessGroup__c, FieldData__c FROM Corporate_Form_Configuration__c];
        } catch (Exception ex) {
            Logger.logException(ex);
            throw new AuraHandledException(ex.getMessage());
        }
        return cfcList;
    }
    /**
     * @description retrieveFields description
     * @return   return description
     */
    @AuraEnabled
    public static List<String> retrieveFields(){
        try {
            Schema.DescribeSObjectResult r = Case.sObjectType.getDescribe();
            List<String>apiNames =  new list<String>();
            for(string apiName : r.fields.getMap().keySet()){
                apiNames.add(apiName);
            }
            return apiNames;
        } catch (Exception ex) {
            Logger.logException(ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }
    /**
     * @description retrieveFieldsApiAndLabel description
     * @return   return description
     */
    @AuraEnabled
    public static List<sObjectUtils.FieldsLabelAndName> retrieveFieldsApiAndLabel(){
        try {
            return sObjectUtils.getFields('Case');
        } catch (Exception ex) {
            Logger.logException(ex); 
            throw new AuraHandledException(ex.getMessage());
        }
    }
    /**
     * @description retreiveRecordType description
     * @param  recordTypeName recordTypeName description
     * @return                return description
     */
    @AuraEnabled
    public static string retreiveRecordType(String recordTypeName){
        try {
            return Schema.SObjectType.Case.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        } catch (Exception ex) {
            Logger.logException(ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }
    /**
     * @description createCase description
     * @param  caseData       caseData description
     * @param  recordTypeName recordTypeName description
     * @return                return description
     */
    @AuraEnabled
    public static Map<String,String> createCase(String caseData,String recordTypeName){
        Map<String,String> returnParamaters = new Map<String,String>();
        try {
            Case currentCase = (Case)JSON.deserialize(caseData, Case.Class);
            currentCase.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
            currentCase.Email_Assignment_Code__c = 'I';
            currentCase.Origin = 'Web';
            AssignmentRule assignRule = [select id from AssignmentRule where SobjectType = 'Case' and Active = true and Name='Case Assignment Rule' limit 1];
            Database.DMLOptions dmls = new Database.DMLOptions(); //Creating the DMLOptions for "Assign using active assignment rules" checkbox
            dmls.assignmentRuleHeader.assignmentRuleId= assignRule.id;
            currentCase.setOptions(dmls);
            currentCase.Subject = 'Corporate Request - ' + currentCase.Business_Group__c;
            insert currentCase;    
            currentCase = [Select CaseNumber FROM Case WHERE ID =: currentCase.Id];
            List<String> params = new List<String>{currentCase.CaseNumber};
            String msgLabel = Label.nfThank_you_message;
            String thankyoumessage = String.format(msgLabel, params);
            returnParamaters.put('CASENUMBER',currentCase.CaseNumber);
            returnParamaters.put('CASEID',currentCase.Id);
            returnParamaters.put('THANKYOUMESSAGE', thankyoumessage);
        } catch (Exception ex) {
            Logger.logException(ex);
            throw new AuraHandledException(ex.getMessage());
        }
        return returnParamaters;
    }
    /**
     * @description saveFiles description
     * @param  filesToInsert filesToInsert description
     * @param  caseId        caseId description
     * @return               return description
     */ 
    @AuraEnabled
    public static list<Id> saveFiles(list<Object> filesToInsert, Id caseId){
        list<Id> lstCntVerIds = new list<Id>();
        try{
            List<ContentVersion> lstVersionsToInsert = new List<ContentVersion>();
            for (Object file : filesToInsert) {
                FileInfo fileData = (FileInfo)JSON.deserialize(JSON.serialize(file), FileInfo.class);
                ContentVersion objCntVersion = new ContentVersion();
                objCntVersion.PathOnClient = fileData.Title;
                objCntVersion.Title = fileData.Title;
                objCntVersion.VersionData = fileData.VersionData;
                objCntVersion.FirstPublishLocationId = caseId;
                lstVersionsToInsert.add(objCntVersion);
            }
            list<Database.saveResult> res = Database.insert(lstVersionsToInsert);
            for (Database.SaveResult saveResult : res) {
                if(saveResult.isSuccess()) {
                    lstCntVerIds.add(saveResult.getId());
                }
            }
        } catch (Exception ex){
            Logger.logException(ex);
            throw new AuraHandledException(ex.getMessage());
        }
        return lstCntVerIds;
    }
    public class FileInfo {
        public String Title;
        public Blob VersionData;
    }
}