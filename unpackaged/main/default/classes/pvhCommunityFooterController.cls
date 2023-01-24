public class pvhCommunityFooterController {

    @AuraEnabled(cacheable = true)
    public static Map<String, List<Community_Footer_Items__mdt>> getFooterData(String brandName) {
        try {
             Map<String, List<Community_Footer_Items__mdt>> mapFooterLabelToValue = new Map<String, List<Community_Footer_Items__mdt>>();
             for(Community_Footer_Items__mdt eachData : [SELECT Brand__c, Brand__r.Brand_Name__c, Name__c, Value__c,
                                                            Header__c, Item_SequenceNo__c, Open_In_New_Tab__c, Header_SequenceNo__c
                                                                FROM Community_Footer_Items__mdt 
                                                                    WHERE Brand__r.MasterLabel =: brandName
                                                                        ORDER BY Header_SequenceNo__c, Item_SequenceNo__c ASC]) {
                
                if(mapFooterLabelToValue.containsKey(eachData.Header__c)) {
                    List<Community_Footer_Items__mdt> lstTempMdt = mapFooterLabelToValue.get(eachData.Header__c);
                    lstTempMdt.add(eachData);
                    mapFooterLabelToValue.put(eachData.Header__c, lstTempMdt);
                } else {
                    mapFooterLabelToValue.put(eachData.Header__c, new List<Community_Footer_Items__mdt>{eachData});
                }
            } 
            if(!mapFooterLabelToValue.keySet().isEmpty()) return mapFooterLabelToValue; 
        } catch(Exception ex) {
            System.debug('Exception :::'+ ex.getMessage());
        }
        return null;
    }

    @AuraEnabled(cacheable = true)
    public static Map<Integer, List<Community_Footer_Copyright_Area_Items__mdt>> getFooterCopyrightAreaData(String brandName) {
        try {
            Map<Integer, List<Community_Footer_Copyright_Area_Items__mdt>> mapLabelToValue = new Map<Integer, List<Community_Footer_Copyright_Area_Items__mdt>>();
             for(Community_Footer_Copyright_Area_Items__mdt eachData : [SELECT Brand__c, Brand__r.Brand_Name__c, Name__c, Value__c,
                                                                             Open_In_New_Tab__c, Row_SequenceNo__c,Item_SequenceNo__c
                                                                                FROM Community_Footer_Copyright_Area_Items__mdt 
                                                                                    WHERE Brand__r.MasterLabel =: brandName
                                                                                        ORDER BY Row_SequenceNo__c, Item_SequenceNo__c DESC]) {
                
                if(mapLabelToValue.containsKey(Integer.valueOf(eachData.Row_SequenceNo__c))) {
                    List<Community_Footer_Copyright_Area_Items__mdt> lstTempMdt = mapLabelToValue.get(Integer.valueOf(eachData.Row_SequenceNo__c));
                    lstTempMdt.add(eachData);
                    mapLabelToValue.put(Integer.valueOf(eachData.Row_SequenceNo__c), lstTempMdt);
                } else {
                    mapLabelToValue.put(Integer.valueOf(eachData.Row_SequenceNo__c), new List<Community_Footer_Copyright_Area_Items__mdt>{eachData});
                }
            } 
            System.debug('-- checking data--'+mapLabelToValue);
            if(!mapLabelToValue.keySet().isEmpty()) return mapLabelToValue; 
        } catch(Exception ex) {
            System.debug('Exception :::'+ ex.getMessage());
        }
        return null;
    } 
}