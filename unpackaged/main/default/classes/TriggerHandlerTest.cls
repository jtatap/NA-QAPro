@isTest
public class TriggerHandlerTest {
@isTest
    static void testdefinitions(){
       Map<Id, sObject> testMap = new Map<Id, sObject>();
        List<sObject> newList = new List<sObject>();
        TriggerHandlerExtension th = new TriggerHandlerExtension();
        th.beforeUpdate(testMap,testMap);
        th.beforeDelete(testMap);
        th.beforeInsert(newList);
        th.afterInsert(testMap);
        th.afterDelete(testMap);
        th.afterUnDelete(testMap);
        th.afterUpdate(testMap,testMap);
        th.isDisabled();
    }
}