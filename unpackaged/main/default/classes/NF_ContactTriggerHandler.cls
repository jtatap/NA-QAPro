public class NF_ContactTriggerHandler extends TriggerHandler{
    public override void beforeInsert(List<sObject> newList){
        NF_ContactTriggerHelper nf = new NF_ContactTriggerHelper();
        nf.handleBeforeInsert((List<Contact>) newList);
        nf.handleBeforeInsertConTrigger((List<Contact>) newList);
        nf.handleBeforeInsertConTriggerHandler((List<Contact>) newList);
    }
    public override void beforeUpdate(Map<Id,sObject> newMap, Map<Id,sObject> oldMap){
        NF_ContactTriggerHelper nf = new NF_ContactTriggerHelper();
        nf.handleBeforeUpdate((Map<Id,Contact>)newMap, (Map<Id,Contact>)oldMap);
        nf.handleBeforeUpdateConTrigger((Map<Id,Contact>)newMap, (Map<Id,Contact>)oldMap);
        
    }

    public override void beforeDelete(Map<Id,sObject> oldMap){
        NF_ContactTriggerHelper nf = new NF_ContactTriggerHelper();
        nf.handleBeforeDeleteConTriggerHandler((Map<Id,Contact>)oldMap);
        nf.handleBeforeDeleteConTriggerHandler2((Map<Id,Contact>)oldMap);
    }

    public override void afterInsert(Map<Id, sObject> newMap){
        NF_ContactTriggerHelper nf = new NF_ContactTriggerHelper();
        nf.handleAfterInsertConTrigger((Map<Id,Contact>)newMap);
    }

    public override void afterUpdate(Map<Id, sObject> newMap, Map<Id, sObject> oldMap){
        NF_ContactTriggerHelper nf = new NF_ContactTriggerHelper();
        nf.handeAfterUpdateConTrigger((Map<Id,Contact>)newMap, (Map<Id,Contact>)oldMap);
        nf.handleAfterUpdateConTrigger2((Map<Id,Contact>)newMap, (Map<Id,Contact>)oldMap);
        nf.handleAfterUpdateConTriggerHandler((Map<Id,Contact>)newMap, (Map<Id,Contact>)oldMap);
    }

    
}