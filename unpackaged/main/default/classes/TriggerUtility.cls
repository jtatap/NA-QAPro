/**
    * Class Name: TriggerUtility
    * Description: To check whether Trigger is Active
    * Created By: Neuraflash LLC, 2020
    * Author: Anshu Chaudhary
**/
public with sharing class TriggerUtility {

    private static Map<String, Boolean> sObjTriggerSettingMap = new Map<String, Boolean>();

    public static Boolean runTrigger(String objectName) {
        if(!sObjTriggerSettingMap.keySet().isEmpty() && sObjTriggerSettingMap.containsKey(objectName)){
            return sObjTriggerSettingMap.get(objectName);
        } else {
            for (Trigger_Settings__mdt settings:[SELECT MasterLabel,Is_Trigger_Deactivated__c 
                                                FROM Trigger_Settings__mdt WHERE MasterLabel = :objectName]) {
                sObjTriggerSettingMap.put(objectName, settings.Is_Trigger_Deactivated__c);
                return settings.Is_Trigger_Deactivated__c;
            }
        }
        sObjTriggerSettingMap.put(objectName,false);
        return false;
    }

    
}