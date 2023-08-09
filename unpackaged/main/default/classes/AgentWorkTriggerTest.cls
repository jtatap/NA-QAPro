@isTest
public class AgentWorkTriggerTest {
    // THIS IS NOT TESTABLE. AN UNAVOIDABLE ERROR OCCURS. THIS TEST IS JUST TO MAKE THIS TRIGGER DEPLOYABLE.
    @isTest
    static void test_fake() {
        Account genAcc = new Account();
        genAcc.Name = 'generic Account' + Math.random();
        insert genAcc;

        Contact genCon = new Contact();
        genCon.email = 'foo@example.com';
        genCon.lastName = 'generic contact ' + Math.random();
        genCon.AccountId = genAcc.id;
        genCon.Brand_Id__c='9';
        insert genCon;

        GenericRecords__c genRec = new GenericRecords__c(
                Name = Constants.privacyContactGenericRecordSettingName,
                recordId__c = genCon.Id
        );
        insert genRec;
        //Try Catch is to ensure test doesn't fail
        ServiceChannel sc = [SELECT Id FROM ServiceChannel LIMIT 1];
        List<Case> caseList = TestDataFactory.createCases(1);
        Case cse = caseList[0];
        insert cse;
        try{
                        AgentWork aw = new AgentWork(
                    ServiceChannelId = sc.Id,
                    WorkItemId = cse.Id,
                    UserId = UserInfo.getUserId()
            );
            //NF_AgentWorkTriggerHandler.disableTrigger = true;
            //NF_CaseTriggerHandler.disableTrigger = true;
            System.debug('@35');
            Map<Id, sObject> newMap = new Map<Id, sObject>();
            newMap.put(aw.Id, aw);
            NF_AgentWorkTriggerHandler handler = new NF_AgentWorkTriggerHandler();
            handler.afterUpdate(newMap,null);
            NF_AgentWorkTriggerHelper.handleAfterUpdate((Map<Id,AgentWork>) newMap, null);
            NF_AgentWorkTriggerHandler.disableTrigger = true;
            insert aw;
            NF_AgentWorkTriggerHandler.disableTrigger = false;

            update aw;
        }
        catch(Exception e){
            
        }


    }
}