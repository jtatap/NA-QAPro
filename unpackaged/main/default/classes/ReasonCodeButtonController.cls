public class ReasonCodeButtonController {
    @AuraEnabled 
    public static Map<String, List<String>> getDependentPicklist(sObject objDetail,string contrfieldApiName,string depfieldApiName ) {
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
       
        
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        Schema.sObjectType objType = objDetail.getSObjectType();
        if (objType==null){
            return objResults;
        }
        
       Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
      
        
        
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            return objResults;     
        }
        
        Schema.SObjectField theField = objFieldMap.get(dependentField);
        Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
        
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : contrEntries) {
            String label = ple.getLabel();
            objResults.put(label, new List<String>());
            controllingValues.add(label);
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String label = plew.label;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    objResults.get(controllingValues.get(i)).add(label);
                }
            }
        }
        return objResults;
    }
    
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        
        return validForBits;
    }
    
    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    
    
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }
    
    
     @AuraEnabled
        public static List<String> getselectOptions(sObject objObject, string fld) {
                  system.debug('objObject --->' + objObject);
                  system.debug('fld --->' + fld);
                  List<String> allOpts = new list<String> ();
                  // Get the object type of the SObject.
                  Schema.sObjectType objType = objObject.getSObjectType();
                 
                  // Describe the SObject using its object type.
                  Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
                 
                  // Get a map of fields for the SObject
                  map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
                 
                  // Get the list of picklist values for this field.
                  list<Schema.PicklistEntry> values =fieldMap.get(fld).getDescribe().getPickListValues();
                 
                  // Add these values to the selectoption list.
                  for (Schema.PicklistEntry a: values) {
                   allOpts.add(a.getValue());
                  }
                  system.debug('allOpts ---->' + allOpts);
                  allOpts.sort();
                  return allOpts;
       }
    public class PicklistEntryWrapper{
        public String active {get;set;}
        public String defaultValue {get;set;}
        public String label {get;set;}
        public String value {get;set;}
        public String validFor {get;set;}
        public PicklistEntryWrapper(){            
        }
        
    }
    /*  @AuraEnabled get Case Manufaturer Picklist Values 
   public static List<String> getManufacturers(){
        List<String> pickListValuesList = new List<String>();
        Schema.DescribeFieldResult fieldResult = Case.Reason_Code_Manufacturers__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
            System.debug('Values in Manufacturers are: '+pickListValuesList);
        }     
        return pickListValuesList;
    }*/
     
    
    @AuraEnabled
    public static List<Case> updateCase (String recordId ,String grandParent,String productSubCategory, String parentField,String childField ,date dateofServiceIssue, String storeNumber , String districtNumber, String updateAccountInfoReason , String manufacturer,String productCategory, string skuNumber,string thirdPartyVendor){
        list<Case> caseList = new list<Case>();
        list<Case> updatedCaseList = new list<Case>();
        caseList = [select Id,ZdPVHDateofServiceIssue__c, ZdPVHStoreNumber__c ,Reason_Code_Product_Sub_Categories_Widge__c,ZdPVHDistrictNumber__c,ZdPVHUpdateAccountInfoReason__c, Reason_Code__c, Reason_Code_Details__c,Reason_Sub_detail__c,Reason_Code_Manufacturers__c,Reason_Code_Product_Category__c,Sku_Style_Number__c,Third_Party_Vendors__c from case where Id =: recordId];
      
      for(Case cse : caseList){
          cse.Reason_Code__c = grandParent ;
          cse.Reason_Code_Details__c=parentField;
          cse.Reason_Sub_detail__c = childField ;
          cse.ZdPVHDateofServiceIssue__c=dateofServiceIssue;
          cse.ZdPVHStoreNumber__c = storeNumber ;
          cse.ZdPVHDistrictNumber__c=districtNumber;
          cse.ZdPVHUpdateAccountInfoReason__c=updateAccountInfoReason;
          cse.Reason_Code_Manufacturers__c=manufacturer;
          cse.Reason_Code_Product_Category__c=productCategory;
          cse.Sku_Style_Number__c=skuNumber;
          cse.Third_Party_Vendors__c=thirdPartyVendor;
          cse.Reason_Code_Product_Sub_Categories_Widge__c=productSubCategory;
          //todo: replace reason code and details
          if(cse.Reason_Code__c!=Null || cse.Reason_Code_Details__c!=Null || cse.Reason_Sub_detail__c!=Null ||
             cse.ZdPVHDateofServiceIssue__c!=Null || cse.ZdPVHStoreNumber__c!=Null || cse.ZdPVHDistrictNumber__c!=Null || cse.ZdPVHUpdateAccountInfoReason__c!=Null || cse.Reason_Code_Manufacturers__c!=Null || cse.Reason_Code_Product_Category__c!=Null||
             cse.Sku_Style_Number__c!=Null || cse.Third_Party_Vendors__c!=Null ||
             cse.Reason_Code_Product_Sub_Categories_Widge__c!=Null
            ){ 
                          updatedCaseList.add(cse);
                }
          
          }
       
        
        if(updatedCaseList.size()>0){
            
             update updatedCaseList;            
           }
      
          return updatedCaseList;
 }
    @AuraEnabled
    public static List<Case> trueNcoUpdateCase (String recordId ,String grandParent,String parentField,String childField,String skuNumber,string channel,String placeOfPurchase){
       list<Case> caseList = new list<Case>();
       list<Case> updatedTrNcoCaseList = new list<Case>(); 
       caseList = [select Id,Brand__c,Channel__c,Place_of_Purchase__c,Reason_Code__c,Reason_Code_Details__c,Reason_Sub_detail__c,TrueAndCo_ReasonCodes__c, TrueAndCo_ReasonCodeDetails__c ,TrueAndCo_ReasonSubDetail__c,Sku_Style_Number__c from case where Id =: recordId AND Brand__c='11'];
       system.debug(caseList+'**caseList**');
        
        string chan;
        if(channel=='Online - trueandco.com'){
            chan='trueandco.com';
        }
        else{
           chan=channel; 
        }
        
       for(Case cse : caseList){
         cse.Reason_Code__c = grandParent ;
         cse.Reason_Code_Details__c=parentField;
         cse.Reason_Sub_detail__c = childField ;
         cse.TrueAndCo_ReasonCodes__c = grandParent ;
         cse.TrueAndCo_ReasonCodeDetails__c=parentField;
         cse.TrueAndCo_ReasonSubDetail__c = childField ;   
         cse.Sku_Style_Number__c=skuNumber;
         cse.Channel__c=chan;
         cse.Place_of_Purchase__c=placeOfPurchase;
           if(cse.Reason_Code__c !=Null || cse.Reason_Code_Details__c !=Null || cse.Reason_Sub_detail__c !=Null || cse.Sku_Style_Number__c !=Null
              || cse.TrueAndCo_ReasonCodes__c !=Null || cse.TrueAndCo_ReasonCodeDetails__c !=Null ||  cse.TrueAndCo_ReasonSubDetail__c !=Null ||
             cse.Place_of_Purchase__c!= Null
             ){
              updatedTrNcoCaseList.add(cse);
           } 
        /*  cse.TrueAndCo_ReasonCodes__c = grandParent ;
         cse.TrueAndCo_ReasonCodeDetails__c=parentField;
         cse.TrueAndCo_ReasonSubDetail__c = childField ;  
           if(cse.TrueAndCo_ReasonCodes__c!=Null || cse.TrueAndCo_ReasonCodeDetails__c!=Null || cse.TrueAndCo_ReasonSubDetail__c!=Null){
              updatedCaseList.add(cse);
           } */
        
       }
        
      if(updatedTrNcoCaseList.size()>0){
        update updatedTrNcoCaseList;            
      }
        
       return updatedTrNcoCaseList;  
    }
    
}