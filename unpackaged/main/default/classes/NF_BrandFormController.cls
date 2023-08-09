/**
 * @description       : Controller class for communityBrandForm LWC
 * @author            :
 * @last modified on  : 08-30-2021
 * @last modified by  : chayan.batabyal@neuraflash.com
**/
public without sharing class NF_BrandFormController {

    private static String TARGET_OBJECT = 'Case';
    private static String SOURCE_FIELD_SET = 'Brand_Form';
    private static String RECORD_TYPE = 'Support_Case';
    private static Map<String,Schema.SObjectType> orgObjectDetails;
    private static FormConfig config;

    @AuraEnabled
    public static FormConfig getFormConfig(String brandname){
        FormConfig formConfigObj;
        if(String.isNotBlank(brandname)){
            config = new FormConfig();
            config.brand = getBrandConfig(brandname);

            formConfigObj = new FormConfig();

            // 1. Add Field set data as a list of wrapper
            formConfigObj.fields = getFieldDetails(TARGET_OBJECT,SOURCE_FIELD_SET);

            //2. Bring brand related picklist values
            formConfigObj.fieldOptions = getPicklistOptions(brandname);

            //3. Set brand code
            formConfigObj.brand = config.brand;
        }
        Log.push('formConfigObj.fields'+formConfigObj.fields);
        Logger.logDebug();
        //return JSON.serialize(formConfigObj);
        return formConfigObj;
    }

    @AuraEnabled
    public static String createCase(String recordString){
        String operationResult;
        Log.push('recordString >> ' + recordString);
        try{
            if(String.isNotBlank(recordString)){
                Map<String,Object> recordObject = (Map<String,Object>) JSON.deserializeUntyped(recordString);

                //Filter out the related files
                CaseAttachmentObject caob = new CaseAttachmentObject();
                caob.filesToDelete = (List<FileObject>)JSON.deserialize(JSON.serialize(recordObject.get('filesToDelete')),List<FileObject>.class);
                caob.filesToLink = (List<FileObject>)JSON.deserialize(JSON.serialize(recordObject.get('filesToRelate')),List<FileObject>.class);

                Log.push('caob >> ' + caob);

                //Remove file related keys
                recordObject.remove('filesToDelete');
                recordObject.remove('filesToRelate');

                if(recordObject != NULL){

                    //Get Org schema
                    orgObjectDetails = Schema.getGlobalDescribe();

                    //Create new SObject instance dynamically
                    SObjectType caseType = orgObjectDetails.get(TARGET_OBJECT);
                    SObject caseRecord = caseType.newSObject();

                    //Set all field values
                    for(String key : recordObject.keySet()){
                        caseRecord.put(key,String.valueOf(recordObject.get(key)));
                    }

                    //The lines 82 - 91 are commented out by Nishant (Neuraflash) since the Reason_Code__c
                    // and Reason_Code_Details__c are not being used to set any other fields going forward

                    /**
                     * If "Reason_Code__c" is "Loyalty"
                     * and "Reason_Code_Details__c" is "Edit Account Information"
                     * then set "ZdPVHUpdateAccountInfoReason__c" same as the "Description" of the case with 255 characters limit.
                     */

                     /*
                    if(String.valueOf(caseRecord.get('Reason_Code__c')) == 'Loyalty'
                    && String.valueOf(caseRecord.get('Reason_Code_Details__c')) == 'Edit Account Information'){
                        String caseDescription = String.valueOf(caseRecord.get('Description'));
                        Integer maxLength = caseDescription.length() > 255 ? 255 : caseDescription.length();
                        caseDescription = caseDescription.substring(0, maxLength);
                        caseRecord.put('ZdPVHUpdateAccountInfoReason__c',caseDescription);
                    }
                    */

                    //The lines 82 - 91 are commented out by Nishant (Neuraflash) since the Reason_Code__c
                    // and Reason_Code_Details__c are not being used to set any other fields going forward

                    /**
                     * If "Reason_Code__c" is "Product"
                     * and "Reason_Code_Details__c" is "Defective Mechandise"
                     * then set "Product_Category__c" and "ZdPVHManufacturer__c" as
                     * "Web Form Submission".
                     */

                    /*
                    Log.push('caseRecord Reason_Code__c: ' + String.valueOf(caseRecord.get('Reason_Code__c')));
                    Log.push('caseRecord Reason_Code_Details__c: ' + String.valueOf(caseRecord.get('Reason_Code_Details__c')));

                    if(String.valueOf(caseRecord.get('Reason_Code__c')) == 'Product'
                    && String.valueOf(caseRecord.get('Reason_Code_Details__c')) == 'Defective Merchandise'){
                        Log.push('caseRecord update for defective thing');
                        caseRecord.put('Reason_Code_Product_Category__c','Web Form Submission');
                        caseRecord.put('Reason_Code_Manufacturers__c','Web Form Submission');
                    }
                    */
                    //Case Origin as Web Form
                    caseRecord.put('Origin','Web');

                    //Calculate Record Type Id and set in Case Record
                    Id recordTypeIdSupportCase = caseType.getDescribe().getRecordTypeInfosByDeveloperName().get(RECORD_TYPE).getRecordTypeId();
                    caseRecord.put('RecordTypeId',recordTypeIdSupportCase);

                    Log.push('caseRecord before insert: ' + caseRecord);
                    
                    //Fetching the assignment rules on case
                    AssignmentRule assignRule = new AssignmentRule(); 
                    assignRule = [select id from AssignmentRule where SobjectType = 'Case' and Active = true and Name='Case Assignment Rule' limit 1];
                    Log.push('assignRule***'+assignRule);
                    //Creating the DMLOptions for "Assign using active assignment rules" checkbox
                    Database.DMLOptions dmls = new Database.DMLOptions();
                    dmls.assignmentRuleHeader.assignmentRuleId= assignRule.id;
                    Log.push('dmls***'+dmls);
                    caseRecord.setOptions(dmls);
                    
                    
                    
                    String reasonCodeDetail = String.valueOf(caseRecord.get('Reason_Code_Details__c'));
                    System.debug('reasonCodeDetail @127: ' + reasonCodeDetail);
                    List<NF_Case_Scenario__c> scenarios = new List<NF_Case_Scenario__c>();

                    try{
                        scenarios = [SELECT Id FROM NF_Case_Scenario__c WHERE Name =:reasonCodeDetail LIMIT 1];
                        if(scenarios[0] != null){
                            caseRecord.put('NFCaseScenario__c', String.valueOf(scenarios[0].Id));
                        }
                    }
                    catch(Exception e){
                        ErrorLog__c log = new ErrorLog__c();
                        log.Message__c = e.getMessage();
                        log.StackTrace__c = e.getStackTraceString();
                        insert log;
                    }
                    //Reason_Code__c abd Reason_Code_Details__c fields will not be populated going forward
                    caseRecord.put('Reason_Code__c', null);
                    caseRecord.put('Reason_Code_Details__c', null);
                    insert caseRecord;
                    

                    //Link case record with files
                    caob.parentId = caseRecord.Id;
                    processCaseRelatedFiles(caob);

                    //Query Case number
                    caseRecord = getCase(caseRecord.Id);
                    Log.push('Case record >> ' + caseRecord);

                    if(caseRecord != NULL){
                        operationResult = 'SUCCESS:' + caseRecord.get('CaseNumber');
                    }
                }
            }
        }
        catch(Exception ex){
            Logger.logException(ex);
            operationResult = 'EXCEPTION: ' + ex.getStackTraceString() + ex.getMessage();
        }
        Logger.logDebug();
        return operationResult;
    }

    @AuraEnabled
    public static String updateFileDescription(String fileObject){
        String result = 'File update started';
        List<FileObject> allFiles;

        Log.push('fileObject: ' + fileObject);

        if(String.isNotBlank(fileObject)){
            allFiles = (List<FileObject>) JSON.deserialize(fileObject, List<FileObject>.class);
        }

        Log.push('allFiles: ' + allFiles);

        if(allFiles != NULL && !allFiles.isEmpty()){
            //List<ContentDocument> files = [SELECT Id, Title, Description FROM ContentDocument WHERE Title IN : allFiles ORDER BY CreatedDate DESC];
            List<ContentDocument> files = new List<ContentDocument>();

            Log.push('New files: ' + files);

            for(FileObject cd : allFiles){
                ContentDocument cdf = new ContentDocument();
                cdf.Id = cd.documentId;
                cdf.Description = 'Brand Form File';
                files.add(cdf);
            }

            update files;
            result = 'File update completed.';
        }
        else{
            result = 'No related files found.';
        }
        Logger.logDebug();
        return result;
    }

    private static Case getCase(String caseId){
        return [SELECT CaseNumber, Channel__c FROM Case WHERE Id =: caseId];
    }

    private static Map<String,List<PicklistObject>> getPicklistOptions(String brandname){
        Map<String,List<PicklistObject>> optionConfig;
        if(String.isNotBlank(brandname)){
            optionConfig = new Map<String,List<PicklistObject>>();

            /** Channel__c field values */
            String query = '';
            query += 'SELECT DeveloperName, Label__c, Value__c, Order__c, Additional_Information__c, Type__c FROM ';
            query += NF_Brand_Form_Constants.fieldMetadata.get('Channel__c');
            query += ' WHERE Brand__r.MasterLabel = \''+ brandname +'\' ORDER BY Order__c ASC';
            List<SObject> pickListOptions = Database.query(query);

            optionConfig.put('Channel__c',new List<PicklistObject>());

            // Add default entry of '--- Select Option ---'
            optionConfig.get('Channel__c').add(selectOption());

            Integer key = 0;
            for(Brand_Form_Brand_Channel__mdt sob : (List<Brand_Form_Brand_Channel__mdt>)pickListOptions){
                PicklistObject pob = new PicklistObject();
                pob.label = String.valueOf(sob.get('Label__c'));
                pob.value = String.valueOf(sob.get('Value__c'));
                pob.order = Integer.valueOf(sob.get('Order__c'));
                if(String.isNotBlank(String.valueOf(sob.get('Additional_Information__c')))){
                    pob.information = String.valueOf(sob.get('Additional_Information__c'));
                }
                if(String.isNotBlank(sob.Type__c)){
                    pob.type = sob.Type__c;
                }
                pob.key = ++key;
                optionConfig.get('Channel__c').add(pob);
            }
            Log.push('Brand_Form_Brand_Channel__mdt Picklist: ' + optionConfig.get('Channel__c').size());

            /** Reason_Code__c field values */
            query = '';
            query += 'SELECT DeveloperName, Label__c, Value__c, Order__c, (SELECT Label__c, Value__c, Order__c, Additional_Information_ECom_Single__c, No_ECom_Single_Channel__c, ';
            query += 'Additional_Information_Other_Retail__c, No_Other_Retail_Channel__c, Additional_Information_Retail__c, No_Retail_Channel__c, ';
            query += ('Secondary_Action_Type__c FROM Brand_Form_Additional_Details__r) FROM ' + NF_Brand_Form_Constants.fieldMetadata.get('Reason_Code__c'));
            query += ' WHERE Brand__r.MasterLabel = \''+ brandname +'\' ORDER BY Order__c ASC';
            pickListOptions = Database.query(query);

            optionConfig.put('Reason_Code__c',new List<PicklistObject>());
            optionConfig.put('Reason_Code_Details__c',new List<PicklistObject>());

            // Add default entry of '--- Select Option ---'
            optionConfig.get('Reason_Code__c').add(selectOption());
            optionConfig.get('Reason_Code_Details__c').add(selectOption());

            key = 0;
            for(Brand_Form_Help_Topics__mdt sob : (List<Brand_Form_Help_Topics__mdt>)pickListOptions){
                PicklistObject pob = new PicklistObject();
                pob.label = String.valueOf(sob.get('Label__c'));
                pob.value = String.valueOf(sob.get('Value__c'));
                pob.order = Integer.valueOf(sob.get('Order__c'));
                pob.key = ++key;
                pob.availableChannels = '#';
                pob.developerName = String.valueOf(sob.get('DeveloperName'));

                Integer adobKey = 0;
                for(Brand_Form_Additional_Details__mdt ad : sob.Brand_Form_Additional_Details__r){
                    PicklistObject adob = new PicklistObject();
                    adob.label = String.valueOf(ad.get('Label__c'));
                    adob.value = String.valueOf(ad.get('Value__c'));
                    adob.order = Integer.valueOf(ad.get('Order__c'));
                    adob.information = String.valueOf(ad.get('Additional_Information_ECom_Single__c'));
                    adob.additionalRetail = String.valueOf(ad.get('Additional_Information_Retail__c'));
                    adob.additionalOtherRetail = String.valueOf(ad.get('Additional_Information_Other_Retail__c'));
                    adob.noECom = ad.No_ECom_Single_Channel__c;
                    adob.noSingle = ad.No_ECom_Single_Channel__c;
                    adob.noRetail = ad.No_Retail_Channel__c;
                    adob.noOtherRetailer = ad.No_Other_Retail_Channel__c;
                    adob.key = ++adobKey;
                    adob.parent = pob.label;
                    adob.show = false;
                    adob.secondaryAction = String.valueOf(ad.get('Secondary_Action_Type__c'));
                    adob.developerName = pob.developerName;
                    optionConfig.get('Reason_Code_Details__c').add(adob);

                    if(!ad.No_ECom_Single_Channel__c && pob.availableChannels.indexOf('#ECom#Single#') == -1){
                        pob.availableChannels += 'ECom#Single#';
                    }
                    if(!ad.No_Retail_Channel__c && pob.availableChannels.indexOf('#Retail#') == -1){
                        pob.availableChannels += 'Retail#';
                    }
                    if(!ad.No_Other_Retail_Channel__c && pob.availableChannels.indexOf('#Other Retailer#') == -1){
                        pob.availableChannels += 'Other Retailer#';
                    }
                }

                Log.push('Reason_Code_Details__c Picklist: ' + optionConfig.get('Reason_Code_Details__c').size());
                optionConfig.get('Reason_Code__c').add(pob);
            }

            Log.push('Reason_Code__c Picklist: ' + optionConfig.get('Reason_Code__c'));
        }
        Logger.logDebug();
        return optionConfig;
    }

    private static List<FieldObject> getFieldDetails(String obj, String fsName){
        List<FieldObject> result;
        try{
            List<Schema.FieldSetMember> fields = Schema.getGlobalDescribe().get(obj).getDescribe().fieldSets.getMap().get(fsName).getFields();
            if(fields != NULL && !fields.isEmpty()){
                result = new List<FieldObject>();
                for(Schema.FieldSetMember flds : fields){
                    FieldObject fObj = new FieldObject();
                    //If label is to be changed, refer to NF_Brand_Form_Constants
                    fObj.fieldLabel = NF_Brand_Form_Constants.fieldLabels.get(flds.getFieldPath());
                    fObj.fieldName = flds.getFieldPath();
                    fObj.fieldType = String.valueOf(flds.getType());
                    fObj.isRequired = flds.getRequired();
                    //Don't display Channel section if singleBrandChannelValue is present for this brand
                    if(
                        fObj.fieldName != 'Channel__c' || (
                            config != null && String.isBlank(config.brand.singleBrandChannelValue)
                        )
                    ){
                        result.add(fObj);
                    }
                }
            }
        }
        catch(Exception ex){
        }
        return result;
    }

    private static void processCaseRelatedFiles(CaseAttachmentObject caob){
        List<SObject> filesListToUpsert, filesListToDelete;
        Log.push('caob 2 >> ' + caob);

        if(caob != NULL){
            filesListToDelete = new List<SObject>();
            filesListToUpsert = new List<SObject>();

            if(caob.filesToLink != NULL && !caob.filesToLink.isEmpty()){
                for(FileObject ob : caob.filesToLink){
                    ContentDocumentLink cdl = new ContentDocumentLink();
                    cdl.ContentDocumentId = ob.documentId;
                    cdl.LinkedEntityId = caob.parentId;                             //Link to case
                    cdl.ShareType = 'V';                                            //Share with All internal users
                    filesListToUpsert.add(cdl);                                     //Add ContentDocumentLink
                }

                insert filesListToUpsert;
            }

            if(caob.filesToDelete != NULL && !caob.filesToDelete.isEmpty()){
                for(FileObject ob : caob.filesToDelete){
                    ContentDocument cd = new ContentDocument();
                    cd.Id = ob.documentId;
                    filesListToDelete.add(cd);
                }

                delete filesListToDelete;
            }
        }
        Logger.logDebug();
    }

    @TestVisible
    private static PicklistObject selectOption(){
        PicklistObject adob = new PicklistObject();
        adob.label = '--- Select Option ---';
        adob.value = '';
        adob.order = 0;
        adob.show = true;
        adob.key = 0;
        return adob;
    }

    public static BrandObject getBrandConfig(String brandname){
        return new BrandObject(getBrand(brandname));
    }

    public static SObject getBrand(String brandname){
        return [
            SELECT Brand_Name__c, Brand_Code__c, Case_Success_Message__c, Track_Order_At__c,
            Logo_URL__c, Password_Reset_At__c, Check_Order_Status_At__c, Show_Logo__c, (
                SELECT Value__c, Order__c, Type__c
                FROM Brand_Channels__r
                WHERE Type__c = 'Single'
                ORDER BY Order__c ASC NULLS LAST
                LIMIT 1
            )
            FROM Webform_Brands__mdt
            WHERE Brand_Name__c =: brandname
            LIMIT 1
        ];
    }

    public static List<SObject> getAllBrands(){
        return [SELECT Brand_Name__c, Brand_Code__c, MasterLabel
                FROM Webform_Brands__mdt
                ORDER By MasterLabel ASC];
    }

    public class FieldObject{
        @AuraEnabled
        public String fieldName = '';
        @AuraEnabled
        public String fieldLabel = '';
        @AuraEnabled
        public String fieldType = '';
        @AuraEnabled
        public Boolean isRequired = false;

        public FieldObject(){}
        public FieldObject(String nm, String lab, Boolean show, String typ){
            this.fieldName = nm;
            this.fieldLabel = lab;
            this.fieldType = typ;
            this.isRequired = show;
        }
    }

    public class PicklistObject{
        @AuraEnabled
        public String label = '';
        @AuraEnabled
        public String value = '';
        @AuraEnabled
        public String parent = '';
        @AuraEnabled
        public Integer order = -1;
        @AuraEnabled
        public Boolean show = true;
        @AuraEnabled
        public String information = ''; //Will hold AdditionalECom for Brand_Form_Additional_Details__mdt
        @AuraEnabled
        public String secondaryAction = '';
        @AuraEnabled
        public String type = '';
        @AuraEnabled
        public String additionalRetail = '';
        @AuraEnabled
        public String additionalOtherRetail = '';
        @AuraEnabled
        public Boolean noECom = false;
        @AuraEnabled
        public Boolean noSingle = false;
        @AuraEnabled
        public Boolean noRetail = false;
        @AuraEnabled
        public Boolean noOtherRetailer = false;
        @AuraEnabled
        public Integer key = 0;
        @AuraEnabled
        public String availableChannels = '';
        @AuraEnabled
        public String developerName = '';
    }

    public class FormConfig{
        @AuraEnabled
        public Id userId = UserInfo.getUserId();
        @AuraEnabled
        public BrandObject brand = NULL;
        @AuraEnabled
        public List<FieldObject> fields = NULL;
        @AuraEnabled
        public Map<String,List<PicklistObject>> fieldOptions = NULL;
    }

    public class BrandObject{
        @AuraEnabled
        public Integer brandCode = 0;
        @AuraEnabled
        public String brandName = '';
        @AuraEnabled
        public String caseSuccessMessage = '';
        @AuraEnabled
        public String logoUrl = '';
        @AuraEnabled
        public String orderTrackerLink = '';
        @AuraEnabled
        public String orderStatusLink = '';
        @AuraEnabled
        public String passwordResetLink = '';
        @AuraEnabled
        public Boolean showLogo = false;
        @AuraEnabled
        public String singleBrandChannelValue = '';

        /**
         * Every field added should be queuried in "getBrand" method.
        */
        public BrandObject(SObject so){
            this.brandCode = Integer.valueOf(so.get('Brand_Code__c'));
            this.brandName = String.valueOf(so.get('Brand_Name__c'));
            this.caseSuccessMessage = String.valueOf(so.get('Case_Success_Message__c'));
            this.orderTrackerLink = String.valueOf(so.get('Track_Order_At__c'));
            this.orderStatusLink = String.valueOf(so.get('Check_Order_Status_At__c'));
            this.passwordResetLink = String.valueOf(so.get('Password_Reset_At__c'));
            this.logoUrl = String.valueOf(so.get('Logo_URL__c'));
            this.showLogo = Boolean.valueOf(so.get('Show_Logo__c'));

            List<SObject> brandChannels = so.getSObjects('Brand_Channels__r');
            if(brandChannels != null && !brandChannels.isEmpty()){
                this.singleBrandChannelValue = String.valueOf(brandChannels[0].get('Value__c'));
            }
        }
    }

    public class CaseAttachmentObject{
        public String parentId = '';
        public List<FileObject> filesToLink = NULL;
        public List<FileObject> filesToDelete = NULL;

        public CaseAttachmentObject(){}
    }

    public class FileObject{
        public String name = '';
        public String documentId = '';
    }
}