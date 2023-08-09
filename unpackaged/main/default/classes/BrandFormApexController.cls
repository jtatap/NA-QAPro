/**
 * @class:       BrandFormApexController
 * @JIRA:        NASSC-25, NASSC-354
 * @description: Controller Class to show picklist values from Custom Metadata to Brand Form and
 *                 create a case in Salesforce after form submission
 */
/**
 * @author Magnet360
 *
 * @date 2019
 *
 * @description Brand form controller
 *
 */
public without sharing class BrandFormApexController{
    /*******************************************************************************************************
     * @description Method to fetch below field Values from Case Custom Metadata - Brand Form Picklist, and show it to Brand Form
     * This method is called at Brand Form Initialization
     * @param brandName Brand name sent from Form
     * @param sourceCountry Either US or CA. Used only for CK Canada
     * @return InitialDataWrapper
     * @example
     */
    @AuraEnabled
    public static InitialDataWrapper getData(String brandName, String sourceCountry){
        InitialDataWrapper wrapperObject = new InitialDataWrapper();
        Map<Decimal, List<String>> myMap = new Map<Decimal, List<String>>();
        Set<String> setQuestions = new Set<String>();
        //String newSearchText = '%'+brandName+'%';
        //String countrySearchText = '%'+sourceCountry+'%';
        //Log.push('We Got: Brand Name = '+brandName+' and Case Source Country = '+sourceCountry);
        List<Brand_Form_Picklist__mdt> listBrandData = [Select Id, Sequence__c, Brand_Name__c, Question__c, Picklist_Values_JSON__c
                                                        from Brand_Form_Picklist__mdt
                                                        where Brand_Name__c = :brandName AND Country__c = :sourceCountry
                                                        order by Sequence__c ASC];
        Log.push('***Got ' + brandName + ' data = ' + listBrandData);

        for (Brand_Form_Picklist__mdt bData : listBrandData){

            //Log.push('***Sequence = '+bData.Sequence__c);
            List<String> tempList = bData.Picklist_Values_JSON__c.Split(';');
            myMap.put(bData.Sequence__c.intValue(), tempList);

        }
        //Log.push('***We got Map = '+myMap);
        wrapperObject.listQue0 = myMap.get(0);
        wrapperObject.listQue1 = myMap.get(1);
        wrapperObject.listQue3 = myMap.get(3);
        wrapperObject.listQue4 = myMap.get(4);
        wrapperObject.userId = UserInfo.getUserId();


        //fetching the Success Message based on Brand
        List<Success_Message_Setting__mdt> getMessage = [Select Id, Success_Message_f__c
                                                         from Success_Message_Setting__mdt
                                                         Where Type__c = 'B' and Brand_Name__c = :brandName and Country__c = :sourceCountry];

        if (!getMessage.isEmpty()){
            //Log.push('***Got Configurd Message');
            wrapperObject.successMessage = getMessage[0].Success_Message_f__c;
        } else{
            //Log.push('***No Configurd Message. Default Message is Set');
            wrapperObject.successMessage = SYSTEM.LABEL.BrandFormApexControllerSuccessMessage;
        }
        Logger.logDebug();
        return wrapperObject;
    }

    /* Method to create Case in Salesforce when Privacy Form is submitted and return:
     * WrapperObject with:
     * CaseNumber and
     * Success Message (Custom Metadata - Success Message Setting)
     * Regards (Custom Metadata - Success Message Setting)
     */
    /*******************************************************************************************************
     * @description Method to create Case in Salesforce when Privacy Form is submitted and return:
     * WrapperObject with:
     * CaseNumber and
     * Success Message (Custom Metadata - Success Message Setting)
     * Regards (Custom Metadata - Success Message Setting)
     * @param getCaseDetail details of case sent from form
     * @param FirstName first name inputed from page
     * @param FirstName first name inputed from page
     * @return
     * @example
     */
    @AuraEnabled
    public static CaseWrapper createCase(Case getCaseDetail, String firstName, String lastName, String name, String brandName){
        //Log.push('***inside createCase Method');
        CaseWrapper CaseWrapperObject = new CaseWrapper();


        Id recordTypeIdSupportCase = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support_Case').getRecordTypeId();

        //call method to get API name of Brand:
        String getAPINameBrand = getBrandAPIName(brandName);
        //Log.push('***We got BrandAPIName = '+getAPINameBrand);

        //Log.push('***Tommy Adaptive = '+getCaseDetail.Tommy_Adaptive__c);
        // Log.push('***We got Product Sub Category = '+getCaseDetail.Product_Sub_Category__c);

        Log.push('***We got Channel = ' + getCaseDetail.Channel__c);
        string channel = getCaseDetail.Channel__c;
        if (getCaseDetail.Channel__c == SYSTEM.LABEL.True_Co_website){
            channel = SYSTEM.LABEL.trueandco_com;
        } else{
            channel = getCaseDetail.Channel__c;
        }

        //Fetching the assignment rules on case
        AssignmentRule assignRule = new AssignmentRule();
        assignRule = [select id
                      from AssignmentRule
                      where SobjectType = 'Case' and Active = true and Name =: SYSTEM.LABEL.Case_Assignment_Rule
                      limit 1];
        Log.push('assignRule***' + assignRule);
        //Creating the DMLOptions for "Assign using active assignment rules" checkbox
        Database.DMLOptions dmls = new Database.DMLOptions();
        dmls.assignmentRuleHeader.assignmentRuleId = assignRule.id;
        Log.push('dmls***' + dmls);


        Case newCases = new Case(
                Supplied_First_Name__c = firstName,
                Supplied_Last_Name__c = lastName,
                SuppliedName = name,
                SuppliedEmail = getCaseDetail.SuppliedEmail,
                SuppliedPhone = getCaseDetail.SuppliedPhone,
                Is_Existing_Purchase__c = getCaseDetail.Is_Existing_Purchase__c,
                Channel__c = channel,
                Type = getCaseDetail.Type,
            //    Reason_Code__c=getCaseDetail.Type,
                Description = getCaseDetail.Description,
                Brand__c = brandName,
                Tommy_Adaptive__c = getCaseDetail.Tommy_Adaptive__c,
                Origin = 'Web',
                Order_Number__c = getCaseDetail.Order_Number__c,
                recordTypeId = recordTypeIdSupportCase
        );

        //Setting the DMLOption on Case instance
        newCases.setOptions(dmls);
        Log.push('newCases***' + newCases);

        try{
            insert newCases;
        } catch (DmlException e){
            Log.push('The following exception has occurred: ' + e.getMessage());
        }

        Case getCase = new Case();
        if (newCases != Null){
            getCase = [Select Id, caseNumber
                       from Case
                       where Id = :newCases.Id];

        }
        //Log.push('***Case Inserted = '+getCase.CaseNumber);

        if (getCase != Null){
            CaseWrapperObject.caseId = getCase.Id;
            CaseWrapperObject.caseNumber = getCase.caseNumber;
        }
        Logger.logDebug();
        return CaseWrapperObject;
    }

    public static String getBrandAPIName(String brandNames){
        Map<String, String> mapBrandLabelValue = new Map<String, String>();
        Schema.sObjectType objTypeCase = Case.getSObjectType();
        Schema.DescribeSObjectResult objDescribe = objTypeCase.getDescribe();
        map<String, Schema.SObjectField> typeMap = objDescribe.fields.getMap();
        list<Schema.PicklistEntry> brandValues = typeMap.get('Brand__c').getDescribe().getPickListValues();
        for (Schema.PicklistEntry ent : brandValues){
            mapBrandLabelValue.put(ent.getLabel(), ent.getValue());
        }
        //Log.push('***We got BrandMap = '+mapBrandLabelValue);
        String brandAPIName = mapBrandLabelValue.get(brandNames);
        return brandAPIName;
    }

    @auraEnabled
    public static String assignFilesToCase(String[] files, Id caseId){
        Log.push('files@@@ ' + files);

        Set<String> fileIds = new Set<String>(files);

        Log.push('fileIds@@@ ' + fileIds);

        List<ContentDocument> cd = [SELECT Id, ParentId
                                    FROM ContentDocument
                                    WHERE Id IN:fileIds];

        List<ContentDocumentLink> cdl = new List<ContentDocumentLink>();

        for (ContentDocument cdItem : cd){
            ContentDocumentLink cDocLink = new ContentDocumentLink();
            cDocLink.ContentDocumentId = cdItem.Id;//Add ContentDocumentId
            cDocLink.LinkedEntityId = caseId;//Add attachment parentId
            cDocLink.ShareType = 'V'; //V - Viewer permission. C - Collaborator permission. I - Inferred permission.
            cdl.add(cDocLink);
        }

        insert cdl;

        Log.push('cdl AFTER: ' + cdl);
        Logger.logDebug();
        return '';
    }

    /*******************************************************************************************************
     * @description Deprecated method
     * @param sdocumentId
     * @return void
     */
    /*@AuraEnabled
     public static void deleteFiles(string sdocumentId) {
     delete [SELECT Id,Title,FileType from ContentDocument WHERE id = :sdocumentId];
     }*/
    public class InitialDataWrapper{
        @AuraEnabled
        public List<String> listQue0{ get; set; }

        @AuraEnabled
        public List<String> listQue1{ get; set; }

        @AuraEnabled
        public List<String> listQue3{ get; set; }

        @AuraEnabled
        public List<String> listQue4{ get; set; }

        @AuraEnabled
        public String successMessage{ get; set; }

        @AuraEnabled
        public String userId{ get; set; }

    }

    public class CaseWrapper{
        @AuraEnabled
        public String caseNumber{ get; set; }

        @AuraEnabled
        public String caseId{ get; set; }

    }

}