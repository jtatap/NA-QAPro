global class NF_BrandNamePicklist extends VisualEditor.DynamicPickList{
    
    global override VisualEditor.DataRow getDefaultValue(){
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('None', 'None');
        return defaultValue;
    }

    global override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows picklistValues = new VisualEditor.DynamicPickListRows();
        
        List<SObject> allBrands = NF_BrandFormController.getAllBrands();
        if(allBrands != NULL && !allBrands.isEmpty()){
            for(SObject so : allBrands){
                picklistValues.addRow(new VisualEditor.DataRow(String.valueOf(so.get('Brand_Name__c')), String.valueOf(so.get('Brand_Name__c'))));
            }
        }
        return picklistValues;
    }
}