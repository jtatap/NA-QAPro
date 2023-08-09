@IsTest
public class TriggerHandlerTest2 {
	@isTest
    static void testdefinitions(){
       Map<Id, sObject> testMap = new Map<Id, sObject>();
        TriggerHandlerExtension th = new TriggerHandlerExtension();
        th.afterUpdate(testMap,testMap);
        
    }
}