/**
 * @class:       BrandNamePicklist
 * @JIRA:        NASSC-25, NASSC-354
 * @description: Class to Fetch Brand Names and show as Drop Down as Design Attribute
 *				 This class is called from BrandForm Design Resource
 */ 

global class BrandNamePicklist extends VisualEditor.DynamicPickList{
    
    global override VisualEditor.DataRow getDefaultValue(){
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('None', 'None');
        return defaultValue;
    }
    global override VisualEditor.DynamicPickListRows getValues() {
       
        String fieldName = 'Brand__c';
        VisualEditor.DynamicPickListRows  picklistValues = new VisualEditor.DynamicPickListRows();
        Map<String, Schema.SObjectField> currPageObjectfieldsMap = Schema.getGlobalDescribe().get('Case').getDescribe().fields.getMap();
        
        for(Schema.SObjectField field : currPageObjectfieldsMap.values())
        {
            Schema.DescribeFieldResult descField = field.getDescribe();
            if(String.ValueOf(descField.type)=='PICKLIST' && descField.getName()==fieldName)
            {
                List<Schema.PicklistEntry> valuesList = new List<Schema.PicklistEntry>();
                valuesList = descField.getPicklistValues();
                
                for(Schema.PicklistEntry value : valuesList)
                {
                    VisualEditor.DataRow dataRow = new VisualEditor.DataRow(value.getLabel(), value.getValue());
                    picklistValues.addRow(dataRow);
                }
                break;
            }
            
        }
        
        return picklistValues;
    }
}