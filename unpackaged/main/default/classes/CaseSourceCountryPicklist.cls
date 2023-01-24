/**
 * @class:       CaseSourceCountryPicklist
 * @JIRA:        NASSC-25, NASSC-354, NASSC-520
 * @description: Class to Fetch Case Source Country and show as Drop Down as Design Attribute
 *				 This class is called from BrandForm Design Resource
 */ 

global class CaseSourceCountryPicklist extends VisualEditor.DynamicPickList{
    
    global override VisualEditor.DataRow getDefaultValue(){
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('None', 'None');
        return defaultValue;
    }
    global override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DataRow defaultValue = getDefaultValue();
        
        List<String> listCaseSourceCountry = new List<String>();
        Schema.sObjectType objTypeCase = Case.getSObjectType();
        Schema.DescribeSObjectResult objDescribe = objTypeCase.getDescribe();
        map <String, Schema.SObjectField> typeMap = objDescribe.fields.getMap();
        list <Schema.PicklistEntry> countryValues = typeMap.get('Case_Source_Country__c').getDescribe().getPickListValues();
        for (Schema.PicklistEntry ent: countryValues) 
        {
            // listBrands.add(ent.getValue());
            listCaseSourceCountry.add(ent.getLabel());
        }
       	System.debug('***Got BrandList = '+listCaseSourceCountry);
        
        VisualEditor.DynamicPickListRows  countryNameList = new VisualEditor.DynamicPickListRows();
        for(String getValue : listCaseSourceCountry)
        {
            VisualEditor.DataRow CountryName = new VisualEditor.DataRow(getValue,getValue);
            countryNameList.addRow(CountryName);
        }
        System.debug('***brandNameList = '+countryNameList);
        return countryNameList;
    }
}